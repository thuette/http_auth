// Copyright (c) 2018, Marco Esposito (marcoesposito1988@gmail.com).
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Http client holding a username and password to be used for Basic authentication
class BasicAuthClient extends http.BaseClient {
  /// The username to be used for all requests
  final String username;

  /// The password to be used for all requests
  final String password;

  final http.Client _inner;
  final String _authString;

  /// Creates a client wrapping [inner] that uses Basic HTTP auth.
  ///
  /// Constructs a new [BasicAuthClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  BasicAuthClient(this.username, this.password, {inner})
      : _authString = _getAuthString(username, password),
        _inner = inner == null ? new http.Client() : inner;

  static String _getAuthString(username, password) {
    final token = base64.encode(latin1.encode('${username}:${password}'));

    final authstr = 'Basic ' + token.trim();

    return authstr;
  }

  _setAuthString(http.BaseRequest request) {
    request.headers['Authorization'] = _authString;
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _setAuthString(request);

    return _inner.send(request);
  }
}
