import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeScaffold extends StatefulWidget {
  final String title;
  final Widget body;

  const EmployeeScaffold({Key? key, required this.title, required this.body}) : super(key: key);

  @override
  _EmployeeScaffoldState createState() => _EmployeeScaffoldState();
}

class _EmployeeScaffoldState extends State<EmployeeScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
      setState(() {
        userEmail = userDoc['email'] ?? user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(widget.title)),
      drawer: _buildDrawer(context),
      onDrawerChanged: (isOpened) {
        setState(() {
          _isDrawerOpen = isOpened;
        });
      },
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_home.png",
              fit: BoxFit.cover,
            ),
          ),
          widget.body,
        ],
      ),
      bottomNavigationBar: _isDrawerOpen
          ? SizedBox.shrink()
          : BottomNavigationBar(
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
                BottomNavigationBarItem(icon: Icon(Icons.group), label: "Nhân viên"),
                BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Thông báo"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
              ],
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            accountName: Text("Xin chào!", style: TextStyle(fontSize: 18)),
            accountEmail: Text(userEmail ?? "Đang tải...", style: TextStyle(fontSize: 14)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Trang chủ"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Hồ sơ cá nhân"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text("Đơn xin nghỉ phép"),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
