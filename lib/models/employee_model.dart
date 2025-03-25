import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  String id;
  String name;
  String email;
  String position;
  double salary;
  String phone;
  String address;
  String dob;
  String startDate;
  String status;  
  String role;


  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.salary,
    required this.phone,
    required this.address,
    required this.dob,
    required this.startDate,
    required this.status,
    required this.role,
  });

  /// Chuyển dữ liệu từ Firestore thành object `Employee`
  factory Employee.fromMap(Map<String, dynamic> data, String documentId) {
    return Employee(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      position: data['position'] ?? '',
      salary: (data['salary'] is int)
          ? (data['salary'] as int).toDouble()
          : (data['salary'] ?? 0.0),
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      dob: data['dob'] ?? '',
      startDate: data['startDate'] ?? '',
      status: data['status'] ?? '',
      role: data['role'] ?? '',
    );
  }

  /// Chuyển object `Employee` thành `Map` để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'position': position,
      'salary': salary,
      'phone': phone,
      'address': address,
      'dob': dob,
      'startDate': startDate,
      'status': status,
      'role': role,
    };
  }
}
