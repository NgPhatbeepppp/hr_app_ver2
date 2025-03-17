import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/employee_model.dart';
import '../../screens//wed/employee_detail_screen.dart';

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

  void _updateFilter(String? status) {
    setState(() {
      _filterStatus = status ?? "Tất cả";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Nhân Viên')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Thanh tìm kiếm + bộ lọc
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
                DropdownButton<String>(
                  value: _filterStatus,
                  items: ["Tất cả", "Đang làm việc", "Nghỉ việc"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _updateFilter,
                ),
              ],
            ),
            SizedBox(height: 10),

            // ✅ Danh sách nhân viên
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

                  // ✅ Lọc dữ liệu
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var employee = Employee.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    bool matchesSearch = employee.name.toLowerCase().contains(_searchQuery) ||
                        employee.email.toLowerCase().contains(_searchQuery) ||
                        employee.position.toLowerCase().contains(_searchQuery);
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
        onPressed: () => _showAddEmployeeDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // ✅ Widget hiển thị nhân viên dưới dạng Card UI đẹp hơn
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
        trailing: Text('${employee.salary} VND', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeDetailScreen(employee: employee)),
          );
        },
      ),
    );
  }

  // ✅ Dialog thêm nhân viên UI đẹp hơn
  void _showAddEmployeeDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController positionController = TextEditingController();
    TextEditingController salaryController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    TextEditingController startDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm Nhân Viên', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, 'Tên'),
                _buildTextField(emailController, 'Email'),
                _buildTextField(positionController, 'Chức vụ'),
                _buildTextField(salaryController, 'Lương', keyboardType: TextInputType.number),
                _buildTextField(phoneController, 'SĐT'),
                _buildTextField(addressController, 'Địa chỉ'),
                _buildTextField(dobController, 'Ngày sinh'),
                _buildTextField(startDateController, 'Ngày bắt đầu'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) return;

                Employee newEmployee = Employee(
                  id: '',
                  name: nameController.text,
                  email: emailController.text,
                  position: positionController.text,
                  salary: double.tryParse(salaryController.text) ?? 0.0,
                  phone: phoneController.text,
                  address: addressController.text,
                  dob: dobController.text,
                  startDate: startDateController.text,
                  status: 'Đang làm việc',
                );

                DocumentReference docRef = await _firestore.collection('employees').add(newEmployee.toMap());
                await docRef.update({'id': docRef.id});

                Navigator.pop(context);
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  // ✅ Widget tạo TextField tái sử dụng
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: keyboardType,
      ),
    );
  }
}
