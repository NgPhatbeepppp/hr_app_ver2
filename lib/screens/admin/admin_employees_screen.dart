import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/employee_model.dart';
import '../../screens//wed/employee_detail_screen.dart';
import 'add_employee_screen.dart';

class AdminEmployeesScreen extends StatefulWidget {
  @override
  _AdminEmployeesScreenState createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _filterStatus = "Tất cả";

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

void _deleteEmployee(String employeeId) async {
  await _firestore.collection('employees').doc(employeeId).update({
    'status': 'Đã xóa',
    'deletedAt': FieldValue.serverTimestamp(),
  });
  setState(() {}); // Cập nhật lại danh sách hiển thị
}




  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bộ lọc", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              ListTile(
                title: Text("Tất cả"),
                trailing: _filterStatus == "Tất cả" ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _filterStatus = "Tất cả");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Đang làm việc"),
                trailing: _filterStatus == "Đang làm việc" ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _filterStatus = "Đang làm việc");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Nghỉ việc"),
                trailing: _filterStatus == "Nghỉ việc" ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _filterStatus = "Nghỉ việc");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Đã xóa"),
                trailing: _filterStatus == "Đã xóa" ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _filterStatus = "Đã xóa");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Nhân Viên')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Tìm kiếm nhân viên",
                      hintText: "Nhập tên, email hoặc chức vụ...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: _updateSearchQuery,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.blue),
                  onPressed: _openFilterSheet,
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('employees').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Không có nhân viên nào.'));
                  }

                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var employee = Employee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    bool matchesSearch = employee.name.toLowerCase().contains(_searchQuery) ||
                        employee.email.toLowerCase().contains(_searchQuery);
                    bool matchesFilter = _filterStatus == "Tất cả" || employee.status == _filterStatus;
                    return matchesSearch && matchesFilter;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      Employee employee = Employee.fromMap(
                        filteredDocs[index].data() as Map<String, dynamic>,
                        filteredDocs[index].id,
                      );
                      return _buildEmployeeCard(employee);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEmployeeScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(employee.name[0], style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(employee.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text("${employee.position} - ${employee.status}", style: GoogleFonts.poppins(color: Colors.grey[600])),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteEmployee(employee.id),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeDetailScreen(employee: employee)),
          );
        },
      ),
    );
  }
}
