import 'package:file/file.dart';

import 'constants.dart';
import 'initializer.dart';

class LogHandler {
  final FileSystem fs;
  final Directory homeDirectory;

  /// This class is responsible for writing to a log
  /// file that has been initialized by the [Initializer]
  ///
  /// It will be treated as an append only log and will be limited
  /// to have has many data records as specified by [kLogFileLength]
  LogHandler({
    required this.fs,
    required this.homeDirectory,
  });
}
