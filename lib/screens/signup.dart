import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appdemo/services/firebase_auth_services.dart';
import 'package:appdemo/widgets/form_container.dart';
import 'package:appdemo/common/toast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _fistnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _comfirmpasswordController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _fistnameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _comfirmpasswordController.dispose();
    super.dispose();
  }

  

  bool passwordConfirmed(){
    if(_passwordController.text.trim() == _comfirmpasswordController.text.trim()){
      return true;
    }else return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _fistnameController,
                hintText: "fistName",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _lastnameController,
                hintText: "lastName",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _ageController,
                hintText: "age",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _comfirmpasswordController,
                hintText: "Comfirm Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap:  (){
                  _signUp();

                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: isSigningUp ? CircularProgressIndicator(color: Colors.white,):Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
 Future addUserDetails(String fistName, String lastName, String email, int age, String Id) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
      await usersCollection.doc(Id).set({
        'fist name': fistName,
        'last name': lastName,
        'email': email,
        'age': age,
        'address':"",
        'phone':"",
      });
    }
  void _signUp() async {
    if(passwordConfirmed()){
      setState(() {
       isSigningUp = true;
      });

    String email = _emailController.text;
    String password = _passwordController.text;
    String fistName = _fistnameController.text;
    String lastName = _lastnameController.text;
    int age = int.parse(_ageController.text);

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    String userId = userCredential.user!.uid;
    addUserDetails(fistName, lastName, email, age, userId);
    setState(() {
     isSigningUp = false;
    });
    if (user != null) {
      showToast(message: "User is successfully created");
      Navigator.pushNamed(context, "/home");
    } else {
      showToast(message: "Some error happend");
    }
    }else{
      showToast(message: "password re-enter does not match");
    }
  }
}