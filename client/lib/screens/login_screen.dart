import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController(); // ID 입력 컨트롤러
  final ApiService _apiService = ApiService(); // API 서비스 객체

  bool _isLoading = false; // 로딩 상태 표시

  void _handleLogin() async {
    final id = _idController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ID is required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.login(id);

      if (response['status'] == 'success') {
        // 로그인 성공 시 ID를 저장하고 홈 화면으로 이동
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: id, // userId 전달
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 요소 추가 (타원형)
          Positioned(
            left: 800,
            top: 0,
            child: Container(
              width: 1024,
              height: 1024,
              decoration: ShapeDecoration(
                color: Color(0xFF26CE7F),
                shape: OvalBorder(),
              ),
            ),
          ),
          Positioned(
            left: 974,
            top: 0,
            child: Container(
              width: 1024,
              height: 1024,
              decoration: ShapeDecoration(
                color: Color(0xFF31937B),
                shape: OvalBorder(),
              ),
            ),
          ),
          // 내용 영역
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 로고 추가
                    Image.asset(
                      'images/logo_eodirok1.png', // 로고 이미지 경로
                      height: 100, // 로고 높이
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 30),
                    Text(
                  "우리 프로젝트.. 어디로 가고 있지? 어디록!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                      ),
                     // 로고와 입력 박스 간 간격
                     SizedBox(height: 100),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ID 입력
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ID",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _idController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFFD9D9D9)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Enter your ID',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // 로그인 버튼
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF31937B),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: _handleLogin,
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
