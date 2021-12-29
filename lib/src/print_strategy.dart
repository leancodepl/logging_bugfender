import 'package:logging/logging.dart';

import 'logging_bugfender.dart';

/// Defines how [LoggingBugfenderListener] prints log messages.
abstract class PrintStrategy {
  /// Const constructor so that subclasses can also have const constructors.
  const PrintStrategy();

  /// Creates a log message.
  String? print(LogRecord record);
}

/// Instructs [LoggingBugfenderListener] to never print.
class NeverPrintStrategy extends PrintStrategy {
  /// Creates a strategy that never prints.
  const NeverPrintStrategy();

  @override
  String? print(LogRecord record) => null;
}

/// Instructs [LoggingBugfenderListener] to print plain text.
class PlainTextPrintStrategy extends PrintStrategy {
  /// Creates a strategy that prints plain text.
  const PlainTextPrintStrategy();

  @override
  String print(LogRecord record) {
    final log = StringBuffer()
      ..writeAll(
        <String>[
          '[${record.level.name}]',
          if (record.loggerName.isNotEmpty) '${record.loggerName}:',
          record.message,
        ],
        ' ',
      );

    if (record.error != null) {
      log.write('\n${record.error}');
    }
    if (record.stackTrace != null) {
      log.write('\n${record.stackTrace}');
    }

    return log.toString();
  }
}
