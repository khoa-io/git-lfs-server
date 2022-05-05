import 'dart:convert';
import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart' as lfs;
import 'package:git_lfs_server/src/generated/authentication.pbgrpc.dart';
import 'package:grpc/grpc.dart'
    show ClientChannel, ChannelOptions, ChannelCredentials;
import 'package:http_multi_server/http_multi_server.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:tuple/tuple.dart';

import '../git_lfs.dart';

class GitLfsHttpServer {
  final String _hostname;
  final int _port;
  final SecurityContext _context;
  late final Logger _log;
  late final ClientChannel? _channel;
  late final AuthenticationClient _authClient;

  /// Router instance to handler requests.
  ///
  /// - `/objects/batch`: https://github.com/git-lfs/git-lfs/blob/main/docs/api/batch.md.
  /// - `/download/{OID}` (`{OID}` is a hexadecimal string (regex: `<[a-fA-F0-9]+>`)): download the object.
  late final shelf_router.Router _router;

  late final HttpServer _server;
  GitLfsHttpServer(this._hostname, this._port, this._context) {
    _router = shelf_router.Router()
      ..post('/objects/batch', _batchHandler)
      ..get('/download/<[a-fA-F0-9]+>', _downloadHandler);
  }

  Future<void> start() async {
    final udsa = InternetAddress(lfs.filelock, type: InternetAddressType.unix);
    _channel = ClientChannel(
      udsa,
      port: 0,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    _authClient = AuthenticationClient(_channel!);

    _server = await HttpMultiServer.bindSecure('any', _port, _context);
    final cascade = Cascade().add(_router);
    shelf_io.serveRequests(_server, cascade.handler);

    _log.info('Listening at https://$_hostname:$_port');
  }

  Future<void> stop() async {
    _log.info('Stopping server');
    await _channel?.shutdown();
    final closed = await _server.close();
    if (closed) {
      _log.info('Server stopped');
    } else {
      _log.warning('Server stop failed');
    }
  }

  /// Handle Batch API
  /// https://github.com/git-lfs/git-lfs/blob/main/docs/api/batch.md.
  Future<Response> _batchHandler(Request request) async {
    final token = request.headers['Authorization'];
    if (token == null) {
      return Response.forbidden('Forbidden');
    }

    final form = AuthenticationForm()..token = token;
    final reply = await _authClient.verifyToken(form);

    if (!reply.success) {
      return Response.forbidden('Forbidden');
    }

    final path = reply.path;
    final expiresIn = reply.expiresIn;
    final Response response =
        _proceedBody(await request.readAsString(), path, expiresIn);

    return response;
  }

  /// Handle download operation.
  Future<Response> _downloadHandler(Request request, String oid) async {
    final token = request.headers['Authorization'];
    if (token == null) {
      return Response.forbidden('Forbidden');
    }

    final form = AuthenticationForm()..token = token;
    final reply = await _authClient.verifyToken(form);

    if (!reply.success) {
      return Response.forbidden('Forbidden');
    }
    final path = reply.path;

    final first = oid.substring(0, 2);
    final second = oid.substring(2, 4);
    final file = File('$path/lfs/objects/$first/$second/$oid');
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

  Response _proceedBody(String body, String path, int expiresIn) {
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
      final file = File('$path/lfs/objects/$first/$second/$oid');
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
            'expires_in': expiresIn,
            'href': 'https://$_hostname:$_port/download/$oid',
          },
        },
      });
    }

    final response = {
      'transfer': 'basic',
      'objects': responseObjects,
      'hash_algo': 'sha256'
    };

    return Response.ok(
      const JsonEncoder.withIndent(' ').convert(response),
      headers: {
        'Content-Type': 'application/vnd.git-lfs+json',
      },
    );
  }

  /// Validate JSON and produce response.
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
      // Only 'download' operation is supported.
      // TODO: Support 'upload'.
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
}
