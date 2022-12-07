import 'dart:io';

import 'config_handler.dart';
import 'initializer.dart';

class Analytics {
  final ConfigHandler _configHandler;

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

    // Initialize the config handler class and check if the
    // tool message and version have been updated from what
    // is in the current file; if there is a new message version
    // make the necessary updates
    // ignore: unused_local_variable TODO: remove after increment method implemented
    bool messagePrinted = false;
    if (!_configHandler.parsedTools.containsKey(tool)) {
      _configHandler.addTool(tool: tool);
      stdout.writeln(toolsMessage);
      messagePrinted = true;
    }
  }

  bool get telemetryEnabled {
    return _configHandler.telemetryEnabled;
  }
}
