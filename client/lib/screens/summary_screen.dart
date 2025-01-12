import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SummaryScreen extends StatelessWidget {
  final List<dynamic> data;
  final String userId;

  const SummaryScreen({Key? key, required this.data, required this.userId}) : super(key: key);

  // 1. 기존 업무에 기록하기 버튼 기능
  Future<void> _showExistingTasksPopup(BuildContext context) async {
  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/archives/get_summary_tables/$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // responseData['summary_tables']가 null일 경우 빈 리스트로 처리
      final List<dynamic> summaryTables = responseData['summary_tables'] ?? [];

      if (summaryTables.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("기존 업무 기록"),
              content: Text("아무것도 없음"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("닫기"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("기존 업무 기록"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: summaryTables.length,
                  itemBuilder: (context, index) {
                    final task = summaryTables[index];
                    return ListTile(
                      title: Text(task ?? 'No Name'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("닫기"),
                ),
              ],
            );
          },
        );
      }
    } else {
      throw Exception("서버 요청 실패: ${response.body}");
    }
  } catch (e) {
    // 오류 처리
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("오류"),
          content: Text("데이터를 가져오는 데 실패했습니다: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("닫기"),
            ),
          ],
        );
      },
    );
  }
}


  // 새로운 프로젝트로 기록하기 버튼 기능
  void _createNewProject(BuildContext context, List<dynamic> summaryData) {
  TextEditingController projectIdController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("새로운 프로젝트로 기록하기"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("프로젝트 ID를 입력하세요."),
            SizedBox(height: 8),
            TextField(
              controller: projectIdController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "프로젝트 ID",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String projectId = projectIdController.text.trim();

              if (projectId.isNotEmpty) {
                // 서버로 보낼 데이터: 요약 데이터를 포함
                final List<dynamic> requestBody = summaryData;

                // JSON 데이터를 로그에 출력
                print("Request Body: ${json.encode(requestBody)}");

                // 서버에 데이터 전송
                final response = await http.post(
                  Uri.parse('http://127.0.0.1:5000/archives/save_summary/$userId/$projectId'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(requestBody), // JSON 데이터 전송
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop(); // 팝업 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("프로젝트가 성공적으로 저장되었습니다.")),
                  );
                } else {
                  Navigator.of(context).pop(); // 팝업 닫기
                  print("Response Body: ${response.body}"); // 서버 응답 로그 출력
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("프로젝트 저장에 실패했습니다.")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("프로젝트 ID를 입력해주세요.")),
                );
              }
            },
            child: Text("저장"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("취소"),
          ),
        ],
      );
    },
  );
}




  // 3. 요약 결과 다운로드 버튼 기능
  void _downloadSummary(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("다운로드"),
          content: Text("요약 결과를 다운로드 하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                // 다운로드 로직 추가
                Navigator.of(context).pop();
              },
              child: Text("다운로드"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("요약 결과")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Task Name')),
                    DataColumn(label: Text('Project Date')),
                    DataColumn(label: Text('Topics')),
                  ],
                  rows: data.map((task) {
                    return DataRow(cells: [
                      DataCell(Text(task['name'] ?? 'No Name')),
                      DataCell(Text(task['project_at'] ?? 'No Date')),
                      DataCell(Text(task['topic'] ?? 'No Topic')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showExistingTasksPopup(context),
              child: Text("기존 업무에 기록하기"),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _createNewProject(context, data),
              child: Text("새로운 프로젝트로 기록하기"),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _downloadSummary(context),
              child: Text("요약 결과 다운로드"),
            ),
          ],
        ),
      ),
    );
  }
}
