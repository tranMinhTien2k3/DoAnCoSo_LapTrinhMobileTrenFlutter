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
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      showToast(message: "Password reset link sent! Check your email");
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Text('enter Your Email:'),
          FormContainerWidget(
                controller: _emailController,
                hintText: "Your email",
              ),
          MaterialButton(
            onPressed: (){
              passwordReset();
            },
            child: Text('Reset password'),
            color: Colors.blue,
          ),
        ],
        ),
    );
  }
}