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
  }

  bool get telemetryEnabled {
    return _configHandler.telemetryEnabled;
  }
}
