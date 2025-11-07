import 'package:flutter/material.dart';
import 'package:mtandao_app/providers/resource_provder.dart';

import 'package:mtandao_app/screens/Authentication/login_page.dart';
import 'package:mtandao_app/screens/Authentication/register_page.dart';
import 'package:mtandao_app/screens/Authentication/welcome_screen.dart';
import 'package:mtandao_app/screens/student/examination/download_provider.dart';
import 'package:mtandao_app/screens/student/examination/past_papers.dart';
import 'package:mtandao_app/screens/student/examination/tests/online_tests.dart';
import 'package:mtandao_app/screens/student/examination/quiz.dart';
import 'package:mtandao_app/providers/test_provider.dart';
import 'package:mtandao_app/screens/student/exams.dart';
import 'package:mtandao_app/screens/student/home_page.dart';
import 'package:mtandao_app/screens/student/resources_page.dart';
import 'package:mtandao_app/screens/Authentication/subscription_page.dart';
import 'package:mtandao_app/screens/teacher/TeacherDashboard.dart';
import 'package:mtandao_app/providers/teacher_test_provider.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
        ChangeNotifierProvider(create: (_) => TeacherTestProvider()),
        ChangeNotifierProvider(create: (_) => ResourceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: TeacherDashboard(),
      // theme: ThemeData.dark(),

      //all page routes
      routes: {
        //all users
        "/register": (context) => Registerpage(),
        "/login": (context) => LoginPage(),
        "/payment": (context) => SubscriptionPage(),
        //for student
        "/home": (context) => HomePage(),
        //"/Studentprofile": => ProfilePage(),
        "/exams": (context) => Exams(),
        "/resources": (context) => StudentResourcesPage(),
        "/tests": (context) => OnlineTestsPage(),
        "/quizes": (context) => Quiz(),
        "pastpapers": (context) => PastPapers(),
      },
    );
  }
}
