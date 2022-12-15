import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/local.dart';

import 'package:dash_analytics/dash_analytics.dart';

final FileSystem fs = LocalFileSystem();

final int flutterToolsMessageVersion = 1;
final String flutterToolsMessage = '''
Dash related tooling uses Google Analytics to report usage and diagnostic data
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

// TODO: look into filtering out requests coming into GA4 around conditionals
//  found within the body of the request
final String measurementId = 'G-N1NXG28J5B';
final String apiSecret = '4yT8__oER3Cd84dtx6r-_A';

Directory getHomeDirectory() {
  String? home;
  Map<String, String> envVars = io.Platform.environment;

  if (io.Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (io.Platform.isLinux) {
    home = envVars['HOME'];
  } else if (io.Platform.isWindows) {
    home = envVars['UserProfile'];
  }

  return fs.directory(home!);
}

// Globally instantiate the analytics class at the entry
// point of the tool
final Analytics analytics = Analytics(
  tool: tool,
  homeDirectory: getHomeDirectory(),
  measurementId: measurementId,
  apiSecret:
      apiSecret, // TODO: determine if this can live within the package or remain passed in
  toolsMessageVersion: flutterToolsMessageVersion,
  toolsMessage: flutterToolsMessage,
  branch: 'ey-test-branch',
  flutterVersion: 'Flutter 3.6.0-7.0.pre.47',
  dartVersion: 'Dart 2.19.0',
);

void main() async {
  DateTime start = DateTime.now();
  print('###### START ###### $start');

  print(analytics.telemetryEnabled);

  DateTime end = DateTime.now();
  print(
      '###### DONE ###### ${DateTime.now()} ${end.difference(start).inMilliseconds}ms');
}
