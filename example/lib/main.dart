// An example app showing how to wire `logging_bugfender` into a Flutter app.
//
// This directory ships without the platform folders – run `flutter create .`
// in it once before `flutter run`.

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:logging_bugfender/logging_bugfender.dart';

/// The key under which the signed in user is reported to Bugfender.
const usernameKey = 'username';

void main() {
  // During debugging, you'll usually want to log everything. On production,
  // `Level.INFO` and above is usually enough.
  Logger.root.level = Level.ALL;

  final loggingListener = LoggingBugfenderListener(
    'my-very-secret-app-key',
    // Logs are only sent to Bugfender by default – printing them to the
    // console too is handy while debugging.
    consolePrintStrategy: const PlainTextPrintStrategy(),
  )..listen(Logger.root);

  runApp(ExampleApp(loggingListener: loggingListener));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key, required this.loggingListener});

  final LoggingBugfenderListener loggingListener;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'logging_bugfender example',
      home: ExamplePage(loggingListener: loggingListener),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key, required this.loggingListener});

  final LoggingBugfenderListener loggingListener;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  /// Every class that logs should have its own [Logger] – its name is included
  /// in the log message, so you always know where a record came from.
  final _logger = Logger('ExamplePage');

  bool _signedIn = false;

  /// Custom data is attached to every log sent from this device, which makes
  /// it easy to tell whose session you're looking at in the Bugfender console.
  Future<void> _toggleSignIn() async {
    final signedIn = _signedIn;

    try {
      if (signedIn) {
        await widget.loggingListener.removeCustomData(usernameKey);
      } else {
        await widget.loggingListener.setCustomData(usernameKey, 'jane.doe');
      }
    } catch (err, st) {
      // Both the error and the stack trace are sent to Bugfender.
      _logger.severe('Failed updating the custom data', err, st);
      return;
    }

    _logger.info(signedIn ? 'Signed out' : 'Signed in');

    if (mounted) {
      setState(() => _signedIn = !signedIn);
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
              onPressed: () => _logger.fine('The details button was tapped'),
              child: const Text('Log at FINE'),
            ),
            FilledButton(
              onPressed: () => _logger.warning('The cache is almost full'),
              child: const Text('Log at WARNING'),
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
