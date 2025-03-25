import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // ✅ Tránh lỗi nếu widget đã bị gỡ bỏ

    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? "";
        _passwordController.text = prefs.getString('savedPassword') ?? "";
      }
    });
  }

  void _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _emailController.text);
      await prefs.setString('savedPassword', _passwordController.text);
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _saveRememberMe();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => BottomNav(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: Duration(milliseconds: 500),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đã xảy ra lỗi";
      if (e.code == 'user-not-found') {
        errorMessage = "Tài khoản không tồn tại";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Mật khẩu không chính xác";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset("assets/images/logo.png", height: 160),
                      ),
                      SizedBox(height: 20),

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

                      // 🔹 Mật khẩu
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "Nhập mật khẩu",
                        label: "Mật khẩu",
                        isPassword: true,
                      ),
                      SizedBox(height: 12),

                      // 🔹 Checkbox "Ghi nhớ đăng nhập" + "Quên mật khẩu"
                      // 🔹 Checkbox "Ghi nhớ đăng nhập"
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          Text(
                            "Ghi nhớ đăng nhập",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      // 🔹 "Quên mật khẩu?" được đẩy xuống dưới
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),

                      SizedBox(height: 25),

                      // 🔹 Nút Đăng nhập
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
