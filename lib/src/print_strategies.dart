import 'logging_bugfender.dart';

/// Defines how [LoggingBugfenderListener] prints.
abstract class PrintStrategy {
  /// Const constructor so that subclasses can also have const constructors.
  const PrintStrategy();
}

/// Instructs [LoggingBugfenderListener] to never print.
class NeverPrintStrategy extends PrintStrategy {
  /// Creates a strategy that never prints.
  const NeverPrintStrategy();
}

/// Instructs [LoggingBugfenderListener] to print plain text.
class PlainTextPrintStrategy extends PrintStrategy {
  /// Creates a strategy that prints plain text.
  const PlainTextPrintStrategy();
}

/// Instructs [LoggingBugfenderListener] to print colored text.
/// The color is based on the log level.
class ColoredTextPrintStrategy extends PrintStrategy {
  /// Creates a strategy that prints colored plain text.
  const ColoredTextPrintStrategy();
}
