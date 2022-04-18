import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:tuple/tuple.dart';

/// [args] must be "HOSTNAME PORT EXPIRES_IN TOKEN PATH"
Future main(List<String> args) async {
  if (args.length < 5) {
    stderr.writeln('usage: git-lfs-server HOSTNAME PORT EXPIRES_IN TOKEN PATH');
    exitCode = 1;
    return;
  }

  _hostname = args[0];
  _port = int.parse(args[1]);
  _expiresIn = int.parse(args[2]);
  _token = args[3];
  _path = args[4];
  _log = Logger('git-lfs-server');

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    var out = File('git-lfs-server.log').openWrite(mode: FileMode.append);
    out.writeln('${record.level.name}: ${record.time}: ${record.message}');
    out.close();
  });

  final cascade = Cascade().add(_router);

  final server = await shelf_io.serve(
    logRequests().addHandler(cascade.handler),
    InternetAddress.anyIPv4, // Allows external connections
    _port,
  );

  _log.info('Serving at http://${server.address.host}:${server.port}');
  _log.info('Link will expire in $_expiresIn seconds');
  Timer(Duration(milliseconds: _expiresIn * 1000), () {
    _log.info('Shutting down');
    server.close();
    exit(0);
  }); // exit after _expiresIn seconds
}

late final Logger _log;
late final String _hostname;
late final int _port;
late final int _expiresIn;
late final String _token;
late final String _path;

// Router instance to handler requests.
final _router = shelf_router.Router()
  ..post('/objects/batch', _batchHandler)
  ..get('/oid/<[a-fA-F0-9]+>', _oidHandler);

Future<Response> _batchHandler(Request request) async {
  final authenticated = _authenticate(request);
  if (!authenticated.item1) {
    return authenticated.item2!;
  }

  final Response response = _proceedBody(await request.readAsString());

  return response;
}

Response _oidHandler(Request request, String oid) {
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
          'header': {'Authorization': 'Basic $_token'},
          'href': 'http://$_hostname:$_port/oid/$oid',
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

Tuple2<bool, Response?> _authenticate(Request request) {
  final auth = request.headers['Authorization'];
  if (auth != 'Basic $_token') {
    return Tuple2(false, Response.forbidden('Forbidden'));
  }

  return Tuple2(true, null);
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

  if (json['operation'] != 'download') {
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
