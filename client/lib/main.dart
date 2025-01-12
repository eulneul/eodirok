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
        useMaterial3: true, // Material 3 사용
        fontFamily: 'Pretendard', // 전체 폰트 설정
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF31937B), // 기본 색상
          primary: Color(0xFF31937B),
          secondary: Color(0xFF9CD49F),
        ),
        scaffoldBackgroundColor: Color(0xFFE8F5E9), // 전체 배경 색상
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF31937B), // AppBar 배경 색상
          foregroundColor: Colors.white, // AppBar 텍스트 색상
          titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF31937B), // 버튼 배경 색상
            foregroundColor: Colors.white, // 버튼 텍스트 색상
            textStyle: TextStyle(fontSize: 16.0),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87), 
          bodyMedium: TextStyle(color: Colors.black54), 
          titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF31937B),
          ),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: Color(0xFF9CD49F), // 리스트 타일 배경 색상
          textColor: Colors.black87, // 리스트 타일 텍스트 색상
          iconColor: Colors.white, // 리스트 타일 아이콘 색상
        ),
        dividerColor: Color(0xFF9CD49F), // 구분선 색상
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/upload': (context) => HomeScreen(),
        '/record': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return RecordScreen(userId: userId);
        },
      },
    );
  }
}
