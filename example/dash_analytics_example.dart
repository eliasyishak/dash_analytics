import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/local.dart';

import 'package:dash_analytics/dash_analytics.dart';
import 'package:dash_analytics/src/enums.dart';

final FileSystem fs = LocalFileSystem();

final String tool = 'flutter-tools';

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
  apiSecret: apiSecret,
  branch: 'ey-test-branch',
  flutterVersion: 'Flutter 3.6.0-7.0.pre.47',
  dartVersion: 'Dart 2.19.0',
  platform: DevicePlatforms.macos,
);

void main() async {
  DateTime start = DateTime.now();
  print('###### START ###### $start');

  print(analytics.telemetryEnabled);
  analytics.sendEvent(
    eventName: DashEvents.hotReloadTime,
    eventData: {'time_ns': 345},
  );
  analytics.close();

  DateTime end = DateTime.now();
  print(
      '###### DONE ###### ${DateTime.now()} ${end.difference(start).inMilliseconds}ms');
}
