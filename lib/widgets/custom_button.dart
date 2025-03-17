import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16), // ✅ Lớn hơn để dễ bấm
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        backgroundColor: Colors.blue[400], // ✅ Màu xanh dương nhẹ
        foregroundColor: Colors.white, // ✅ Màu chữ trắng
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // ✅ Bo góc mềm mại
        ),
        elevation: 5, // ✅ Đổ bóng nhẹ khi chưa nhấn
        shadowColor: Colors.blueAccent.withOpacity(0.5),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2, // ✅ Hiệu ứng loading nhỏ gọn hơn
              ),
            )
          : Text(text),
    );
  }
}
