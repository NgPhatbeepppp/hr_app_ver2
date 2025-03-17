import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thông báo nội bộ")),
      body: Center(child: Text("Tất cả thông báo nội bộ sẽ hiển thị tại đây")),
    );
  }
}
