import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_app_ver2/widgets/custom_textfield.dart';
import 'package:hr_app_ver2/widgets/custom_button.dart';
import 'package:hr_app_ver2/widgets/bottom_nav.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
       //  Chuyển màn hình với hiệu ứng Fade In
       Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => BottomNav(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 500), // ⏳ Thời gian hiệu ứng
            ),
          );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đã xảy ra lỗi";
      if (e.code == 'user-not-found') {
        errorMessage = "Tài khoản không tồn tại";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Mật khẩu không chính xác";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🔹 Logo to rõ hơn
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20), // ✅ Bo góc logo
                        child: Image.asset("assets/images/logo.png", height: 180), // ✅ Tăng kích thước
                      ),
                      SizedBox(height: 30),
                      // 🔹 Tên App
                      Text(
                        "Hooman",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                      SizedBox(height: 20),
                      // 🔹 Email
                      CustomTextField(
                        controller: _emailController,
                        hintText: "Nhập email của bạn",
                        label: "Email",
                        isPassword: false,
                      ),
                      SizedBox(height: 12),
                      // 🔹 Mật khẩu (Thêm hint)
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "Nhập mật khẩu",
                        label: "Mật khẩu",
                        isPassword: true,
                      ),
                      SizedBox(height: 10),
                      // 🔹 Quên mật khẩu
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Chuyển sang màn hình quên mật khẩu
                          },
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      // 🔹 Nút Login
                      _isLoading
                          ? CircularProgressIndicator()
                          : CustomButton(
                              onPressed: _login,
                              text: "Đăng nhập",
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
