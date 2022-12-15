import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

import 'package:dash_analytics/dash_analytics.dart';

void main() {
  late FileSystem fs;
  late Directory home;
  late Directory dartToolDirectory;
  late Analytics analytics;

  setUp(() {
    // Setup the filesystem with the home directory
    fs = MemoryFileSystem();
    home = fs.directory('home');
    dartToolDirectory = home.childDirectory('.dart-tool');

    analytics = Analytics.test(
      tool: 'tool',
      homeDirectory: home,
      measurementId: 'measurementId',
      apiSecret: 'apiSecret',
      toolsMessageVersion: 1,
      toolsMessage: 'flutterToolsMessage',
      branch: 'ey-test-branch',
      flutterVersion: 'Flutter 3.6.0-7.0.pre.47',
      dartVersion: 'Dart 2.19.0',
      fs: fs,
    );
  });

  test('Initializer properly sets up on first run', () {
    // The 3 files that should have been generated
    final File clientIdFile =
        home.childDirectory('.dart-tool').childFile('CLIENT_ID');
    final File sessionFile =
        home.childDirectory('.dart-tool').childFile('session.json');
    final File configFile = home
        .childDirectory('.dart-tool')
        .childFile('dart-flutter-telemetry.config');

    expect(clientIdFile.existsSync(), true,
        reason: 'The CLIENT_ID file was not found');
    expect(sessionFile.existsSync(), true,
        reason: 'The session.json file was not found');
    expect(configFile.existsSync(), true,
        reason: 'The dart-flutter-telemetry.config was not found');
    expect(dartToolDirectory.listSync().length, equals(3),
        reason: 'There should only be 3 files in the .dart-tool directory');
    expect(analytics.shouldShowMessage, true,
        reason: 'For the first run, analytics should default to being enabled');
  });
}
