import 'initializer.dart';

class Analytics {
  static final Analytics _instance = Analytics._internal();

  bool _singletonInitialized = false;

  factory Analytics() {
    if (!_instance._singletonInitialized) {
      throw Exception(
          'Analytics has not been initialized - to initialize call `Analytics.setup(...)` '
          'before calling for the singleton instance\n'
          "Recommended to call at entry point's main method");
    }
    return _instance;
  }

  /// This will be required to setup before using the
  /// [Analytics] singleton instance.
  static void setup({
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
  }) {
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

    // This will allow for the singleton to be access via the
    // factory constructor
    _instance._singletonInitialized = true;
  }

  /// Produces the singleton instance of the analytics
  /// class to be passed around tools codebase
  Analytics._internal();
}
