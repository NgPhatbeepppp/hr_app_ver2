import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  int elapsedTime = 0;

  @override
  void initState() {
    super.initState();
    _checkAttendanceStatus();
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
        _startTimer();
      }
    }
  }

  Future<void> _checkIn() async {
    String userId = _auth.currentUser!.uid;
    Position position = await Geolocator.getCurrentPosition();
    await _firestore.collection('attendance').add({
      "userId": userId,
      "checkInTime": FieldValue.serverTimestamp(),
      "checkOutTime": null,
      "location": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      }
    });
    setState(() {
      isCheckedIn = true;
    });
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
        elapsedTime = 0;
      });
      _timer?.cancel();
    }
  }

  void _startTimer() {
    if (checkInTime == null) return;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime = DateTime.now().difference(checkInTime!.toDate()).inSeconds;
      });
    });
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chấm công", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Nen_Cong.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Thời gian làm việc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(_formatDuration(elapsedTime), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
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
                          color: isCheckedIn ? Colors.redAccent.withOpacity(0.5) : Colors.greenAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isCheckedIn ? "KẾT THÚC" : "CHECK-IN",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
