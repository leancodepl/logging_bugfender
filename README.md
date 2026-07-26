<div align="center">

[![Banner][banner-img]][leancode-landing]

</div>

# logging_bugfender

[![logging_bugfender pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

A library helping integrate Bugfender with the [logging] package.

See the [example app][example] for a runnable version of the snippets below.

## Usage

### Setup

```dart
final loggingListener = LoggingBugfenderListener('my-very-secret-app-key');

void main() {
    setupLogger(true);
    // ...
    runApp(MyApp());
}

void setupLogger(bool debugMode) {
  if (debugMode) {
    // During debugging, you'll usually want to log everything
    Logger.root.level = Level.ALL;
    LoggingBugfenderListener(
      config.bugfenderKey,
      consolePrintStrategy: const PlainTextPrintStrategy(),
    ).listen(Logger.root);
  } else {
    // On production, you probably want to log only INFO and above
    Logger.root.level = Level.INFO;
    LoggingBugfenderListener(config.bugfenderKey).listen(Logger.root);
  }
}
```

### Custom data

You can also add and remove custom data.

```dart
const logUsernameKey = 'username';

// After the user signs in
loggingListener.setCustomData(logUsernameKey, '<some username>');

// After the user signs out
loggingListener.removeCustomData(logUsernameKey);
```

### In a cubit

```dart
class FooBarCubit {
    final _logger = Logger('FooBarCubit');

    // (...)

    void doSomething() {
        try {
            // (...)
            _logger.info('Successfuly did something');
        } catch (err, st) {
            _logger.severe('Failed doing something', err, st);
        }
    }
}
```

---

## 🛠️ Maintained by LeanCode
<div align="center">

  [<img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />][leancode-landing]

</div>

This package is built with 💙 by **[LeanCode][leancode-landing]**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol][patrol-landing]** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**][leancode-estimate]
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages][leancode-packages]

</div>

[pub-badge]: https://img.shields.io/pub/v/logging_bugfender
[pub-badge-link]: https://pub.dev/packages/logging_bugfender
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/logging_bugfender/test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/logging_bugfender/actions/workflows/test.yml
[logging]: https://pub.dev/packages/logging
[example]: https://github.com/leancodepl/logging_bugfender/tree/master/example
[banner-img]: https://raw.githubusercontent.com/leancodepl/logging_bugfender/refs/heads/master/docs/imgs/banner.png
[leancode-landing]: https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=logging-bugfender
[leancode-estimate]: https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=logging-bugfender
[leancode-packages]: https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads
[patrol-landing]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=logging-bugfender