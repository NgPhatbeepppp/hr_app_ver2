import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class FirestoreService {
  final CollectionReference employeesRef =
      FirebaseFirestore.instance.collection('employees');

  Future<void> addEmployee(Employee employee) async {
    await employeesRef.add(employee.toMap());
  }

  Future<void> updateEmployee(String id, Employee employee) async {
    await employeesRef.doc(id).update(employee.toMap());
  }

  Future<void> deleteEmployee(String id) async {
    await employeesRef.doc(id).delete();
  }

  Stream<List<Employee>> getEmployees() {
    return employeesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Employee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
