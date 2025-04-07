// lib/screens/employees_screen.dart 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Thêm animate_do

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.shade700,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                duration: Duration(milliseconds: 800),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Danh sách nhân viên",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              // Thanh tìm kiếm
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    style: GoogleFonts.poppins(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      hintText: "Tìm kiếm nhân viên...",
                      hintStyle: GoogleFonts.poppins(color: Colors.black54),
                      prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              // Dropdown chọn chức vụ
             
                  FadeInUp(
                    duration: Duration(milliseconds: 1100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('employees').snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(); // Nếu chưa có data thì ẩn dropdown
                          }

                          // 📌 Lấy danh sách chức vụ duy nhất
                          List<String> positions = snapshot.data!.docs
                              .map((doc) => doc['position'].toString())
                              .toSet()
                              .toList();
                          positions.insert(0, "Tất cả"); // Thêm lựa chọn "Tất cả"

                          return DropdownButtonFormField<String>(
                            value: selectedPosition,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.95),
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.3), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              prefixIcon: Icon(
                                Icons.filter_list,
                                color: Colors.blueAccent,
                                size: 24,
                              ),
                              labelText: "Lọc theo chức vụ",
                              labelStyle: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            hint: Text(
                              "Chọn chức vụ",
                              style: GoogleFonts.poppins(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            items: positions.map((pos) {
                              return DropdownMenuItem<String>(
                                value: pos,
                                child: Text(
                                  pos,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: pos == selectedPosition ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPosition = value.toString();
                              });
                            },
                            dropdownColor: Colors.white.withOpacity(0.95),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blueAccent,
                              size: 28,
                            ),
                            elevation: 8, // Thêm độ nâng cho dropdown menu
                            borderRadius: BorderRadius.circular(12), // Bo góc cho dropdown menu
                            menuMaxHeight: 300, // Giới hạn chiều cao tối đa của menu
                          );
                        },
                      ),
                    ),
                  ),
              // Danh sách nhân viên
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('employees').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: Text(
                            "Không có nhân viên nào.",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }

                    // 🔍 Lọc danh sách theo tìm kiếm & chức vụ
                    var employees = snapshot.data!.docs.where((doc) {
                      bool matchesName = doc['name'].toLowerCase().contains(searchQuery);
                      bool matchesPosition =
                          selectedPosition == "Tất cả" || doc['position'] == selectedPosition;
                      return matchesName && matchesPosition;
                    }).toList();

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        var employee = employees[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 800 + (index * 100)),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  employee['name'][0],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                employee['name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    "Chức vụ: ${employee['position']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "Liên hệ: ${employee['phone']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.phone, color: Colors.green),
                              onTap: () {
                                // Có thể thêm hành động khi nhấn vào nhân viên
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
