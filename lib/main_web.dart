import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hr_app_ver2/screens/wed/admin_dashboard.dart';
import 'firebase_options.dart';
import 'package:hr_app_ver2/services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  runApp(AdminApp()); // ✅ Chạy giao diện Web
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(),
    );
  }
}
