import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String _role = 'Nhân viên';
  DateTime? _dob;
  DateTime? _startDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;

      Employee newEmployee = Employee(
        id: uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        position: _positionController.text.trim(),
        salary: double.tryParse(_salaryController.text) ?? 0.0,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dob: _dob?.toIso8601String() ?? '',
        startDate: _startDate?.toIso8601String() ?? '',
        status: 'Đang làm việc',
        role: _role,
      );

      await _firestore.collection('employees').doc(uid).set(newEmployee.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm nhân viên thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thêm nhân viên: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm Nhân Viên', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Tên nhân viên', Icons.person),
                _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
                _buildTextField(_passwordController, 'Mật khẩu', Icons.lock, isPassword: true),
                _buildTextField(_positionController, 'Chức vụ', Icons.work),
                _buildTextField(_salaryController, 'Mức lương', Icons.monetization_on, isNumber: true),
                _buildTextField(_phoneController, 'Số điện thoại', Icons.phone, isNumber: true),
                _buildTextField(_addressController, 'Địa chỉ', Icons.home),
                _buildDropdownRole(),
                _buildDatePicker('Ngày sinh', _dob, (date) => setState(() => _dob = date)),
                _buildDatePicker('Ngày bắt đầu', _startDate, (date) => setState(() => _startDate = date)),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _addEmployee,
                          icon: Icon(Icons.save),
                          label: Text('Lưu Nhân Viên', style: GoogleFonts.lato(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isNumber = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _buildDropdownRole() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: _role,
        decoration: InputDecoration(
          labelText: 'Vai trò',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ['Nhân viên', 'Quản trị viên'].map((role) {
          return DropdownMenuItem(value: role, child: Text(role));
        }).toList(),
        onChanged: (value) => setState(() => _role = value!),
      ),
    );
  }
  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15.0),
    child: ListTile(
      title: Text(label),
      subtitle: Text(
        selectedDate != null ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}' : 'Chưa chọn',
        style: TextStyle(color: Colors.blueAccent),
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.blueAccent),
      onTap: () => _selectDate(context, onDateSelected),
    ),
  );
}

}
