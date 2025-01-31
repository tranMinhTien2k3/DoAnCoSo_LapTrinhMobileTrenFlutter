import 'package:appdemo/common/toast.dart';
import 'package:appdemo/widgets/form_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ForgotPW extends StatefulWidget {
  const ForgotPW({super.key});

  @override
  State<ForgotPW> createState() => _ForgotPWState();
}

class _ForgotPWState extends State<ForgotPW> {
  TextEditingController _emailController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  Future passwordReset() async{
    if (_emailController.text.trim().isEmpty) {
      showToast(message: "Vui lòng nhập địa chỉ email của bạn");
      return; 
    }
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      showToast(message: "Đã xác nhận! ");
    }on FirebaseAuthException catch (e){
      print(e);
      showToast(message: "some error occured $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        title:const Text('Lấy lại mật khẩu'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Thêm khoảng cách xung quanh các thành phần
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn chỉnh theo chiều ngang
          children: [
            SizedBox(height: 20), // Thêm khoảng cách giữa các thành phần
            Text(
              'Nhập email của bạn:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: () {
                  passwordReset();
                },
                child: Text('Reset password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}