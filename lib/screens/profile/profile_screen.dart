import 'package:flutter/material.dart';
import 'leave_request_screen.dart';
import 'payroll_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
   Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hồ sơ cá nhân")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequestScreen()));
              },
              child: Text("Đăng ký lịch nghỉ"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PayrollScreen()));
              },
              child: Text("Xem bảng lương"),
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text("Đăng xuất"),
            ),
          ],
        ),
      ),
    );
  }
}
