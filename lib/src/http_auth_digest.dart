// Copyright (c) 2018, Marco Esposito (marcoesposito1988@gmail.com).
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:async';
import 'package:http/http.dart' as http;
import 'http_auth_utils.dart' as utils;

/// Http client holding a username and password to be used for Digest authentication
class DigestAuthClient extends http.BaseClient {
  final http.Client _inner;

  final utils.DigestAuth _auth;

  /// Creates a client wrapping [inner] that uses Basic HTTP auth.
  ///
  /// Constructs a new [BasicAuthClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  DigestAuthClient(String username, String password, {inner})
      : _auth = new utils.DigestAuth(username, password),
        _inner = inner == null ? new http.Client() : inner;

  _setAuthString(http.BaseRequest request) {
    request.headers['Authorization'] =
        _auth.getAuthString(request.method, request.url);
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // after the first request we can provide Auth info
    if (_auth.isReady()) {
      _setAuthString(request);
      return _inner.send(request);
    }

    final response = await _inner.send(request);

    if (response.statusCode == 401) {
      final newRequest = utils.copyRequest(request);
      final String authInfo = response.headers['www-authenticate'];
      _auth.initFromAuthorizationHeader(authInfo);

      _setAuthString(newRequest);

      return _inner.send(newRequest);
    }

    // we should reach this point only with errors other than 401
    return response;
  }
}
