import 'dart:async';

import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:logging/logging.dart';
import 'package:logging_bugfender/src/print_strategies.dart';

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
  /// The `maximumLocalStorageSize` is a maximum size the log cache will use,
  /// in bytes.
  ///
  /// The `printToConsole` decides whether to print to console or not.
  /// Defaults to `true`.
  ///
  /// The `printStrategy` decides if and how logs are printed to the console.
  /// It it is set, then printToConsole should be set to `false` to avoid
  /// logging everything twice.
  ///
  /// The `sendToBugfender` decides whether to send logs to bugfender. If it is
  /// set to false, then logs will be printed only locally, to your console.
  ///
  /// The `enableUIEventLogging` enables automatic logging of user
  /// interactions. Defaults to `true`.
  ///
  /// The `enableCrashReporting` enables automatic crash reporting. Defaults to
  /// `true`.
  ///
  /// The `enableAndroidLogcatLogging` enables automatic logging of Logcat
  /// (only on Android). Defaults to `true`. This may result in logging many
  /// unrelevant records.
  LoggingBugfenderListener(
    String appKey, {
    Uri? apiUri,
    Uri? baseUri,
    int? maximumLocalStorageSize,
    @Deprecated('Use printStrategy instead') bool printToConsole = true,
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
      printToConsole: printToConsole,
      enableUIEventLogging: enableUIEventLogging,
      enableCrashReporting: enableCrashReporting,
      enableAndroidLogcatLogging: enableAndroidLogcatLogging,
    );
  }

  /// Defines if and how logs should created and printed to the console.
  final PrintStrategy consolePrintStrategy;

  /// Defines if and how logs should be created and sent to Bugfender.
  ///
  /// Using [ColoredTextPrintStrategy] for this might have unexpected results
  /// and is discouraged.
  final PrintStrategy bugfenderPrintStrategy;

  /// Registers a [Logger] listener to the Bugfender.
  /// Starts listening to logs emitted by [logger]
  StreamSubscription<LogRecord> listen(Logger logger) {
    return logger.onRecord.listen((record) {
      if (consolePrintStrategy is NeverPrintStrategy &&
          bugfenderPrintStrategy is NeverPrintStrategy) {
        return;
      }

      if (consolePrintStrategy is PlainTextPrintStrategy) {
        final log = _createLog(record);
        // ignore: avoid_print
        print(log);
      } else if (consolePrintStrategy is ColoredTextPrintStrategy) {
        final log = _createLog(record);
        // TODO: make log colorful
        print(log);
      }

      if (bugfenderPrintStrategy is! NeverPrintStrategy) {
        final log = _createLog(record);
        if (record.level >= Level.SEVERE) {
          FlutterBugfender.fatal(log);
        } else if (record.level >= Level.WARNING) {
          FlutterBugfender.warn(log);
        } else if (record.level >= Level.CONFIG) {
          FlutterBugfender.info(log);
        } else {
          FlutterBugfender.trace(log);
        }
      }
    });
  }

  String _createLog(LogRecord record) {
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
