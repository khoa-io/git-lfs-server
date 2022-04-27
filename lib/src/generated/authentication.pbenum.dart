///
//  Generated code. Do not modify.
//  source: authentication.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class AuthenticationResponse_Status extends $pb.ProtobufEnum {
  static const AuthenticationResponse_Status SUCCESS = AuthenticationResponse_Status._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SUCCESS');
  static const AuthenticationResponse_Status ENOENT = AuthenticationResponse_Status._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ENOENT');
  static const AuthenticationResponse_Status EIO = AuthenticationResponse_Status._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EIO');
  static const AuthenticationResponse_Status EAGAIN = AuthenticationResponse_Status._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EAGAIN');
  static const AuthenticationResponse_Status EOPNOTSUPP = AuthenticationResponse_Status._(95, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EOPNOTSUPP');

  static const $core.List<AuthenticationResponse_Status> values = <AuthenticationResponse_Status> [
    SUCCESS,
    ENOENT,
    EIO,
    EAGAIN,
    EOPNOTSUPP,
  ];

  static final $core.Map<$core.int, AuthenticationResponse_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AuthenticationResponse_Status? valueOf($core.int value) => _byValue[value];

  const AuthenticationResponse_Status._($core.int v, $core.String n) : super(v, n);
}

