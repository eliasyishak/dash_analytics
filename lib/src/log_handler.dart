import 'dart:convert';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';
import 'enums.dart';
import 'initializer.dart';

class LogHandler {
  final FileSystem fs;
  final Directory homeDirectory;
  final File logFile;

  /// This class is responsible for writing to a log
  /// file that has been initialized by the [Initializer]
  ///
  /// It will be treated as an append only log and will be limited
  /// to have has many data records as specified by [kLogFileLength]
  LogHandler({
    required this.fs,
    required this.homeDirectory,
  }) : logFile = fs.file(p.join(
          homeDirectory.path,
          kDartToolDirectoryName,
          kLogFileName,
        ));

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

  /// Query the persisted log file using the persisted log file
  Map<String, dynamic> query(LogFileQuery q) {
    Iterable<Map<String, dynamic>> records =
        logFile.readAsLinesSync().map((String e) => jsonDecode(e));
    Map<String, dynamic> results = <String, dynamic>{};

    // Get the start and end dates for the log file
    results['start_datetime'] =
        DateTime.parse(records.first['user_properties']['local_time']['value']);
    results['end_datetime'] =
        DateTime.parse(records.last['user_properties']['local_time']['value']);

    switch (q) {
      case LogFileQuery.sessionCount:
        final Set<int> sessions = <int>{};
        for (Map<String, dynamic> element in records) {
          sessions.add(element['user_properties']['session_id']['value']);
        }
        results['session_count'] = sessions.length;
        break;
    }

    return results;
  }
}
