///
//  Generated code. Do not modify.
//  source: authentication.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'authentication.pb.dart' as $0;
export 'authentication.pb.dart';

class AuthenticationClient extends $grpc.Client {
  static final _$authenticate =
      $grpc.ClientMethod<$0.AuthenticationRequest, $0.AuthenticationResponse>(
          '/authentication.Authentication/Authenticate',
          ($0.AuthenticationRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AuthenticationResponse.fromBuffer(value));

  AuthenticationClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.AuthenticationResponse> authenticate(
      $0.AuthenticationRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$authenticate, request, options: options);
  }
}

abstract class AuthenticationServiceBase extends $grpc.Service {
  $core.String get $name => 'authentication.Authentication';

  AuthenticationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuthenticationRequest,
            $0.AuthenticationResponse>(
        'Authenticate',
        authenticate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AuthenticationRequest.fromBuffer(value),
        ($0.AuthenticationResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthenticationResponse> authenticate_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.AuthenticationRequest> request) async {
    return authenticate(call, await request);
  }

  $async.Future<$0.AuthenticationResponse> authenticate(
      $grpc.ServiceCall call, $0.AuthenticationRequest request);
}
