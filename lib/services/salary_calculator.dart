// lib/services/salary_calculator.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryCalculator {
  static Future<void> calculateSalariesForMonth({
    required String month, // Định dạng "YYYY-MM"
    double standardHoursPerMonth = 176.0, // 8 giờ/ngày × 22 ngày
  }) async {
    try {
      // Xác định khoảng thời gian của tháng
      final monthParts = month.split('-');
      final year = int.parse(monthParts[0]);
      final monthNum = int.parse(monthParts[1]);
      final startOfMonth = DateTime(year, monthNum, 1);
      final endOfMonth = DateTime(year, monthNum + 1, 0);

      // Lấy danh sách nhân viên
      final employeesSnapshot = await FirebaseFirestore.instance.collection('employees').get();
      if (employeesSnapshot.docs.isEmpty) {
        throw Exception("Không có nhân viên nào để tính lương");
      }

      // Tính lương cho từng nhân viên
      for (var employee in employeesSnapshot.docs) {
        String userId = employee.id;
        double baseSalary = employee['salary']?.toDouble() ?? 0.0;

        // Lấy dữ liệu chấm công
        final attendanceSnapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .where('userId', isEqualTo: userId)
            .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
            .where('checkInTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
            .get();

        // Tính tổng số giờ làm việc
        double totalHours = 0.0;
        for (var doc in attendanceSnapshot.docs) {
          Timestamp checkIn = doc['checkInTime'];
          Timestamp? checkOut = doc['checkOutTime'];
          if (checkOut != null) {
            totalHours += checkOut.toDate().difference(checkIn.toDate()).inHours.toDouble();
          }
        }

        // Tính lương
        double hourlySalary = baseSalary / standardHoursPerMonth;
        double calculatedSalary = totalHours * hourlySalary;

        // Lưu vào salaries
        String salaryDocId = "${userId}_$month";
        await FirebaseFirestore.instance.collection('salaries').doc(salaryDocId).set({
          'userId': userId,
          'month': month,
          'salary': calculatedSalary,
          'totalHours': totalHours,
          'calculatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Merge để không ghi đè nếu đã có
      }

      print("Đã tính lương cho tháng $month");
    } catch (e) {
      print("Lỗi khi tính lương: $e");
      throw e; // Ném lỗi để xử lý ở nơi gọi
    }
  }
}