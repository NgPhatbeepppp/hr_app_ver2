import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  DateTime? _dob;
  String _position = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _firestore.collection('employees').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['name'];
        _phoneController.text = userDoc['phone'];
        _addressController.text = userDoc['address'];
        _position = userDoc['position'];
        _dob = DateTime.tryParse(userDoc['dob']);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    String uid = _auth.currentUser!.uid;
    try {
      await _firestore.collection('employees').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'dob': _dob?.toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Chỉnh sửa thông tin", style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade200, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FadeInUp(
            duration: Duration(milliseconds: 600),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTextField(_nameController, "Họ và tên", Icons.person),
                            SizedBox(height: 12),
                            _buildTextField(_phoneController, "Số điện thoại", Icons.phone),
                            SizedBox(height: 12),
                            _buildTextField(_addressController, "Địa chỉ", Icons.location_on),
                            SizedBox(height: 12),
                            ListTile(
                              leading: Icon(Icons.work, color: Colors.blue.shade700),
                              title: Text(
                                "Chức vụ: $_position",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                              title: Text(
                                _dob != null
                                    ? "Ngày sinh: ${_dob!.day}/${_dob!.month}/${_dob!.year}"
                                    : "Chọn ngày sinh",
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                              onTap: () => _selectDate(context),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _updateProfile,
                              icon: _isLoading
                                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Icon(Icons.save),
                              label: Text("Lưu thay đổi", style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
            ),
          )
        ],
      ),
    );
  }
}
