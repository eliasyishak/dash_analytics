import 'config_handler.dart';
import 'initializer.dart';

class Analytics {
  final ConfigHandler _configHandler;
  late bool _showMessage;

  Analytics({
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
  }) : _configHandler = ConfigHandler(homeDirectory: homeDirectory) {
    // This initializer class will let the instance know
    // if it was the first run; if it is, nothing will be sent
    // on the first run
    final Initializer initializer = Initializer(
      tool: tool,
      homeDirectory: homeDirectory,
      toolsMessageVersion: toolsMessageVersion,
      toolsMessage: toolsMessage,
      forceReset: forceReset ?? false,
    );
    initializer.run();
    _showMessage = initializer.firstRun;

    // Initialize the config handler class and check if the
    // tool message and version have been updated from what
    // is in the current file; if there is a new message version
    // make the necessary updates
    if (!_configHandler.parsedTools.containsKey(tool)) {
      _configHandler.addTool(tool: tool);
      _showMessage = true;
    }
  }

  /// Boolean indicating whether or not telemetry is enabled
  bool get telemetryEnabled {
    return _configHandler.telemetryEnabled;
  }

  /// Boolean that lets the client know if they should display the message
  bool get shouldShowMessage => _showMessage;
}
