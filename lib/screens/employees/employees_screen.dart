import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String searchQuery = ""; // 🔍 Biến lưu nội dung tìm kiếm
  String selectedPosition = "Tất cả"; // 🏢 Lọc theo chức vụ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách nhân viên')),
      body: Column(
        children: [
          // ✅ Thanh tìm kiếm
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Tìm kiếm nhân viên...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // ✅ Dropdown chọn chức vụ
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('employees').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return SizedBox(); // Nếu chưa có data thì ẩn dropdown

                // 📌 Lấy danh sách chức vụ duy nhất
                List<String> positions = snapshot.data!.docs
                    .map((doc) => doc['position'].toString())
                    .toSet()
                    .toList();
                positions.insert(0, "Tất cả"); // Thêm lựa chọn "Tất cả"

                return DropdownButtonFormField(
                  value: selectedPosition,
                  items: positions.map((pos) {
                    return DropdownMenuItem(value: pos, child: Text(pos));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPosition = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 10), // Khoảng cách

          // ✅ Danh sách nhân viên
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('employees').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Không có nhân viên nào.'));
                }

                // 🔍 Lọc danh sách theo tìm kiếm & chức vụ
                var employees = snapshot.data!.docs.where((doc) {
                  bool matchesName = doc['name'].toLowerCase().contains(searchQuery);
                  bool matchesPosition = selectedPosition == "Tất cả" || doc['position'] == selectedPosition;
                  return matchesName && matchesPosition;
                }).toList();

                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    var employee = employees[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          employee['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Chức vụ: ${employee['position']}\nLiên hệ: ${employee['phone']}'),
                        trailing: Icon(Icons.phone, color: Colors.green),
                        onTap: () {
                          
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
