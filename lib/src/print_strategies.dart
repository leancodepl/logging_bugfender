import 'logging_bugfender.dart';

/// Defines how [LoggingBugfenderListener] prints.
enum PrintStrategy {
  /// Instructs [LoggingBugfenderListener] to never print.
  never,

  /// Instructs [LoggingBugfenderListener] to print plain text.
  plainText,

  /// Instructs [LoggingBugfenderListener] to print colored text.
  /// The color is based on the log level.
  coloredText,
}
