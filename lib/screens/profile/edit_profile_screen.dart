import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  DateTime? _dob;
  String _position = ""; // Chỉ hiển thị, không chỉnh sửa
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
        _position = userDoc['position']; // Không cho chỉnh sửa
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
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chỉnh sửa thông tin")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, "Họ và tên", Icons.person),
                SizedBox(height: 10),
                _buildTextField(_phoneController, "Số điện thoại", Icons.phone),
                SizedBox(height: 10),
                _buildTextField(_addressController, "Địa chỉ", Icons.location_on),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.work, color: Colors.blueAccent),
                  title: Text("Chức vụ: $_position", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: Text(_dob != null ? "Ngày sinh: ${_dob!.day}/${_dob!.month}/${_dob!.year}" : "Chọn ngày sinh"),
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateProfile,
        child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.save),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
