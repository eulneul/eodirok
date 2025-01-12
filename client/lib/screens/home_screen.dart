import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userId; // userId를 저장할 변수
  List<dynamic>? _jsonData; // JSON 데이터를 저장할 변수

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  // 전달받은 arguments에서 userId 추출
  userId = ModalRoute.of(context)?.settings.arguments as String?;

  // userId가 null인 경우 메시지 표시
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("사용자 ID를 가져오는 데 실패했습니다.")),
    );
  } else {
    // 필요한 경우 userId로 추가 작업 수행 가능
    print("Logged in as: $userId");
  }
}
  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'], // 허용할 파일 확장자
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.single.bytes;
        String? fileName = result.files.single.name;

        if (fileBytes != null) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('http://127.0.0.1:5000/upload'),
          );
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ));

          var response = await request.send();

          if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            List<dynamic> jsonData = json.decode(responseData);

            // JSON 데이터를 상태에 저장
            setState(() {
              _jsonData = jsonData;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("파일 업로드 성공! JSON 데이터가 업데이트되었습니다.")),
            );
          } else {
            var responseError = await response.stream.bytesToString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("파일 업로드 실패! 서버 에러: $responseError"),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("파일이 비어 있습니다.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("파일 선택이 취소되었습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파일 업로드 실패: $e")),
      );
    }
  }

  Future<List<dynamic>> _sendDataToServerForSummary() async {
    if (_jsonData == null) {
      throw Exception("요약할 데이터가 없습니다. 파일을 업로드하세요.");
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/archives/extract_topics_from_descriptions'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(_jsonData), // JSON 데이터를 서버로 전송
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // 요약 결과를 반환
    } else {
      throw Exception('Failed to get summary from server: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 제거
      ),
      body: Stack(
        children: [
          // 배경 요소
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
          // 메인 내용
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    "우리 프로젝트.. 어디로 가고 있지? 어디록!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      color: Color(0xFF31937B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () => _pickAndUploadFile(context),
                    child: Text("파일 업로드"),
                  ),
                  SizedBox(height: 20),
                  if (_jsonData != null) ...[
                    Text(
                      "JSON 데이터가 서버로부터 수신되었습니다!",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          List<dynamic> summary = await _sendDataToServerForSummary();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SummaryScreen(
                                data: summary,
                                userId: userId!,
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("요약 실패: $e")),
                          );
                        }
                      },
                      child: Text("요약하러 가기"),
                    ),
                  ],
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
