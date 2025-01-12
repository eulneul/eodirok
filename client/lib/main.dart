import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어디록',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // 라우트 정의
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(), // HomeScreen 경로 추가
        '/upload': (context) => HomeScreen(),
        '/record': (context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String; // userId 전달
    return RecordScreen(userId: userId);
  },
      },
    );
  }
}
