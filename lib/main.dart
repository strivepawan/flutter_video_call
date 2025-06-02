import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'injection/injection.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up dependencies based on platform
  if (Platform.isAndroid) {
    configureDependencies(CallEnvironment.android);
  } else if (Platform.isIOS) {
    configureDependencies(CallEnvironment.ios);
  }

  runApp(const App());
}
