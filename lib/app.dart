import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'widgets/bottom_nav.dart';
import 'screens/wed/admin_dashboard.dart'; // Màn hình quản lý trên Web

class MyApp extends StatelessWidget {
  final bool isWeb;
  MyApp({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HR App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(isWeb: isWeb),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool isWeb;
  AuthWrapper({required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return isWeb ? AdminDashboard() : BottomNav();
        }
        return LoginScreen();
      },
    );
  }
}
