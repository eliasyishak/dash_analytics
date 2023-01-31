import 'dart:convert';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';
import 'initializer.dart';

class LogFileStats {
  /// The oldest timestamp in the log file
  final DateTime startDateTime;

  /// The latest timestamp in the log file
  final DateTime endDateTime;

  /// The number of unique session ids found in the log file
  final int sessionCount;

  /// Contains the data from the [LogHandler.logFileStats] method
  const LogFileStats({
    required this.startDateTime,
    required this.endDateTime,
    required this.sessionCount,
  });

  @override
  String toString() => jsonEncode(<String, dynamic>{
        'startDateTime': startDateTime.toString(),
        'endDateTime': endDateTime.toString(),
        'sessionCount': sessionCount,
      });
}

/// This class is responsible for writing to a log
/// file that has been initialized by the [Initializer]
///
/// It will be treated as an append only log and will be limited
/// to have has many data records as specified by [kLogFileLength]
class LogHandler {
  final FileSystem fs;
  final Directory homeDirectory;
  final File logFile;

  /// A log handler constructor that will delegate saving
  /// logs and retrieving stats from the persisted log
  LogHandler({
    required this.fs,
    required this.homeDirectory,
  }) : logFile = fs.file(p.join(
          homeDirectory.path,
          kDartToolDirectoryName,
          kLogFileName,
        ));

  /// Get stats from the persisted log file
  LogFileStats? logFileStats() {
    Iterable<Map<String, dynamic>> records =
        logFile.readAsLinesSync().map((String e) => jsonDecode(e));

    if (records.isEmpty) return null;

    // Get the start and end dates for the log file
    final DateTime startDateTime =
        DateTime.parse(records.first['user_properties']['local_time']['value']);
    final DateTime endDateTime =
        DateTime.parse(records.last['user_properties']['local_time']['value']);

    // Collection of unique sessions
    final Set<int> sessions = <int>{};
    for (Map<String, dynamic> element in records) {
      sessions.add(element['user_properties']['session_id']['value']);
    }
    final int sessionCount = sessions.length;

    return LogFileStats(
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      sessionCount: sessionCount,
    );
  }

  /// Saves the data passed in as a single line in the log file
  ///
  /// This will keep the max number of records limited to equal to
  /// or less than [kLogFileLength] records
  void save({required Map<String, dynamic> data}) {
    List<String> records = logFile.readAsLinesSync();
    final String content = '${jsonEncode(data)}\n';

    // When the record count is less than the max, add as normal;
    // else drop the oldest records until equal to max
    if (records.length < kLogFileLength) {
      logFile.writeAsStringSync(content, mode: FileMode.writeOnlyAppend);
    } else {
      records.add(content);
      records = records.skip(records.length - kLogFileLength).toList();

      logFile.writeAsStringSync(records.join('\n'));
    }
  }
}
