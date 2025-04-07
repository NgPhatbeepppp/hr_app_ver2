// lib/screens/employee/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isCheckedIn = false;
  Timestamp? checkInTime;
  Timer? _timer;
  ValueNotifier<int> elapsedTimeNotifier = ValueNotifier<int>(0); // Dùng ValueNotifier để cập nhật thời gian

  @override
  void initState() {
    super.initState();
    _loadAttendanceStatus();
  }

  // Lưu trạng thái chấm công vào SharedPreferences
  Future<void> _saveAttendanceStatus(bool isCheckedIn, Timestamp? checkInTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCheckedIn', isCheckedIn);
    if (checkInTime != null) {
      await prefs.setString('checkInTime', checkInTime.toDate().toIso8601String());
    } else {
      await prefs.remove('checkInTime');
    }
  }

  // Tải trạng thái chấm công từ SharedPreferences và Firestore
  Future<void> _loadAttendanceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedIsCheckedIn = prefs.getBool('isCheckedIn');
    String? savedCheckInTime = prefs.getString('checkInTime');

    if (savedIsCheckedIn == true && savedCheckInTime != null) {
      setState(() {
        isCheckedIn = true;
        checkInTime = Timestamp.fromDate(DateTime.parse(savedCheckInTime));
      });
      _startTimer();
    } else {
      await _checkAttendanceStatus();
    }
  }

  Future<void> _checkAttendanceStatus() async {
    String userId = _auth.currentUser!.uid;
    var snapshot = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('checkInTime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var lastAttendance = snapshot.docs.first;
      if (lastAttendance['checkOutTime'] == null) {
        setState(() {
          isCheckedIn = true;
          checkInTime = lastAttendance['checkInTime'];
        });
        await _saveAttendanceStatus(true, checkInTime);
        _startTimer();
      }
    }
  }

  Future<void> _checkIn() async {
    String userId = _auth.currentUser!.uid;
    Position position = await Geolocator.getCurrentPosition();
    var docRef = await _firestore.collection('attendance').add({
      "userId": userId,
      "checkInTime": FieldValue.serverTimestamp(),
      "checkOutTime": null,
      "location": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      }
    });

    // Lấy lại thời gian check-in từ Firestore để đảm bảo chính xác
    var doc = await docRef.get();
    setState(() {
      isCheckedIn = true;
      checkInTime = doc['checkInTime'];
    });
    await _saveAttendanceStatus(true, checkInTime);
    _startTimer();
  }

  Future<void> _checkOut() async {
    String userId = _auth.currentUser!.uid;
    DateTime checkOutTime = DateTime.now();
    var snapshot = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('checkInTime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var lastAttendance = snapshot.docs.first;
      await _firestore.collection('attendance').doc(lastAttendance.id).update({
        "checkOutTime": checkOutTime,
      });
      setState(() {
        isCheckedIn = false;
        checkInTime = null;
        elapsedTimeNotifier.value = 0;
      });
      await _saveAttendanceStatus(false, null);
      _timer?.cancel();
    }
  }

  void _startTimer() {
    if (checkInTime == null) return;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedTimeNotifier.value = DateTime.now().difference(checkInTime!.toDate()).inSeconds;
    });
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    elapsedTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chấm công", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Nen_Cong.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Phần chấm công
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Thời gian làm việc",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(height: 10),
                      ValueListenableBuilder<int>(
                        valueListenable: elapsedTimeNotifier,
                        builder: (context, elapsedTime, child) {
                          return Text(
                            _formatDuration(elapsedTime),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 40),
                      InkWell(
                        onTap: () async {
                          if (isCheckedIn) {
                            await _checkOut();
                          } else {
                            await _checkIn();
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
                        splashColor: Colors.white.withOpacity(0.3),
                        highlightColor: Colors.transparent,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isCheckedIn ? Colors.red : Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isCheckedIn
                                    ? Colors.redAccent.withOpacity(0.5)
                                    : Colors.greenAccent.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isCheckedIn ? "KẾT THÚC" : "CHECK-IN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Phần lịch sử chấm công
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lịch sử chấm công gần đây",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('attendance')
                            .where('userId', isEqualTo: _auth.currentUser!.uid)
                            .orderBy('checkInTime', descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text("Lỗi: ${snapshot.error}"));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                "Chưa có lịch sử chấm công",
                                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                              ),
                            );
                          }

                          var attendanceDocs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: attendanceDocs.length,
                            itemBuilder: (context, index) {
                              var doc = attendanceDocs[index];
                              // Kiểm tra null cho checkInTime
                              if (doc['checkInTime'] == null) {
                                return Card(
                                  color: Colors.white.withOpacity(0.9),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text(
                                      "Dữ liệu không hợp lệ",
                                      style: TextStyle(fontSize: 14, color: Colors.red),
                                    ),
                                  ),
                                );
                              }

                              Timestamp checkIn = doc['checkInTime'];
                              Timestamp? checkOut = doc['checkOutTime'];
                              String checkInStr = DateFormat('dd/MM/yyyy HH:mm').format(checkIn.toDate());
                              String checkOutStr = checkOut != null
                                  ? DateFormat('dd/MM/yyyy HH:mm').format(checkOut.toDate())
                                  : "Chưa kết thúc";
                              int duration = checkOut != null
                                  ? checkOut.toDate().difference(checkIn.toDate()).inSeconds
                                  : 0;
                              String durationStr = checkOut != null ? _formatDuration(duration) : "-";

                              return Card(
                                color: Colors.white.withOpacity(0.9),
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    "Check-in: $checkInStr",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    "Check-out: $checkOutStr\nThời gian: $durationStr",
                                    style: TextStyle(fontSize: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}