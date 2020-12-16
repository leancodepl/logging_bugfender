# logging_bugfender

[![logging_bugfender pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

A library helping integrate Bugfender with the `logging` package.

## Usage

```dart
final loggingListener = LoggingBugfenderListener('my-very-secret-app-key');

// You probably want it to be INFO on production
Logger.root.level = Level.ALL;
// Listen on root logger
loggingListener.listen(Logger.root);

const logUsernameKey = 'username';

// After the user signs in
loggingListener.setCustomData(logUsernameKey, '<some username>');

// After the user signs out
loggingListener.removeCustomData(logUsernameKey);
```

[pub-badge]: https://img.shields.io/pub/v/logging_bugfender
[pub-badge-link]: https://pub.dev/packages/logging_bugfender
[build-badge]: https://img.shields.io/github/workflow/status/leancodepl/logging_bugfender/test
[build-badge-link]: https://github.com/leancodepl/logging_bugfender/actions?query=workflow%3A%22test%22
