import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hr_app_ver2/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(isWeb: false)); // ✅ Chạy giao diện Mobile
}
