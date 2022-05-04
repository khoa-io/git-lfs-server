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
  static final _$generateToken =
      $grpc.ClientMethod<$0.RegistrationForm, $0.RegistrationReply>(
          '/authentication.Authentication/GenerateToken',
          ($0.RegistrationForm value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.RegistrationReply.fromBuffer(value));
  static final _$verifyToken =
      $grpc.ClientMethod<$0.AuthenticationForm, $0.AuthenticationReply>(
          '/authentication.Authentication/VerifyToken',
          ($0.AuthenticationForm value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.AuthenticationReply.fromBuffer(value));

  AuthenticationClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.RegistrationReply> generateToken(
      $0.RegistrationForm request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$generateToken, request, options: options);
  }

  $grpc.ResponseFuture<$0.AuthenticationReply> verifyToken(
      $0.AuthenticationForm request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$verifyToken, request, options: options);
  }
}

abstract class AuthenticationServiceBase extends $grpc.Service {
  $core.String get $name => 'authentication.Authentication';

  AuthenticationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RegistrationForm, $0.RegistrationReply>(
        'GenerateToken',
        generateToken_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RegistrationForm.fromBuffer(value),
        ($0.RegistrationReply value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AuthenticationForm, $0.AuthenticationReply>(
            'VerifyToken',
            verifyToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AuthenticationForm.fromBuffer(value),
            ($0.AuthenticationReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegistrationReply> generateToken_Pre($grpc.ServiceCall call,
      $async.Future<$0.RegistrationForm> request) async {
    return generateToken(call, await request);
  }

  $async.Future<$0.AuthenticationReply> verifyToken_Pre($grpc.ServiceCall call,
      $async.Future<$0.AuthenticationForm> request) async {
    return verifyToken(call, await request);
  }

  $async.Future<$0.RegistrationReply> generateToken(
      $grpc.ServiceCall call, $0.RegistrationForm request);
  $async.Future<$0.AuthenticationReply> verifyToken(
      $grpc.ServiceCall call, $0.AuthenticationForm request);
}
