import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';

import 'config_handler.dart';
import 'constants.dart';
import 'initializer.dart';

abstract class Analytics {
  /// The default factory constructor that will return an implementation
  /// of the [Analytics] abstract class using the [LocalFileSystem]
  factory Analytics({
    required String tool,
    required Directory homeDirectory,
    required String measurementId,
    required String apiSecret,
    required String branch,
    required String flutterVersion,
    required String dartVersion,
  }) =>
      AnalyticsImpl(
        tool: tool,
        homeDirectory: homeDirectory,
        measurementId: measurementId,
        apiSecret: apiSecret,
        branch: branch,
        flutterVersion: flutterVersion,
        dartVersion: dartVersion,
        toolsMessage: kToolsMessage,
        toolsMessageVersion: kToolsMessageVersion,
        fs: LocalFileSystem(),
      );

  /// Factory constructor to return the [AnalyticsImpl] class with a
  /// [MemoryFileSystem] to use for testing
  factory Analytics.test({
    required String tool,
    required Directory homeDirectory,
    required String measurementId,
    required String apiSecret,
    required String branch,
    required String flutterVersion,
    required String dartVersion,
    required int toolsMessageVersion,
    required String toolsMessage,
    required FileSystem fs,
  }) =>
      AnalyticsImpl(
        tool: tool,
        homeDirectory: homeDirectory,
        measurementId: measurementId,
        apiSecret: apiSecret,
        branch: branch,
        toolsMessageVersion: toolsMessageVersion,
        toolsMessage: toolsMessage,
        flutterVersion: flutterVersion,
        dartVersion: dartVersion,
        fs: fs,
      );

  /// Returns a map object with all of the tools that have been parsed
  /// out of the configuration file
  Map<String, ToolInfo> get parsedTools;

  /// Boolean that lets the client know if they should display the message
  bool get shouldShowMessage;

  /// Boolean indicating whether or not telemetry is enabled
  bool get telemetryEnabled;

  /// Returns the message that should be displayed to the users if
  /// [shouldShowMessage] returns true
  String get toolsMessage;

  /// Pass a boolean to either enable or disable telemetry and make
  /// the necessary changes in the persisted configuration file
  void setTelemetry(bool reportingBool);
}

class AnalyticsImpl implements Analytics {
  final FileSystem fs;
  late ConfigHandler _configHandler;
  late bool _showMessage;

  @override
  final String toolsMessage;

  AnalyticsImpl({
    required String tool,
    required Directory homeDirectory,
    required String measurementId,
    required String apiSecret,
    required String branch,
    required String flutterVersion,
    required String dartVersion,
    required this.toolsMessage,
    required int toolsMessageVersion,
    required this.fs,
  }) {
    // This initializer class will let the instance know
    // if it was the first run; if it is, nothing will be sent
    // on the first run
    final Initializer initializer = Initializer(
      fs: fs,
      tool: tool,
      homeDirectory: homeDirectory,
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
    );
    initializer.run();
    _showMessage = initializer.firstRun;

    // Create the config handler that will parse the config file
    _configHandler = ConfigHandler(
      fs: fs,
      homeDirectory: homeDirectory,
      initializer: initializer,
    );

    // Initialize the config handler class and check if the
    // tool message and version have been updated from what
    // is in the current file; if there is a new message version
    // make the necessary updates
    if (!_configHandler.parsedTools.containsKey(tool)) {
      _configHandler.addTool(tool: tool);
      _showMessage = true;
    }
    if (_configHandler.parsedTools[tool]!.versionNumber < toolsMessageVersion) {
      _configHandler.incrementToolVersion(tool: tool);
      _showMessage = true;
    }
  }

  @override
  Map<String, ToolInfo> get parsedTools => _configHandler.parsedTools;

  @override
  bool get shouldShowMessage => _showMessage;

  @override
  bool get telemetryEnabled => _configHandler.telemetryEnabled;

  @override
  void setTelemetry(bool reportingBool) {
    _configHandler.setTelemetry(reportingBool);
  }
}
