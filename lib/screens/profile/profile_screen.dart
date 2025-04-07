// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore.collection('employees').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải thông tin nhân viên: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueAccent.shade700,
            Colors.indigo.shade900,
          ],
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : userData == null
                ? Center(
                    child: FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: Text(
                        "Không tìm thấy thông tin nhân viên",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top, // Full height minus top padding
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 10.0,
                        bottom: MediaQuery.of(context).padding.bottom + 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header
                            FadeInDown(
                              duration: Duration(milliseconds: 800),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Thông tin cá nhân",
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.logout, color: Colors.white),
                                    onPressed: _signOut,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            // Avatar và tên
                            FadeInUp(
                              duration: Duration(milliseconds: 1000),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.95),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blueAccent.shade700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            FadeInUp(
                              duration: Duration(milliseconds: 1100),
                              child: Text(
                                userData!["name"] ?? "Không xác định",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Thông tin cá nhân
                            FadeInUp(
                              duration: Duration(milliseconds: 1200),
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Colors.white.withOpacity(0.95),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      _buildInfoRow(
                                        Icons.badge,
                                        "Chức vụ",
                                        userData!["position"] ?? "Không xác định",
                                      ),
                                      _buildInfoRow(
                                        Icons.email,
                                        "Email",
                                        userData!["email"] ?? "Không xác định",
                                      ),
                                      _buildInfoRow(
                                        Icons.phone,
                                        "Số điện thoại",
                                        userData!["phone"] ?? "Không xác định",
                                      ),
                                      _buildInfoRow(
                                        Icons.location_on,
                                        "Địa chỉ",
                                        userData!["address"] ?? "Không xác định",
                                      ),
                                      _buildInfoRow(
                                        Icons.cake,
                                        "Ngày sinh",
                                        _formatDate(userData!["dob"]),
                                      ),
                                      _buildInfoRow(
                                        Icons.calendar_today,
                                        "Ngày bắt đầu",
                                        _formatDate(userData!["startDate"]),
                                      ),
                                      _buildInfoRow(
                                        Icons.work,
                                        "Trạng thái",
                                        userData!["status"] ?? "Không xác định",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Nút chỉnh sửa
                            FadeInUp(
                              duration: Duration(milliseconds: 1300),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/edit_profile");
                                },
                                icon: Icon(Icons.edit, color: Colors.white),
                                label: Text(
                                  "Chỉnh sửa hồ sơ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          SizedBox(width: 10),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    } else if (timestamp is String) {
      return timestamp.length >= 10 ? timestamp.substring(0, 10) : "Không xác định";
    }
    return "Không xác định";
  }
}