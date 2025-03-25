import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hr_app_ver2/app.dart';
import 'firebase_options.dart';
import 'package:hr_app_ver2/screens/auth/login_screen.dart';
import 'package:hr_app_ver2/screens/profile/profile_screen.dart';
import 'package:hr_app_ver2/screens/auth/forgot_password_screen.dart';
import 'package:hr_app_ver2/screens/profile/leave_request_screen.dart';
import 'package:hr_app_ver2/screens/profile/edit_profile_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(isWeb: false)); // ✅ Chạy giao diện Mobile
}
class MyApp extends StatelessWidget {
  final bool isWeb;

  MyApp({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/login", // Hoặc "/home" nếu bạn có trang chính
      routes: {
        "/login": (context) => LoginScreen(), // Định nghĩa trang login
        "/profile": (context) => ProfileScreen(), // Thêm các trang khác nếu cần
        //TODO '/attendance': (context) => AttendanceScreen(),
        "/forgot-password": (context) => ForgotPasswordScreen(),
        //TODO '/attendance_history': (context) => AttendanceHistoryScreen(),
        //TODO '/salary': (context) => SalaryScreen(),
        '/leave_request': (context) => LeaveRequestScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
      },
    );
  }
}
