import 'package:file/file.dart';
import 'package:file/local.dart';

import 'config_handler.dart';
import 'initializer.dart';

abstract class Analytics {
  /// The default factory constructor that will return an implementation
  /// of the [Analytics] abstract class using the [LocalFileSystem]
  factory Analytics({
    required tool,
    required homeDirectory,
    required measurementId,
    required apiSecret,
    required toolsMessageVersion,
    required toolsMessage,
    required branch,
    required flutterVersion,
    required dartVersion,
    bool? forceReset,
  }) =>
      AnalyticsImpl(
        tool: tool,
        homeDirectory: homeDirectory,
        measurementId: measurementId,
        apiSecret: apiSecret,
        toolsMessageVersion: toolsMessageVersion,
        toolsMessage: toolsMessage,
        branch: branch,
        flutterVersion: flutterVersion,
        dartVersion: dartVersion,
      );

  /// Boolean indicating whether or not telemetry is enabled
  bool get telemetryEnabled;

  /// Boolean that lets the client know if they should display the message
  bool get shouldShowMessage;
}

class AnalyticsImpl implements Analytics {
  final FileSystem fs;
  late ConfigHandler _configHandler;
  late bool _showMessage;

  AnalyticsImpl({
    required tool,
    required homeDirectory,
    required measurementId,
    required apiSecret,
    required toolsMessageVersion,
    required toolsMessage,
    required branch,
    required flutterVersion,
    required dartVersion,
    bool forceReset = false,
    this.fs = const LocalFileSystem(),
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
      forceReset: forceReset,
    );
    initializer.run();
    _showMessage = initializer.firstRun;

    // Create the config handler that will parse the config file
    _configHandler = ConfigHandler(fs: fs, homeDirectory: homeDirectory);

    // Initialize the config handler class and check if the
    // tool message and version have been updated from what
    // is in the current file; if there is a new message version
    // make the necessary updates
    if (!_configHandler.parsedTools.containsKey(tool)) {
      _configHandler.addTool(tool: tool);
      _showMessage = true;
    }
  }

  @override
  bool get telemetryEnabled {
    return _configHandler.telemetryEnabled;
  }

  @override
  bool get shouldShowMessage => _showMessage;
}
