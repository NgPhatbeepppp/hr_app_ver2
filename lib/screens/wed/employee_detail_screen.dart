import 'package:flutter/material.dart';
import 'package:hr_app_ver2/models/employee_model.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  EmployeeDetailScreen({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết nhân viên"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Chuyển sang trang chỉnh sửa (nếu có)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person, "Họ và tên", employee.name),
                _buildInfoRow(Icons.work, "Chức vụ", employee.position),
                _buildInfoRow(Icons.email, "Email", employee.email),
                _buildInfoRow(Icons.phone, "Số điện thoại", employee.phone),
                _buildInfoRow(Icons.home, "Địa chỉ", employee.address),
                _buildInfoRow(Icons.calendar_today, "Ngày sinh", employee.dob),
                _buildInfoRow(Icons.date_range, "Ngày bắt đầu", employee.startDate),
                _buildStatusRow(employee.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10),
          Expanded(child: Text("$label: $value", style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: status == "Đang làm việc" ? Colors.green : Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Trạng thái: $status",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: status == "Đang làm việc" ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
