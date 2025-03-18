import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/employee_model.dart';

class AddEmployeeScreen extends StatefulWidget {
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
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
      Employee newEmployee = Employee(
        id: '', // Temporary placeholder for ID
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        position: _positionController.text.trim(),
        salary: double.tryParse(_salaryController.text) ?? 0.0,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dob: _dob?.toIso8601String() ?? '',
        startDate: _startDate?.toIso8601String() ?? '',
        status: 'Đang làm việc',
      );

      DocumentReference docRef = await _firestore.collection('employees').add(newEmployee.toMap());
      await docRef.update({'id': docRef.id});

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
        title: Text('Thêm Nhân Viên', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                _buildTextField(_positionController, 'Chức vụ', Icons.work),
                _buildTextField(_salaryController, 'Mức lương', Icons.monetization_on, isNumber: true),
                _buildTextField(_phoneController, 'Số điện thoại', Icons.phone, isNumber: true),
                _buildTextField(_addressController, 'Địa chỉ', Icons.home),
                _buildDatePicker('Ngày sinh', _dob, (date) => setState(() => _dob = date)),
                _buildDatePicker('Ngày bắt đầu', _startDate, (date) => setState(() => _startDate = date)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.cancel),
                      label: Text('Hủy'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addEmployee,
                      icon: Icon(Icons.save),
                      label: _isLoading ? CircularProgressIndicator() : Text('Lưu Nhân Viên'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () => _selectDate(context, onDateSelected),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            date == null ? 'Chọn $label' : '${date.day}/${date.month}/${date.year}',
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
