import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isCheckedIn = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAttendanceStatus();
  }

  Future<void> _checkAttendanceStatus() async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    var snapshot = await _firestore
        .collection('employees')
        .doc(userId)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var lastAttendance = snapshot.docs.first;
      setState(() {
        isCheckedIn = lastAttendance['status'] == 'Check-in';
      });
    }
  }

  Future<Position?> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Bạn cần cấp quyền GPS để chấm công!");
        return null;
      }
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _handleAttendance() async {
    setState(() => isLoading = true);
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    Position? position = await _getUserLocation();
    if (position == null) {
      setState(() => isLoading = false);
      return;
    }

    String status = isCheckedIn ? "Check-out" : "Check-in";
    await _firestore.collection('employees').doc(userId).collection('attendance').add({
      "timestamp": Timestamp.now(),
      "status": status,
      "latitude": position.latitude,
      "longitude": position.longitude,
    });

    setState(() {
      isCheckedIn = !isCheckedIn;
      isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildAttendanceHistory() {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return Center(child: Text("Không tìm thấy tài khoản"));

    return StreamBuilder(
      stream: _firestore
          .collection('employees')
          .doc(userId)
          .collection('attendance')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Chưa có dữ liệu chấm công."));
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(
                data['status'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(data['timestamp'].toDate())}"),
              leading: Icon(
                data['status'] == "Check-in" ? Icons.login : Icons.logout,
                color: data['status'] == "Check-in" ? Colors.green : Colors.red,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chấm công")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              isCheckedIn ? "Bạn đã Check-in" : "Bạn chưa chấm công",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _handleAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isCheckedIn ? "Kết thúc ca" : "Chấm công",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            SizedBox(height: 30),
            Divider(),
            Text("Lịch sử chấm công gần đây", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(child: _buildAttendanceHistory()),
          ],
        ),
      ),
    );
  }
}
