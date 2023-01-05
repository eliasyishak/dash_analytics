import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

import 'package:dash_analytics/dash_analytics.dart';
import 'package:dash_analytics/src/config_handler.dart';

void main() {
  late FileSystem fs;
  late Directory home;
  late Directory dartToolDirectory;
  late Analytics analytics;

  const String initialToolName = 'initialTool';
  const String secondTool = 'newTool';
  const String measurementId = 'measurementId';
  const String apiSecret = 'apiSecret';
  const int toolsMessageVersion = 1;
  const String toolsMessage = 'toolsMessage';
  const String branch = 'branch';
  const String flutterVersion = 'flutterVersion';
  const String dartVersion = 'dartVersion';

  setUp(() {
    // Setup the filesystem with the home directory
    fs = MemoryFileSystem.test();
    home = fs.directory('home');
    dartToolDirectory = home.childDirectory('.dart-tool');

    analytics = Analytics.test(
      tool: initialToolName,
      homeDirectory: home,
      measurementId: measurementId,
      apiSecret: apiSecret,
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
      branch: branch,
      flutterVersion: flutterVersion,
      dartVersion: dartVersion,
      fs: fs,
    );
  });

  tearDown(() {
    dartToolDirectory.deleteSync(recursive: true);
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

  test('New tool is successfully added to config file', () {
    // Create a new instance of the analytics class with the new tool
    final Analytics secondAnalytics = Analytics.test(
      tool: secondTool,
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

    // Access the config handler specifically to check adding a tool was
    // was successful, this class will not be available for importing however
    final ConfigHandler configHandler =
        ConfigHandler(fs: fs, homeDirectory: home);

    expect(configHandler.parsedTools.length, equals(2),
        reason: 'There should be only 2 tools that have '
            'been parsed into the config file');
    expect(configHandler.parsedTools.containsKey(initialToolName), true,
        reason: 'The first tool: $initialToolName should be in the map');
    expect(configHandler.parsedTools.containsKey(secondTool), true,
        reason: 'The second tool: $secondAnalytics should be in the map');
  });

  test('Toggling telemetry boolean through Analytics class api', () {
    expect(analytics.telemetryEnabled, true,
        reason: 'Telemetry should be enabled by default '
            'when initialized for the first time');

    // Use the API to disable analytics
    analytics.setTelemetry(false);
    expect(analytics.telemetryEnabled, false,
        reason: 'Analytics telemetry should be disabled');

    // Toggle it back to being enabled
    analytics.setTelemetry(true);
    expect(analytics.telemetryEnabled, true,
        reason: 'Analytics telemetry should be enabled');
  });

  test(
      'Telemetry has been disabled by one '
      'tool and second tool correctly shows telemetry is disabled', () {
    expect(analytics.telemetryEnabled, true,
        reason: 'Analytics telemetry should be enabled on initialization');
    // Use the API to disable analytics
    analytics.setTelemetry(false);
    expect(analytics.telemetryEnabled, false,
        reason: 'Analytics telemetry should be disabled');

    // Initialize a second analytics class, which simulates a second tool
    // Create a new instance of the analytics class with the new tool
    final Analytics secondAnalytics = Analytics.test(
      tool: secondTool,
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

    expect(secondAnalytics.telemetryEnabled, false,
        reason: 'Analytics telemetry should be disabled by the first class '
            'and the second class should show telemetry is disabled');
  });

  test(
      'Two concurrent instances are running '
      'and reflect an accurate up to date telemetry status', () {
    // Initialize a second analytics class, which simulates a second tool
    final Analytics secondAnalytics = Analytics.test(
      tool: secondTool,
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

    expect(analytics.telemetryEnabled, true,
        reason: 'Telemetry should be enabled on initialization for '
            'first analytics instance');
    expect(secondAnalytics.telemetryEnabled, true,
        reason: 'Telemetry should be enabled on initialization for '
            'second analytics instance');

    // Use the API to disable analytics on the first instance
    analytics.setTelemetry(false);
    expect(analytics.telemetryEnabled, false,
        reason: 'Analytics telemetry should be disabled on first instance');

    expect(secondAnalytics.telemetryEnabled, false,
        reason: 'Analytics telemetry should be disabled by the first class '
            'and the second class should show telemetry is disabled'
            ' by checking the timestamp on the config file');
  });

  test('New line character is added if missing', () {
    String currentConfigFileString;

    // Access the config handler directly to remove the trailing
    // new line character
    final ConfigHandler configHandler =
        ConfigHandler(fs: fs, homeDirectory: home);

    expect(configHandler.configFile.readAsStringSync().endsWith('\n'), true,
        reason: 'When initialized, the tool should correctly '
            'add a trailing new line character');

    // Remove the trailing new line character before initializing a second
    // analytics class; the new class should correctly format the config file
    currentConfigFileString = configHandler.configFile.readAsStringSync();
    currentConfigFileString = currentConfigFileString.substring(
        0, currentConfigFileString.length - 1);

    // Write back out to the config file to be processed again
    configHandler.configFile.writeAsStringSync(currentConfigFileString);

    expect(configHandler.configFile.readAsStringSync().endsWith('\n'), false,
        reason: 'The trailing new line should be missing');

    // Initialize a second analytics class, which simulates a second tool
    // which should correct the missing trailing new line character
    final Analytics secondAnalytics = Analytics.test(
      tool: secondTool,
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
    expect(secondAnalytics.telemetryEnabled, true);

    expect(configHandler.configFile.readAsStringSync().endsWith('\n'), true,
        reason: 'The second analytics class will correct '
            'the missing new line character');
  });
}
