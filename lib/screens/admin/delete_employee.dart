import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/employee_model.dart';

class DeleteEmployee extends StatefulWidget {
  @override
  _TrashEmployeesScreenState createState() => _TrashEmployeesScreenState();
}

class _TrashEmployeesScreenState extends State<DeleteEmployee> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _restoreEmployee(String employeeId) async {
    await _firestore.collection('employees').doc(employeeId).update({
      'status': 'Đang làm việc'
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nhân viên đã được khôi phục!")));
  }

  void _deletePermanently(String employeeId) async {
    bool confirmDelete = await _showConfirmDialog();
    if (confirmDelete) {
      await _firestore.collection('employees').doc(employeeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nhân viên đã bị xóa vĩnh viễn!")));
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có chắc chắn muốn xóa nhân viên này vĩnh viễn?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách tài khoản đã xóa')),
      body: StreamBuilder(
        stream: _firestore.collection('employees').where('status', isEqualTo: 'Đã xóa').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có nhân viên nào trong thùng rác.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Employee employee = Employee.fromMap(
                snapshot.data!.docs[index].data() as Map<String, dynamic>,
                snapshot.data!.docs[index].id,
              );
              return ListTile(
                title: Text(employee.name),
                subtitle: Text(employee.position),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.restore, color: Colors.green),
                      onPressed: () => _restoreEmployee(employee.id),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePermanently(employee.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
