import 'dart:developer' as dev;

import 'package:logging/logging.dart';
import 'package:logging_bugfender/src/logging_bugfender.dart';

/// Defines how [LoggingBugfenderListener] prints log messages.
abstract class PrintStrategy {
  /// Const constructor so that subclasses can also have const constructors.
  const PrintStrategy();

  /// Creates a log message.
  String? print(LogRecord record);

  /// Creates a log message and prints it using the `log` function from
  /// `dart:developer`.

  void log(LogRecord record);
}

/// Instructs [LoggingBugfenderListener] to never print.
class NeverPrintStrategy extends PrintStrategy {
  /// Creates a strategy that never prints.
  const NeverPrintStrategy();

  @override
  String? print(LogRecord record) => null;

  @override
  void log(LogRecord record) {}
}

/// Instructs [LoggingBugfenderListener] to print plain text.
class PlainTextPrintStrategy extends PrintStrategy {
  /// Creates a strategy that prints plain text.
  const PlainTextPrintStrategy();

  @override
  String print(LogRecord record) {
    final logMessage = StringBuffer()
      ..writeAll(
        <String>[
          '[${record.level.name}]',
          if (record.loggerName.isNotEmpty) '${record.loggerName}:',
          record.message,
        ],
        ' ',
      );

    if (record.error != null) {
      logMessage.write('\n${record.error}');
    }
    if (record.stackTrace != null) {
      logMessage.write('\n${record.stackTrace}');
    }

    return logMessage.toString();
  }

  @override
  void log(LogRecord record) {
    final logMessage = '[${record.level.name}] ${record.message}';

    dev.log(
      logMessage,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
      level: record.level.value,
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      zone: record.zone,
    );
  }
}

/// Instructs [LoggingBugfenderListener] to print color-coded text based
/// on log levels. Color display depends on the terminal’s support for ANSI
/// escape sequences, which theoretically can be verified using
/// `io.stdout.supportsAnsiEscapes`. However, this check often fails to return
/// `true` even when ANSI escapes are supported by the terminal.
///
/// For optimal results, test this print strategy in your chosen
/// IDE and output device combination. Consider enabling this feature
/// conditionally, such as through an environment variable.

class ColoredTextPrintStrategy extends PlainTextPrintStrategy {
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

  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = '\x1B[';

  /// Reset all colors and options to terminal defaults.
  static const ansiDefault = '${ansiEsc}0m';

  @override
  String print(LogRecord record) {
    final logMessage = super.print(record);

    return _encodeColor(logMessage, record.level);
  }

  @override
  void log(LogRecord record) {
    final logMessage = '[${record.level.name}] ${record.message}';

    dev.log(
      _encodeColor(logMessage.toString(), record.level),
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
      level: record.level.value,
      time: record.time,
      sequenceNumber: record.sequenceNumber,
      zone: record.zone,
    );
  }

  String _encodeColor(String text, Level level) {
    final color = _levelColors[level];

    if (color != null) {
      return '${ansiEsc}38;5;${color}m$text$ansiDefault';
    } else {
      return text;
    }
  }
}
