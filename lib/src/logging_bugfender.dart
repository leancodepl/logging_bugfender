import 'dart:async';

import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:logging/logging.dart';
import 'package:logging_bugfender/src/print_strategy.dart';

/// A [Logger] listener that sends the records to Bugfender.
class LoggingBugfenderListener {
  /// Creates a [LoggingBugfenderListener]. You probably want to call [listen]
  /// just after creating it.
  ///
  /// The `appKey` is your secret app key from Bugfender.
  ///
  /// The `apiUri` and `baseUri` are the alternative URLs for on-premise
  /// installations.
  ///
  /// The `maximumLocalStorageSize` is a maximum size the log cache will use, in
  /// bytes.
  ///
  /// The `consolePrintStrategy` decides if and how logs are printed to the
  /// console.
  ///
  /// The `bugfenderPrintStrategy` decides if and how logs are sent to
  /// Bugfender.
  ///
  /// The `sendToBugfender` decides whether to send logs to bugfender. If it is
  /// set to false, then logs will be printed only locally, to your console.
  ///
  /// The `enableUIEventLogging` enables automatic logging of user interactions.
  /// Defaults to `true`.
  ///
  /// The `enableCrashReporting` enables automatic crash reporting. Defaults to
  /// `true`.
  ///
  /// The `enableAndroidLogcatLogging` enables automatic logging of Logcat (only
  /// on Android). Defaults to `true`. This may result in logging many
  /// unrelevant records.
  LoggingBugfenderListener(
    String appKey, {
    Uri? apiUri,
    Uri? baseUri,
    int? maximumLocalStorageSize,
    this.consolePrintStrategy = const NeverPrintStrategy(),
    this.bugfenderPrintStrategy = const PlainTextPrintStrategy(),
    bool enableUIEventLogging = true,
    bool enableCrashReporting = true,
    bool enableAndroidLogcatLogging = true,
  }) {
    FlutterBugfender.init(
      appKey,
      apiUri: apiUri,
      baseUri: baseUri,
      maximumLocalStorageSize: maximumLocalStorageSize,
      printToConsole: false, // we do logging ourselves
      enableUIEventLogging: enableUIEventLogging,
      enableCrashReporting: enableCrashReporting,
      enableAndroidLogcatLogging: enableAndroidLogcatLogging,
    );
  }

  /// Defines if and how logs should created and printed to the console.
  final PrintStrategy consolePrintStrategy;

  /// Defines if and how logs should be created and sent to Bugfender.
  ///
  /// Using [ColoredTextPrintStrategy] is not recommended and might have
  /// unexpected results.
  final PrintStrategy bugfenderPrintStrategy;

  /// Starts listening to logs emitted by [logger].
  StreamSubscription<LogRecord> listen(Logger logger) {
    return logger.onRecord.listen((logRecord) {
      final consoleLog = consolePrintStrategy.print(logRecord);
      if (consoleLog != null) {
        // ignore: avoid_print
        print(consoleLog);
      }

      final bugfenderLog = bugfenderPrintStrategy.print(logRecord);
      if (bugfenderLog != null) {
        if (logRecord.level >= Level.SEVERE) {
          FlutterBugfender.fatal(bugfenderLog);
        } else if (logRecord.level >= Level.WARNING) {
          FlutterBugfender.warn(bugfenderLog);
        } else if (logRecord.level >= Level.CONFIG) {
          FlutterBugfender.info(bugfenderLog);
        } else {
          FlutterBugfender.trace(bugfenderLog);
        }
      }
    });
  }

  /// Sets the custom data with a specified `key` for Bugfender on this device.
  Future<void> setCustomData(String key, dynamic value) {
    if (value is String) {
      return FlutterBugfender.setDeviceString(key, value);
    } else if (value is bool) {
      return FlutterBugfender.setDeviceBool(key, value);
    } else if (value is double) {
      return FlutterBugfender.setDeviceFloat(key, value);
    } else if (value is num) {
      return FlutterBugfender.setDeviceInt(key, value.toInt());
    } else {
      return FlutterBugfender.setDeviceString(key, value.toString());
    }
  }

  /// Removes the custom data with a specified `key`.
  Future<void> removeCustomData(String key) =>
      FlutterBugfender.removeDeviceKey(key);
}
