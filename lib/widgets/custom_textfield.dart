import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;
  final String hintText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText, // ✅ Thêm gợi ý nhập
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // ✅ Bo góc mềm mại
          borderSide: BorderSide(color: Colors.grey.shade400), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2), // ✅ Viền xanh khi focus
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // ✅ Thoải mái hơn
        prefixIcon: widget.isPassword
            ? Icon(Icons.lock_outline, color: Colors.grey.shade600) // ✅ Thêm icon khóa nếu là mật khẩu
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured; // ✅ Bật/tắt hiển thị mật khẩu
                  });
                },
              )
            : null,
      ),
    );
  }
}
