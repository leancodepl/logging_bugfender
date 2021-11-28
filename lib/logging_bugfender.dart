//  Copyright 2020 LeanCode Sp. z o.o.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

/// A library integrating Bugfender with the `logging` package.
library logging_bugfender;

import 'package:flutter_bugfender/flutter_bugfender.dart';
import 'package:logging/logging.dart';

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
    bool printToConsole = true,
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

  /// Registers a [Logger] listener to the Bugfender.
  void listen(Logger logger) {
    logger.onRecord.listen((record) {
      if (record.level >= Level.SEVERE) {
        FlutterBugfender.fatal(_mapRecord(record));
      } else if (record.level >= Level.WARNING) {
        FlutterBugfender.warn(_mapRecord(record));
      } else if (record.level >= Level.CONFIG) {
        FlutterBugfender.info(_mapRecord(record));
      } else {
        FlutterBugfender.trace(_mapRecord(record));
      }
    });
  }

  String _mapRecord(LogRecord record) {
    var log = '[${record.level.name}] ${record.loggerName}: ${record.message}';
    if (record.error != null) {
      log += '\n${record.error}';
    }
    if (record.stackTrace != null) {
      log += '\n${record.stackTrace}';
    }

    return log;
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
