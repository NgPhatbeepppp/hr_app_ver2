const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.calculateSalaries = functions.pubsub.schedule("every 1st of month 00:00")
    .timeZone("Asia/Ho_Chi_Minh")
    .onRun(async (context) => {
      console.log("🔄 Bắt đầu tính lương...");

      try {
        const employeesSnapshot = await db.collection("employees").get();
        const lastMonth = getLastMonthYear();
        const startOfLastMonth = getFirstDayOfLastMonth();
        const startOfThisMonth = getFirstDayOfThisMonth();

        for (const employeeDoc of employeesSnapshot.docs) {
          const employeeData = employeeDoc.data();
          const employeeId = employeeDoc.id;
          const monthlySalary = employeeData.salary || 0; // Lương tháng

          console.log(`📌 Tính lương cho ${employeeId} tháng ${lastMonth}`);

          // Lấy danh sách chấm công tháng trước
          const attendanceSnapshot = await db.collection("employees")
              .doc(employeeId)
              .collection("attendance")
              .where("checkInTime", ">=", admin.firestore.Timestamp.fromDate(startOfLastMonth))
              .where("checkInTime", "<", admin.firestore.Timestamp.fromDate(startOfThisMonth))
              .get();

          let totalHours = 0;
          const workDays = new Set(); // Đếm số ngày làm việc thực tế

          attendanceSnapshot.forEach((doc) => {
            const data = doc.data();
            if (data.checkInTime && data.checkOutTime) {
              const checkIn = data.checkInTime.toDate();
              const checkOut = data.checkOutTime.toDate();
              const hoursWorked = (checkOut - checkIn) / (1000 * 60 * 60);
              totalHours += hoursWorked;

              // Lưu lại ngày làm việc (để không trùng lặp)
              workDays.add(checkIn.toISOString().split("T")[0]);
            }
          });

          const totalWorkDays = workDays.size; // Số ngày làm việc thực tế
          const avgHoursPerDay = totalWorkDays > 0 ? totalHours / totalWorkDays : 8; // Giả định 8h nếu không có dữ liệu
          const expectedWorkDays = getExpectedWorkDays(startOfLastMonth); // Số ngày làm việc chuẩn của tháng
          const expectedWorkHours = expectedWorkDays * avgHoursPerDay; // Giờ làm chuẩn

          // Tính lương dựa trên tổng số giờ làm thực tế
          const totalSalary = (totalHours / expectedWorkHours) * monthlySalary;

          console.log(`✅ Nhân viên ${employeeId}: Làm ${totalHours.toFixed(2)} giờ, lương = ${totalSalary.toFixed(2)}`);

          // Lưu kết quả vào Firestore
          await db.collection("salaries").doc(`${employeeId}_${lastMonth}`).set({
            employeeId,
            month: lastMonth,
            totalHours: totalHours.toFixed(2),
            totalSalary: totalSalary.toFixed(2),
            workDays: totalWorkDays,
            expectedWorkHours: expectedWorkHours.toFixed(2),
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        console.log("🎉 Tính lương hoàn tất!");
      } catch (error) {
        console.error("❌ Lỗi khi tính lương:", error);
      }
    });

/**
 * Lấy ngày đầu tiên của tháng trước.
 * @return {Date} Ngày đầu tiên của tháng trước.
 */
function getFirstDayOfLastMonth() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth() - 1, 1);
}

/**
   * Lấy ngày đầu tiên của tháng hiện tại.
   * @return {Date} Ngày đầu tiên của tháng này.
   */
function getFirstDayOfThisMonth() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

/**
   * Lấy chuỗi định dạng "YYYY-MM" của tháng trước.
   * @return {string} Chuỗi "YYYY-MM" của tháng trước.
   */
function getLastMonthYear() {
  const now = new Date();
  now.setMonth(now.getMonth() - 1);
  return `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, "0")}`;
}

/**
   * Tính số ngày làm việc (loại trừ thứ 7, chủ nhật) trong tháng.
   * @param {Date} startDate - Ngày bắt đầu tính.
   * @return {number} Số ngày làm việc trong tháng.
   */
function getExpectedWorkDays(startDate) {
  const date = new Date(startDate);
  let workDays = 0;
  while (date.getMonth() === startDate.getMonth()) {
    const day = date.getDay();
    if (day !== 0 && day !== 6) { // Không tính thứ 7, chủ nhật
      workDays++;
    }
    date.setDate(date.getDate() + 1);
  }
  return workDays;
}
