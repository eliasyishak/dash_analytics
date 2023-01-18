// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'constants.dart';

class GAClient {
  final String measurementId;
  final String apiSecret;
  final String postUrl;
  final http.Client _client;

  GAClient({
    required this.measurementId,
    required this.apiSecret,
  })  : postUrl =
            '$kAnalyticsUrl?measurement_id=$measurementId&api_secret=$apiSecret',
        _client = http.Client();

  /// Closes the http client's connection to prevent lingering requests
  void close() => _client.close();

  /// Receive the payload in Map form and parse
  /// into JSON to send to GA
  ///
  /// Follows the following schema
  ///
  /// ```
  /// {
  ///   "client_id": "46cc0ba6-f604-4fd9-aa2f-8a20beb24cd4",
  ///   "events": [{ "name": "testing_from_dash", "params": { "time_ns": 345 } }],
  ///   "user_properties": {
  ///     "session_id": { "value": 1673466750423 },
  ///     "branch": { "value": "ey-test-branch" },
  ///     "host": { "value": "macos" },
  ///     "flutter_version": { "value": "Flutter 3.6.0-7.0.pre.47" },
  ///     "dart_version": { "value": "Dart 2.19.0" },
  ///     "tool": { "value": "flutter-tools" },
  ///     "local_time": { "value": "2023-01-11 14:53:31.471816" }
  ///   }
  /// }
  /// ```
  /// https://developers.google.com/analytics/devguides/collection/protocol/ga4/sending-events?client_type=gtag
  Future<http.Response> sendData(Map<String, dynamic> body) {
    return _client.post(
      Uri.parse(postUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
  }
}
