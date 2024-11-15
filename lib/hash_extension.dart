// We use .copywith() like methods
// _extension.dart is where we create the extension method

import 'dart:convert';

import 'package:crypto/crypto.dart';

// Add hash functionality to our String id
extension HashStringExtension on String {
  // Returns the SHA256 hash of this String
  String get hashValue {
    return sha256.convert(utf8.encode(this)).toString();
  }
}
