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
  /// "client_id": "x",
  /// "events": [
  ///   {
  ///     "name": "offline_purchase",
  ///     "params": {
  ///       "engagement_time_msec": "100",
  ///       "session_id": "123"
  ///     }
  ///   }
  /// ]
  /// }
  ///
  /// https://developers.google.com/analytics/devguides/collection/protocol/ga4/sending-events?client_type=gtag
  /// ```
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
