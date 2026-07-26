// An example app showing how to wire `logging_bugfender` into a Flutter app.
//
// This directory ships without the platform folders – run `flutter create .`
// in it once before `flutter run`.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_bugfender/logging_bugfender.dart';

/// Your secret app key, taken from the Bugfender dashboard.
///
/// Run the example with your own key:
/// `flutter run --dart-define=BUGFENDER_APP_KEY=<your-app-key>`.
const bugfenderAppKey = String.fromEnvironment('BUGFENDER_APP_KEY');

/// Flip this to `false` to see how the setup behaves on production.
const debugMode = true;

/// The key under which the signed in user is reported to Bugfender.
const usernameKey = 'username';

/// The listener has to outlive the logger it listens to, so it's kept in a
/// top-level variable. In a real app it would usually live in your DI
/// container.
late final LoggingBugfenderListener loggingListener;

void main() {
  loggingListener = setupLogger(debugMode: debugMode);

  runApp(const ExampleApp());
}

/// Creates a [LoggingBugfenderListener] and attaches it to the root logger, so
/// that every record logged anywhere in the app ends up in Bugfender.
LoggingBugfenderListener setupLogger({required bool debugMode}) {
  final LoggingBugfenderListener listener;

  if (debugMode) {
    // During debugging, you'll usually want to log everything and to also see
    // the logs in the console.
    Logger.root.level = Level.ALL;
    listener = LoggingBugfenderListener(
      bugfenderAppKey,
      consolePrintStrategy: const PlainTextPrintStrategy(),
    );
  } else {
    // On production, you probably want to log only INFO and above.
    Logger.root.level = Level.INFO;
    listener = LoggingBugfenderListener(bugfenderAppKey);
  }

  listener.listen(Logger.root);

  return listener;
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'logging_bugfender example',
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _cubit = FooBarCubit();

  bool _signedIn = false;

  /// Custom data is attached to every log sent from this device, which makes
  /// it easy to tell whose session you're looking at in the Bugfender console.
  Future<void> _toggleSignIn() async {
    if (_signedIn) {
      // After the user signs out.
      await loggingListener.removeCustomData(usernameKey);
    } else {
      // After the user signs in.
      await loggingListener.setCustomData(usernameKey, 'jane.doe');
    }

    if (mounted) {
      setState(() => _signedIn = !_signedIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('logging_bugfender')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: _cubit.doSomething,
              child: const Text('Do something'),
            ),
            FilledButton(
              onPressed: _cubit.doSomethingFailing,
              child: const Text('Do something that fails'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _toggleSignIn,
              child: Text(_signedIn ? 'Sign out' : 'Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stand-in for a piece of business logic that reports what it's doing.
///
/// Every class that logs should have its own [Logger] – its name is included
/// in the log message, so you always know where a record came from.
class FooBarCubit {
  final _logger = Logger('FooBarCubit');

  void doSomething() {
    _logger.info('Successfully did something');
  }

  void doSomethingFailing() {
    _logger.fine('About to do something else');

    try {
      throw const FormatException('Malformed response');
    } catch (err, st) {
      // Both the error and the stack trace are sent to Bugfender.
      _logger.severe('Failed doing something else', err, st);
    }
  }
}
