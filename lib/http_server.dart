import 'dart:convert';
import 'dart:io';

import 'package:http_multi_server/http_multi_server.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:tuple/tuple.dart';

import 'git_lfs.dart';

late final int _expiresIn;

late final String _hostname;
late final Logger _log;
late final String _path;
late final int _port;

/// Router instance to handler requests.
///
/// - `/objects/batch`: https://github.com/git-lfs/git-lfs/blob/main/docs/api/batch.md.
/// - `/oid/{OID}` (`{OID}` is a hexadecimal string (regex: `<[a-fA-F0-9]+>`)): download the object.
final _router = shelf_router.Router()
  ..post('/objects/batch', _batchHandler)
  ..get('/oid/<[a-fA-F0-9]+>', _fileHandler);

Tuple2<bool, Response?> _authenticate(Request request) {
  // TODO: rewrite this function.
  final auth = request.headers['Authorization'];
  // if (auth != 'Basic $_token') {
  //   return Tuple2(false, Response.forbidden('Forbidden'));
  // }

  return Tuple2(true, null);
}

Future<Response> _batchHandler(Request request) async {
  final authenticated = _authenticate(request);
  if (!authenticated.item1) {
    return authenticated.item2!;
  }

  final Response response = _proceedBody(await request.readAsString());

  return response;
}

Response _fileHandler(Request request, String oid) {
  final authenticated = _authenticate(request);
  if (!authenticated.item1) {
    return authenticated.item2!;
  }

  final first = oid.substring(0, 2);
  final second = oid.substring(2, 4);
  final file = File('$_path/lfs/objects/$first/$second/$oid');
  if (!file.existsSync()) {
    return Response.internalServerError(body: 'Object not found');
  }

  final bytes = file.readAsBytesSync();
  final headers = {
    'Content-Type': 'application/octet-stream',
    'Content-Length': bytes.length.toString(),
  };

  return Response.ok(bytes, headers: headers);
}

Response _proceedBody(String body) {
  final json = jsonDecode(body);

  Tuple2<bool, Response?> result = _validateJson(json);

  if (!result.item1) {
    return result.item2!;
  }

  final objects = json['objects'] as List;
  var responseObjects = <Map>[];

  for (final object in objects) {
    final oid = object['oid'] as String;
    final size = object['size'] as int;

    final first = oid.substring(0, 2);
    final second = oid.substring(2, 4);
    final file = File('$_path/lfs/objects/$first/$second/$oid');
    if (!file.existsSync()) {
      return Response.notFound('Not found');
    }

    final content = file.readAsBytesSync();
    if (content.length != size) {
      return Response.internalServerError(body: 'Internal server error');
    }

    responseObjects.add({
      'oid': oid,
      'size': size,
      'authenticated': true,
      'actions': {
        'download': {
          'expires_in': _expiresIn,
          // 'header': {'Authorization': 'Basic $_token'},
          'href': 'https://$_hostname:$_port/oid/$oid',
        },
      },
    });
  }

  final response = {'transfer': 'basic', 'objects': responseObjects};

  return Response.ok(
    const JsonEncoder.withIndent(' ').convert(response),
    headers: {
      'Content-Type': 'application/vnd.git-lfs+json',
    },
  );
}

Tuple2<bool, Response?> _validateJson(dynamic json) {
  if (json is! Map) {
    return Tuple2<bool, Response>(
        false, Response.badRequest(body: 'Invalid JSON'));
  }

  if (!json.containsKey('operation')) {
    return Tuple2<bool, Response>(
        false, Response.badRequest(body: 'Missing operation'));
  }

  if (json['operation'] != Operation.download.name) {
    // TODO: support upload
    return Tuple2<bool, Response>(
        false, Response.badRequest(body: 'Invalid operation'));
  }

  if (!json.containsKey('objects')) {
    return Tuple2<bool, Response>(
        false, Response.badRequest(body: 'Missing objects'));
  }

  final objects = json['objects'] as List;
  for (final object in objects) {
    if (!object.containsKey('oid')) {
      return Tuple2<bool, Response>(
          false, Response.badRequest(body: 'Missing oid'));
    }
    if (!object.containsKey('size')) {
      return Tuple2<bool, Response>(
          false, Response.badRequest(body: 'Missing size'));
    }
  }

  return Tuple2<bool, Response?>(true, null);
}

late final HttpServer _server;

class GitLfsServer {
  final String _hostname;
  final int _port;
  final SecurityContext _context;
  GitLfsServer(this._hostname, this._port, this._context);

  Future<void> start() async {
    _server = await HttpMultiServer.bindSecure('any', _port, _context);
    final cascade = Cascade().add(_router);
    shelf_io.serveRequests(_server, cascade.handler);

    _log.info('Listening at https://$_hostname:$_port');
  }

  Future<void> stop() async {
    _log.info('Stopping server');
    final closed = await _server.close();
    if (closed) {
      _log.info('Server stopped');
    } else {
      _log.warning('Server stop failed');
    }
  }
}
