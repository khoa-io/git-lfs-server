///
//  Generated code. Do not modify.
//  source: authentication.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use authenticationRequestDescriptor instead')
const AuthenticationRequest$json = const {
  '1': 'AuthenticationRequest',
  '2': const [
    const {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    const {'1': 'operation', '3': 2, '4': 1, '5': 9, '10': 'operation'},
  ],
};

/// Descriptor for `AuthenticationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticationRequestDescriptor = $convert.base64Decode('ChVBdXRoZW50aWNhdGlvblJlcXVlc3QSEgoEcGF0aBgBIAEoCVIEcGF0aBIcCglvcGVyYXRpb24YAiABKAlSCW9wZXJhdGlvbg==');
@$core.Deprecated('Use authenticationResponseDescriptor instead')
const AuthenticationResponse$json = const {
  '1': 'AuthenticationResponse',
  '2': const [
    const {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.authentication.AuthenticationResponse.Status', '10': 'status'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': const [AuthenticationResponse_Status$json],
};

@$core.Deprecated('Use authenticationResponseDescriptor instead')
const AuthenticationResponse_Status$json = const {
  '1': 'Status',
  '2': const [
    const {'1': 'SUCCESS', '2': 0},
    const {'1': 'ENOENT', '2': 2},
    const {'1': 'EIO', '2': 5},
    const {'1': 'EAGAIN', '2': 11},
    const {'1': 'EOPNOTSUPP', '2': 95},
  ],
};

/// Descriptor for `AuthenticationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticationResponseDescriptor = $convert.base64Decode('ChZBdXRoZW50aWNhdGlvblJlc3BvbnNlEkUKBnN0YXR1cxgBIAEoDjItLmF1dGhlbnRpY2F0aW9uLkF1dGhlbnRpY2F0aW9uUmVzcG9uc2UuU3RhdHVzUgZzdGF0dXMSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZSJGCgZTdGF0dXMSCwoHU1VDQ0VTUxAAEgoKBkVOT0VOVBACEgcKA0VJTxAFEgoKBkVBR0FJThALEg4KCkVPUE5PVFNVUFAQXw==');
