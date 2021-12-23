import 'package:logging/logging.dart';

import 'logging_bugfender.dart';
import 'dart:developer' as developer;

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

/// Instructs [LoggingBugfenderListener] to print colored text.
/// The color is based on the log level.
class ColoredTextPrintStrategy extends PrintStrategy {
  /// Creates a strategy that prints colored plain text.
  const ColoredTextPrintStrategy();

  static final _levelColors = <Level, String?>{
    Level.FINEST: '8',
    Level.FINER: '8',
    Level.FINE: '8',
    Level.CONFIG: null,
    Level.INFO: '12',
    Level.WARNING: '208',
    Level.SEVERE: '196',
    Level.SHOUT: '199',
  };

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

    final color = _levelColors[record.level];
    if (color != null) {
      final msg = '\x1B[${color}m$log\x1B[0m';
      developer.log(message);
      return msg;
    } else {
      return log.toString();
    }
  }
}
