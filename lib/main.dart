import 'package:appdemo/screens/CreateContent.dart';
import 'package:appdemo/screens/fgpassw.dart';
import 'package:appdemo/screens/login.dart';
import 'package:appdemo/screens/myContent.dart';
import 'package:appdemo/screens/notification.dart';
import 'package:appdemo/screens/profile_screen.dart';
import 'package:appdemo/screens/schedule_detail.dart';
import 'package:appdemo/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:appdemo/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              return LoginPage();
            }
          }
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
        '/profile':(context)=> ProfileScreen(),
        '/schedule':(context)=> ScheduleScreen(),
        '/notifucation':(context) => Notifucation(),
        '/content':(context) =>CreateContent(),
        '/fwp':(context) =>ForgotPW(),
        '/mycontent':(context) => Mycontent(),
      },  
    );   
  }
}     