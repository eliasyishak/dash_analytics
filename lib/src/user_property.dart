import 'dart:convert';

import 'package:clock/clock.dart';

import 'session.dart';

class UserProperty {
  final Session session;
  final String branch;
  final String host;
  final String flutterVersion;
  final String dartVersion;
  final String tool;

  /// This class is intended to capture all of the user's
  /// metadata when the class gets initialized as well as collecting
  /// session data to send in the json payload to Google Analytics
  UserProperty({
    required this.session,
    required this.branch,
    required this.host,
    required this.flutterVersion,
    required this.dartVersion,
    required this.tool,
  });

  /// This method will take the data in this class and convert it into
  /// a Map that is suitable for the POST request schema
  ///
  /// This will call the [Session] object's [getSessionId] method which will
  /// update the session file and get a new session id if necessary
  ///
  /// https://developers.google.com/analytics/devguides/collection/protocol/ga4/user-properties?client_type=gtag
  Map<String, Map<String, dynamic>> preparePayload() {
    return <String, Map<String, dynamic>>{
      for (MapEntry<String, dynamic> entry in _toMap().entries)
        entry.key: <String, dynamic>{'value': entry.value}
    };
  }

  @override
  String toString() {
    return jsonEncode(_toMap());
  }

  /// Convert the data stored in this class into a map while also
  /// getting the latest session id using the [Session] class
  Map<String, dynamic> _toMap() => <String, dynamic>{
        'session_id': session.getSessionId(),
        'branch': branch,
        'host': host,
        'flutter_version': flutterVersion,
        'dart_version': dartVersion,
        'tool': tool,
        'local_time': '${clock.now()}',
      };
}
