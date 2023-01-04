import 'dart:convert';

import 'package:file/file.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

/// The regex pattern used to parse the disable analytics line
const String disableTelemetryPattern = r'^(;?)reporting=([0|1]) *$';

/// The regex pattern used to parse the tools info
/// from the configuration file
///
/// Example:
/// flutter-tools=2022-10-26,1
const String toolPattern =
    r'^([A-Za-z0-9]+-*[A-Za-z0-9]*)=([0-9]{4}-[0-9]{2}-[0-9]{2}),([0-9]+)$';

class ConfigHandler {
  final FileSystem fs;
  final Directory homeDirectory;
  final File configFile;
  final File clientIdFile;
  final Map<String, ToolInfo> parsedTools = {};

  /// Reporting enabled unless specified by user
  bool _telemetryEnabled = true;

  ConfigHandler({
    required this.fs,
    required this.homeDirectory,
  })  : configFile = fs.file(p.join(
          homeDirectory.path,
          '.dart-tool',
          'dart-flutter-telemetry.config',
        )),
        clientIdFile = fs.file(p.join(
          homeDirectory.path,
          '.dart-tool',
          'CLIENT_ID',
        )) {
    parseConfig();
  }

  String get dateStamp {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Regex pattern implementation for matching a line in the config file
  ///
  /// Example:
  /// flutter-tools=2022-10-26,1
  static RegExp disableTelemetryRegex =
      RegExp(disableTelemetryPattern, multiLine: true);

  /// Method responsible for reading in the config file stored on
  /// user's machine and parsing out the following: all the tools that
  /// have been logged in the file, the dates they were last run, and
  /// determining if telemetry is enabled by parsing the file
  void parseConfig() {
    final RegExp toolRegex = RegExp(toolPattern, multiLine: true);
    final RegExp disableTelemetryRegex =
        RegExp(disableTelemetryPattern, multiLine: true);

    // Read the configuration file as a string and run the two regex patterns
    // on it to get information around which tools have been parsed and whether
    // or not telemetry has been disabled by the user
    final String configString = configFile.readAsStringSync();

    // Collect the tools logged in the configuration file
    toolRegex.allMatches(configString).forEach((element) {
      // Extract the information relevant for the [ToolInfo] class
      final String tool = element.group(1) as String;
      final DateTime lastRun = DateTime.parse(element.group(2) as String);
      final int versionNumber = int.parse(element.group(3) as String);

      // Initialize an instance of the [ToolInfo] class to store
      // in the [parsedTools] map object
      parsedTools[tool] = ToolInfo(
        lastRun: lastRun,
        versionNumber: versionNumber,
      );
    });

    // Check for lines signaling that the user has disabled analytics,
    // if multiple lines are found, the more conservative value will be used
    disableTelemetryRegex.allMatches(configString).forEach((element) {
      // Conditional for recording telemetry as being disabled
      if (element.group(1) != ';' && element.group(2) == '0') {
        _telemetryEnabled = false;
      }
    });
  }

  // TODO: determine if we should read from the file every time we
  //  get the [_telemetryEnabled] field; there is an edge case where
  //  two analytics classes are running and one disables telemetry, the
  //  other one will not know telemetry has been disabled until we call
  //  the [parseConfig()] method again
  bool get telemetryEnabled => _telemetryEnabled;

  /// Responsibe for the creation of the configuration line
  /// for the tool being passed in by the user and adding a
  /// [ToolInfo] object
  void addTool({required String tool}) {
    // Increment the version number of any existing tools
    // that already exist in configuration file by using
    // the [incrementToolVersion] method
    if (parsedTools.containsKey(tool)) {
      // TODO: implement method to increment the tool if it
      //  already exists in the config file
    }

    // Create the new instance of [ToolInfo] to be added
    // to the [parsedTools] map
    final DateTime now = DateTime.now();
    parsedTools[tool] = ToolInfo(lastRun: now, versionNumber: 1);

    // New string to be appended to the bottom of the configuration file
    // with a newline character for new tools to be added
    String newTool = '$tool=$dateStamp,1\n';
    if (!configFile.readAsStringSync().endsWith('\n')) {
      newTool = '\n$newTool';
    }
    configFile.writeAsStringSync(newTool, mode: FileMode.append);
  }

  /// Disables the reporting capabilities if false is passed
  void enableTelemetry(bool reportingBool) {
    final String flag = reportingBool ? '1' : '0';
    final String configString = configFile.readAsStringSync();

    final Iterable<RegExpMatch> matches =
        disableTelemetryRegex.allMatches(configString);

    // TODO: need to determine what to do when there are two lines for the reporting
    //  flag; currently assuming that there will only be one
    if (matches.length == 1) {
      final String newTelemetryString = 'reporting=$flag';

      final String newConfigString =
          configString.replaceAll(disableTelemetryRegex, newTelemetryString);

      configFile.writeAsStringSync(newConfigString);

      _telemetryEnabled = reportingBool;
    }
  }
}

class ToolInfo {
  DateTime lastRun;
  int versionNumber;

  ToolInfo({
    required this.lastRun,
    required this.versionNumber,
  });

  @override
  String toString() {
    return json.encode({
      'lastRun': DateFormat('yyyy-MM-dd').format(lastRun),
      'versionNumber': versionNumber,
    });
  }
}
