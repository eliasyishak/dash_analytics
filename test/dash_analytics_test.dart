import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

import 'package:dash_analytics/dash_analytics.dart';
import 'package:dash_analytics/src/config_handler.dart';
import 'package:dash_analytics/src/constants.dart';

void main() {
  late FileSystem fs;
  late Directory home;
  late Directory dartToolDirectory;
  late Analytics analytics;
  late File clientIdFile;
  late File sessionFile;
  late File configFile;

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
      branch: branch,
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
      flutterVersion: flutterVersion,
      dartVersion: dartVersion,
      fs: fs,
    );

    // The 3 files that should have been generated
    clientIdFile = home.childDirectory('.dart-tool').childFile('CLIENT_ID');
    sessionFile = home.childDirectory('.dart-tool').childFile('session.json');
    configFile = home
        .childDirectory('.dart-tool')
        .childFile('dart-flutter-telemetry.config');
  });

  tearDown(() {
    dartToolDirectory.deleteSync(recursive: true);
  });

  test('Initializer properly sets up on first run', () {
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
      branch: 'ey-test-branch',
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
      flutterVersion: 'Flutter 3.6.0-7.0.pre.47',
      dartVersion: 'Dart 2.19.0',
      fs: fs,
    );

    expect(secondAnalytics.parsedTools.length, equals(2),
        reason: 'There should be only 2 tools that have '
            'been parsed into the config file');
    expect(secondAnalytics.parsedTools.containsKey(initialToolName), true,
        reason: 'The first tool: $initialToolName should be in the map');
    expect(secondAnalytics.parsedTools.containsKey(secondTool), true,
        reason: 'The second tool: $secondAnalytics should be in the map');
    expect(configFile.readAsStringSync().startsWith(kConfigString), true,
        reason:
            'The config file should have the same message from the constants file');
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
      branch: 'ey-test-branch',
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
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
      branch: 'ey-test-branch',
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
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

    expect(configFile.readAsStringSync().endsWith('\n'), true,
        reason: 'When initialized, the tool should correctly '
            'add a trailing new line character');

    // Remove the trailing new line character before initializing a second
    // analytics class; the new class should correctly format the config file
    currentConfigFileString = configFile.readAsStringSync();
    currentConfigFileString = currentConfigFileString.substring(
        0, currentConfigFileString.length - 1);

    // Write back out to the config file to be processed again
    configFile.writeAsStringSync(currentConfigFileString);

    expect(configFile.readAsStringSync().endsWith('\n'), false,
        reason: 'The trailing new line should be missing');

    // Initialize a second analytics class, which simulates a second tool
    // which should correct the missing trailing new line character
    final Analytics secondAnalytics = Analytics.test(
      tool: secondTool,
      homeDirectory: home,
      measurementId: 'measurementId',
      apiSecret: 'apiSecret',
      branch: 'ey-test-branch',
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
      flutterVersion: 'Flutter 3.6.0-7.0.pre.47',
      dartVersion: 'Dart 2.19.0',
      fs: fs,
    );
    expect(secondAnalytics.telemetryEnabled, true);

    expect(configFile.readAsStringSync().endsWith('\n'), true,
        reason: 'The second analytics class will correct '
            'the missing new line character');
  });

  test('Incrementing the version for a tool is successful', () {
    expect(analytics.parsedTools[initialToolName]?.versionNumber,
        toolsMessageVersion,
        reason: 'On initialization, the first version number should '
            'be what is set in the setup method');

    // Initialize a second analytics class for the same tool as
    // the first analytics instance except with a newer version for
    // the tools message and version
    final Analytics secondAnalytics = Analytics.test(
      tool: initialToolName,
      homeDirectory: home,
      measurementId: measurementId,
      apiSecret: apiSecret,
      branch: branch,
      toolsMessageVersion: toolsMessageVersion + 1,
      toolsMessage: toolsMessage,
      flutterVersion: flutterVersion,
      dartVersion: dartVersion,
      fs: fs,
    );

    expect(secondAnalytics.parsedTools[initialToolName]?.versionNumber,
        toolsMessageVersion + 1,
        reason:
            'The second analytics instance should have incremented the version');
  });

  test(
      'Config file resets when there is not exactly one match for the reporting flag',
      () {
    // Write to the config file a string that is not formatted correctly
    // (ie. there is more than one match for the reporting flag)
    configFile.writeAsStringSync('''
# INTRODUCTION
#
# This is the Flutter and Dart telemetry reporting
# configuration file.
#
# Lines starting with a #" are documentation that
# the tools maintain automatically.
#
# All other lines are configuration lines. They have
# the form "name=value". If multiple lines contain
# the same configuration name with different values,
# the parser will default to a conservative value. 

# DISABLING TELEMETRY REPORTING
#
# To disable telemetry reporting, set "reporting" to
# the value "0" and to enable, set to "1":
reporting=1
reporting=1

# NOTIFICATIONS
#
# Each tool records when it last informed the user about
# analytics reporting and the privacy policy.
#
# The following tools have so far read this file:
#
#   dart-tools (Dart CLI developer tool)
#   devtools (DevTools debugging and performance tools)
#   flutter-tools (Flutter CLI developer tool)
#
# For each one, the file may contain a configuration line
# where the name is the code in the list above, e.g. "dart-tool",
# and the value is a date in the form YYYY-MM-DD, a comma, and
# a number representing the version of the message that was
# displayed.''');

    // Disable telemetry which should result in a reset of the config file
    analytics.setTelemetry(false);

    expect(configFile.readAsStringSync().startsWith(kConfigString), true,
        reason: 'The tool should have reset the config file '
            'because it was not formatted correctly');
  });

  test('Config file resets when there is not exactly one match for the tool',
      () {
    // Write to the config file a string that is not formatted correctly
    // (ie. there is more than one match for the reporting flag)
    configFile.writeAsStringSync('''
# INTRODUCTION
#
# This is the Flutter and Dart telemetry reporting
# configuration file.
#
# Lines starting with a #" are documentation that
# the tools maintain automatically.
#
# All other lines are configuration lines. They have
# the form "name=value". If multiple lines contain
# the same configuration name with different values,
# the parser will default to a conservative value. 

# DISABLING TELEMETRY REPORTING
#
# To disable telemetry reporting, set "reporting" to
# the value "0" and to enable, set to "1":
reporting=1

# NOTIFICATIONS
#
# Each tool records when it last informed the user about
# analytics reporting and the privacy policy.
#
# The following tools have so far read this file:
#
#   dart-tools (Dart CLI developer tool)
#   devtools (DevTools debugging and performance tools)
#   flutter-tools (Flutter CLI developer tool)
#
# For each one, the file may contain a configuration line
# where the name is the code in the list above, e.g. "dart-tool",
# and the value is a date in the form YYYY-MM-DD, a comma, and
# a number representing the version of the message that was
# displayed.
$initialToolName=${ConfigHandler.dateStamp},$toolsMessageVersion
$initialToolName=${ConfigHandler.dateStamp},$toolsMessageVersion
''');

    // Initialize a second analytics class for the same tool as
    // the first analytics instance except with a newer version for
    // the tools message and version
    //
    // This second instance should reset the config file when it goes
    // to increment the version in the file
    final Analytics secondAnalytics = Analytics.test(
      tool: initialToolName,
      homeDirectory: home,
      measurementId: measurementId,
      apiSecret: apiSecret,
      branch: branch,
      toolsMessageVersion: toolsMessageVersion + 1,
      toolsMessage: toolsMessage,
      flutterVersion: flutterVersion,
      dartVersion: dartVersion,
      fs: fs,
    );

    expect(
      configFile.readAsStringSync().endsWith(
          '# displayed.\n$initialToolName=${ConfigHandler.dateStamp},${toolsMessageVersion + 1}\n'),
      true,
      reason: 'The config file ends with the correctly formatted ending '
          'after removing the duplicate lines for a given tool',
    );
    expect(
      secondAnalytics.parsedTools[initialToolName]?.versionNumber,
      toolsMessageVersion + 1,
      reason: 'The new version should have been incremented',
    );
  });
}
