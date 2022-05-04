///
//  Generated code. Do not modify.
//  source: authentication.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class RegistrationReply_Status extends $pb.ProtobufEnum {
  static const RegistrationReply_Status SUCCESS = RegistrationReply_Status._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SUCCESS');
  static const RegistrationReply_Status ENOENT = RegistrationReply_Status._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ENOENT');
  static const RegistrationReply_Status EIO = RegistrationReply_Status._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EIO');
  static const RegistrationReply_Status EAGAIN = RegistrationReply_Status._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EAGAIN');
  static const RegistrationReply_Status EOPNOTSUPP = RegistrationReply_Status._(95, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'EOPNOTSUPP');

  static const $core.List<RegistrationReply_Status> values = <RegistrationReply_Status> [
    SUCCESS,
    ENOENT,
    EIO,
    EAGAIN,
    EOPNOTSUPP,
  ];

  static final $core.Map<$core.int, RegistrationReply_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RegistrationReply_Status? valueOf($core.int value) => _byValue[value];

  const RegistrationReply_Status._($core.int v, $core.String n) : super(v, n);
}

