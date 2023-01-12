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

  /// Convert the data stored in this class into a map while also
  /// getting the latest session id using the [Session] class
  Map _toMap() {
    return {
      'session_id': session.getSessionId(),
      'branch': branch,
      'host': host,
      'flutter_version': flutterVersion,
      'dart_version': dartVersion,
      'tool': tool,
      'local_time': '${clock.now()}',
    };
  }

  /// This method will take the data in this class and convert it into
  /// a Map that is suitable for the POST request schema
  ///
  /// This will call the [Session] object's [getSessionId] method which will
  /// update the session file and get a new session id if necessary
  ///
  /// https://developers.google.com/analytics/devguides/collection/protocol/ga4/user-properties?client_type=gtag
  Map preparePayload() {
    return {
      for (MapEntry entry in _toMap().entries) entry.key: {'value': entry.value}
    };
  }

  @override
  String toString() {
    return jsonEncode(_toMap());
  }
}
