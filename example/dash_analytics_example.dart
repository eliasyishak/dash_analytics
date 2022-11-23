import 'dart:io';

import 'package:dash_analytics/dash_analytics.dart';

void main() async {
  DateTime start = DateTime.now();
  print('###### START ###### $start');
  String? home;
  Map<String, String> envVars = Platform.environment;

  if (Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (Platform.isLinux) {
    home = envVars['HOME'];
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'];
  }

  final Directory homeDirectory = Directory(home!);
  final int flutterToolsMessageVersion = 1;
  final String flutterToolsMessage = '''
The [tool name] uses Google Analytics to report usage and diagnostic data
along with package dependencies, and crash reporting to send basic crash
reports. This data is used to help improve the Dart platform, Flutter framework,
and related tools.

Telemetry is not sent on the very first run.
To disable reporting of telemetry, run this terminal command:

[dart|flutter] --disable-telemetry.
If you opt out of telemetry, an opt-out event will be sent, and then no further
information will be sent. This data is collected in accordance with the
Google Privacy Policy (https://policies.google.com/privacy).
''';
  final String tool = 'flutter-tools';

  final String measurementId = 'G-N1NXG28J5B';
  final String apiSecret = '4yT8__oER3Cd84dtx6r-_A';
  // TODO: look into filtering out requests coming into GA4 around conditionals
  //  found within the body of the request

  // Initialize the singleton + run the initializer to produce
  // the files for telemetry if they don't exist
  Analytics.setup(
    tool: tool,
    homeDirectory: homeDirectory,
    measurementId: measurementId,
    apiSecret: apiSecret,
    toolsMessageVersion: flutterToolsMessageVersion,
    toolsMessage: flutterToolsMessage,
    branch: 'ey-test-branch',
    flutterVersion: 'Flutter 3.6.0-7.0.pre.47',
    dartVersion: 'Dart 2.19.0',
  );

  DateTime end = DateTime.now();
  print(
      '###### DONE ###### ${DateTime.now()} ${end.difference(start).inMilliseconds}ms');
}
