///
//  Generated code. Do not modify.
//  source: authentication.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use registrationFormDescriptor instead')
const RegistrationForm$json = const {
  '1': 'RegistrationForm',
  '2': const [
    const {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    const {'1': 'operation', '3': 2, '4': 1, '5': 9, '10': 'operation'},
  ],
};

/// Descriptor for `RegistrationForm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationFormDescriptor = $convert.base64Decode('ChBSZWdpc3RyYXRpb25Gb3JtEhIKBHBhdGgYASABKAlSBHBhdGgSHAoJb3BlcmF0aW9uGAIgASgJUglvcGVyYXRpb24=');
@$core.Deprecated('Use registrationReplyDescriptor instead')
const RegistrationReply$json = const {
  '1': 'RegistrationReply',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.authentication.RegistrationReply.Status', '10': 'status'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': const [RegistrationReply_Status$json],
};

@$core.Deprecated('Use registrationReplyDescriptor instead')
const RegistrationReply_Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'SUCCESS', '2': 0},
    const {'1': 'ENOENT', '2': 2},
    const {'1': 'EIO', '2': 5},
    const {'1': 'EAGAIN', '2': 11},
    const {'1': 'EOPNOTSUPP', '2': 95},
  ],
};

/// Descriptor for `RegistrationReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationReplyDescriptor = $convert.base64Decode('ChFSZWdpc3RyYXRpb25SZXBseRJACgZzdGF0dXMYASABKA4yKC5hdXRoZW50aWNhdGlvbi5SZWdpc3RyYXRpb25SZXBseS5TdGF0dXNSBnN0YXR1cxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlIkYKBlN0YXR1cxILCgdTVUNDRVNTEAASCgoGRU5PRU5UEAISBwoDRUlPEAUSCgoGRUFHQUlOEAsSDgoKRU9QTk9UU1VQUBBf');
@$core.Deprecated('Use authenticationFormDescriptor instead')
const AuthenticationForm$json = const {
  '1': 'AuthenticationForm',
  '2': const [
    const {'1': 'token', '3': 1, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `AuthenticationForm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticationFormDescriptor = $convert.base64Decode('ChJBdXRoZW50aWNhdGlvbkZvcm0SFAoFdG9rZW4YASABKAlSBXRva2Vu');
@$core.Deprecated('Use authenticationReplyDescriptor instead')
const AuthenticationReply$json = const {
  '1': 'AuthenticationReply',
  '2': const [
    const {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    const {'1': 'path', '3': 2, '4': 1, '5': 9, '10': 'path'},
  ],
};

/// Descriptor for `AuthenticationReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticationReplyDescriptor = $convert.base64Decode('ChNBdXRoZW50aWNhdGlvblJlcGx5EhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSEgoEcGF0aBgCIAEoCVIEcGF0aA==');
