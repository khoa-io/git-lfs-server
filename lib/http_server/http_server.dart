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
  final tag = 'git-lfs-http-server';
  late final Logger _log;

  late final ClientChannel? _channel;
  late final AuthenticationClient _authClient;

  /// Router instance to handler requests.
  ///
  /// - `/objects/batch`: https://github.com/git-lfs/git-lfs/blob/main/docs/api/batch.md.
  /// - `/download/{TOKEN}/{OID}`: download the object has checksum `{OID}` (SHA256).
  late final shelf_router.Router _router;

  final String _hostname;
  final int _port;
  final SecurityContext _context;
  late final HttpServer _server;

  GitLfsHttpServer(this._hostname, this._port, this._context);

  Future<void> start() async {
    _log = Logger(tag);
    Logger.root.level = Level.ALL;
    _router = shelf_router.Router()
      ..post('/objects/batch', _batchHandler)
      ..get('/download/<[a-zA-Z0-9]{25}>/<[a-zA-Z0-9]{64}>', _downloadHandler);

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
    await _server.close();
    _log.info('Server stopped');
  }

  /// Return `(token, path, expiresIn)` when authentication is successful.
  /// Otherwise, return a forbidden response.
  dynamic _authenticate(Request request) async {
    final authorization = request.headers['Authorization'];
    if (authorization == null || authorization.isEmpty) {
      _log.fine('No token provided');
      return Response.forbidden('Forbidden');
    }

    if (!authorization.startsWith('Basic') &&
        !authorization.startsWith('RemoteAuth')) {
      _log.fine('Invalid authentication scheme');
      return Response.forbidden('Forbidden');
    }

    final token = authorization.split(' ')[1];
    final form = AuthenticationForm()..token = token;
    final reply = await _authClient.verifyToken(form);

    if (!reply.success) {
      _log.fine('Token verification failed');
      return Response.forbidden('Forbidden');
    }

    _log.fine('${reply.path} will expire in ${reply.expiresIn} seconds');
    return Tuple3(token, reply.path, reply.expiresIn);
  }

  /// Handle Batch API
  /// https://github.com/git-lfs/git-lfs/blob/main/docs/api/batch.md.
  Future<Response> _batchHandler(Request request) async {
    final result = await _authenticate(request);
    if (result is Response) {
      return result;
    }

    final token = (result as Tuple3<String, String, int>).item1;
    final path = (result).item2;
    final expiresIn = (result).item3;
    final Response response =
        _proceedBody(await request.readAsString(), token, path, expiresIn);

    return response;
  }

  /// Handle download operation.
  Future<Response> _downloadHandler(
      Request request, String token, String oid) async {
    final form = AuthenticationForm()..token = token;
    final reply = await _authClient.verifyToken(form);

    if (!reply.success) {
      _log.fine('Token verification failed');
      return Response.forbidden('Forbidden');
    }

    _log.fine('$oid will expire in ${reply.expiresIn} seconds');

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

  Response _proceedBody(String body, String token, String path, int expiresIn) {
    final json = jsonDecode(body);
    final result = _validateJson(json);
    if (result is Response) {
      return result;
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
            'href': 'https://$_hostname:$_port/download/$token/$oid',
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
  /// Returns `true` if JSON is valid, a `Response` otherwise.
  dynamic _validateJson(dynamic json) {
    if (json is! Map) {
      return Response.badRequest(body: 'Invalid JSON');
    }

    if (!json.containsKey('operation')) {
      return Response.badRequest(body: 'Missing operation');
    }

    if (json['operation'] != Operation.download.name) {
      // Only 'download' operation is supported.
      return Response.badRequest(body: 'Invalid operation');
    }

    if (!json.containsKey('objects')) {
      return Response.badRequest(body: 'Missing objects');
    }

    final objects = json['objects'] as List;
    for (final object in objects) {
      if (!object.containsKey('oid')) {
        return Response.badRequest(body: 'Missing oid');
      }
      if (!object.containsKey('size')) {
        return Response.badRequest(body: 'Missing size');
      }
    }

    return true;
  }
}
