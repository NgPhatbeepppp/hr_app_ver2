// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Thêm package animate_do để tạo animation

class AboutScreen extends StatelessWidget {
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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với nút quay lại
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FadeInDown(
                        duration: Duration(milliseconds: 800),
                        child: Text(
                          "Thông tin",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Phần giới thiệu ứng dụng
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.business_center,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Ứng dụng quản lý nhân sự",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Ứng dụng này được thiết kế để hỗ trợ quản lý nhân sự một cách hiệu quả, bao gồm các tính năng như quản lý nghỉ phép, tính lương, và gửi thông báo cho nhân viên và quản trị viên. Chúng tôi cam kết mang lại giải pháp tối ưu, giúp doanh nghiệp vận hành trơn tru và chuyên nghiệp.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Phần đội ngũ phát triển
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Đội ngũ phát triển",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  FadeInUp(
                    duration: Duration(milliseconds: 1400),
                    child: _buildTeamMemberCard(context, "Phát", "Lập trình viên"),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: _buildTeamMemberCard(context, "Vy", "Thiết kế giao diện"),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1600),
                    child: _buildTeamMemberCard(context, "Châu", "Quản lý dự án"),
                  ),
                  SizedBox(height: 30),

                  // Phần đơn vị thực hiện
                  FadeInUp(
                    duration: Duration(milliseconds: 1800),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white.withOpacity(0.95),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Đơn vị thực hiện",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Đại học Ngoại ngữ và Tin học Thành phố Hồ Chí Minh (HUFLIT)",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Footer
                  FadeInUp(
                    duration: Duration(milliseconds: 2000),
                    child: Center(
                      child: Text(
                        "© 2025 HR App. All rights reserved.",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(BuildContext context, String name, String role) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white.withOpacity(0.95),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blueAccent,
          child: Text(
            name[0],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          role,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}