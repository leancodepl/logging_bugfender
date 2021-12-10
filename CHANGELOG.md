# 3.0.0

- Package rework. Now it comes with an opinionated (but configurable) logger
  setup.
- Add `PrintStrategy` classes to allow more granular control over
  `LoggingBugfenderListener`s behavior.
- **Breaking**: remove `printToConsole` from `LoggingBugfenderListener`'s
  constructor.

# 2.1.0

- `LoggingBugfenderListener.listen()` now returns a
  `StreamSubscription<LogRecord>` instead of `void`
- Update README.

# 2.0.0+1
 
- Depend on `flutter_bugfender` 2.0.1

# 2.0.0

- Bump minimum SDK version to 2.12.
- Depend on flutter_bugfender 2.0.0-web.1
- Depend on logging 1.0.1
- Log error and stack trace if present in the log record.

# 2.0.0-nullsafety.0

- Bump minimum SDK version to 2.12 prerelease.
- Add support for null-safety.

# 1.0.0

- First release.
