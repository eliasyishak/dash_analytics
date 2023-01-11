import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as p;

import 'config_handler.dart';
import 'constants.dart';
import 'ga_client.dart';
import 'initializer.dart';
import 'session.dart';
import 'user_property.dart';

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
    required String platform,
  }) =>
      AnalyticsImpl(
        tool: tool,
        homeDirectory: homeDirectory,
        measurementId: measurementId,
        apiSecret: apiSecret,
        branch: branch,
        flutterVersion: flutterVersion,
        dartVersion: dartVersion,
        platform: platform,
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
    required String platform,
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
        platform: platform,
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

  /// Call this method when the tool using this package is closed
  ///
  /// Prevents the tool from hanging when if there are still requests
  /// that need to be sent off
  void close();

  /// API to send events to Google Analytics to track usage
  void sendEvent({
    required String eventName,
    required Map eventData,
  });

  /// Pass a boolean to either enable or disable telemetry and make
  /// the necessary changes in the persisted configuration file
  void setTelemetry(bool reportingBool);
}

class AnalyticsImpl implements Analytics {
  final FileSystem fs;
  late final ConfigHandler _configHandler;
  late bool _showMessage;
  late final GAClient _gaClient;
  late final String _clientId;
  late final UserProperty userProperty;

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
    required String platform,
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
    _clientId = fs
        .file(p.join(
            homeDirectory.path, kDartToolDirectoryName, kClientIdFileName))
        .readAsStringSync();

    // Create the instance of the GA Client which will create
    // an [http.Client] to send requests
    _gaClient = GAClient(
      measurementId: measurementId,
      apiSecret: apiSecret,
    );

    // Initialize the user property class that will be attached to
    // each event that is sent to Google Analytics -- it will be responsible
    // for getting the session id or rolling the session if the duration
    // exceeds [kSessionDurationMinutes]
    userProperty = UserProperty(
      session: Session(homeDirectory: homeDirectory, fs: fs),
      branch: branch,
      host: platform,
      flutterVersion: flutterVersion,
      dartVersion: dartVersion,
      tool: tool,
    );
  }

  @override
  Map<String, ToolInfo> get parsedTools => _configHandler.parsedTools;

  @override
  bool get shouldShowMessage => _showMessage;

  @override
  bool get telemetryEnabled => _configHandler.telemetryEnabled;

  @override
  void close() => _gaClient.close();

  @override
  void sendEvent({
    required String eventName,
    required Map eventData,
  }) {
    if (!telemetryEnabled) return;

    // Construct the body of the request
    final Map body = {
      'client_id': _clientId,
      'events': [
        {
          'name': eventName,
          'params': eventData,
        }
      ],
      'user_properties': userProperty.preparePayload()
    };

    // Pass to the google analytics client to send
    _gaClient.sendData(body);
  }

  @override
  void setTelemetry(bool reportingBool) {
    _configHandler.setTelemetry(reportingBool);
  }
}
