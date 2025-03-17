import 'package:flutter/material.dart';
import '../models/employee_model.dart';
import '../services/firestore_service.dart';

class EmployeeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  void fetchEmployees() {
    _firestoreService.getEmployees().listen((employees) {
      _employees = employees;
      notifyListeners();
    });
  }

  Future<void> addEmployee(Employee employee) async {
    await _firestoreService.addEmployee(employee);
    fetchEmployees();
  }

  Future<void> updateEmployee(String id, Employee employee) async {
    await _firestoreService.updateEmployee(id, employee);
    fetchEmployees();
  }

  Future<void> deleteEmployee(String id) async {
    await _firestoreService.deleteEmployee(id);
    fetchEmployees();
  }
}
