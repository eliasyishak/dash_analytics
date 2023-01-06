import 'dart:convert';

import 'package:file/file.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import 'utils/uuid.dart';

/// Creates the text file that will contain the client ID
/// which will be used across all related tools for analytics
/// reporting in GA
void createClientIdFile({required File clientFile}) {
  clientFile.createSync(recursive: true);
  clientFile.writeAsStringSync(Uuid().generateV4());
}

/// Creates the configuration file with the default message
/// in the user's home directory
void createConfigFile({
  required File configFile,
  required String dateStamp,
  required String tool,
  required String toolsMessage,
  required int toolsMessageVersion,
}) {
  configFile.createSync(recursive: true);
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
# the value "0" by uncommenting the following line:
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
$tool=$dateStamp,$toolsMessageVersion
''');
}

/// Creates the session json file which will contain
/// the current session id along with the timestamp for
/// the last ping which will be used to increment the session
/// if current timestamp is greater than the session window
createSessionFile({required File sessionFile}) {
  final DateTime now = DateTime.now();
  sessionFile.createSync(recursive: true);
  sessionFile.writeAsStringSync(jsonEncode({
    'session_id': now.millisecondsSinceEpoch,
    'last_ping': now.millisecondsSinceEpoch,
  }));
}

class Initializer {
  final FileSystem fs;
  final String tool;
  final Directory homeDirectory;
  final int toolsMessageVersion;
  final String toolsMessage;
  final bool forceReset;
  bool firstRun = false;

  /// Responsibe for the initialization of the files
  /// necessary for analytics reporting
  ///
  /// Creates the configuration file that allows the user to
  /// mannually opt out of reporting along with the file containing
  /// the client ID to be used across all relevant tooling
  ///
  /// Updating of the config file with new versions will
  /// not be handled by the [Initializer]
  ///
  /// Passing [forceReset] as true will only reset the configuration
  /// file, it won't recreate the client id file
  Initializer({
    required this.fs,
    required this.tool,
    required this.homeDirectory,
    required this.toolsMessageVersion,
    required this.toolsMessage,
    this.forceReset = false,
  });

  String get dateStamp {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// This will check that there is a client ID populated in
  /// the user's home directory under the .dart-tool directory.
  /// If it doesn't exist, one will be created there
  void run() {
    // Begin by checking for the 'dart-flutter-telemetry.config'
    final File configFile = fs.file(p.join(
        homeDirectory.path, '.dart-tool', 'dart-flutter-telemetry.config'));

    // When the config file doesn't exist, initialize it with the default tools
    // and the current date
    if (!configFile.existsSync() || forceReset) {
      firstRun = true;
      createConfigFile(
        configFile: configFile,
        dateStamp: dateStamp,
        tool: tool,
        toolsMessage: toolsMessage,
        toolsMessageVersion: toolsMessageVersion,
      );
    }

    // Begin initialization checks for the client id
    final File clientFile =
        fs.file(p.join(homeDirectory.path, '.dart-tool', 'CLIENT_ID'));
    if (!clientFile.existsSync()) {
      createClientIdFile(clientFile: clientFile);
    }

    // Begin initialization checks for the session file
    final File sessionFile =
        fs.file(p.join(homeDirectory.path, '.dart-tool', 'session.json'));
    if (!sessionFile.existsSync()) {
      createSessionFile(sessionFile: sessionFile);
    }
  }
}
