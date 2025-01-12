import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

class SummaryScreen extends StatelessWidget {
  final List<dynamic> data;
  final String userId;
  final List<dynamic> originalData;

  const SummaryScreen({
    Key? key,
    required this.data,
    required this.userId,
    required this.originalData, 
  }) : super(key: key);

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
              content: Text("프로젝트 없음"),
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
                    final String projectName = task ?? 'No Name';

                    return ListTile(
                      title: Text(projectName),
                      onTap: () async {
                        // 프로젝트 이름에서 접두사 'summary_' 제거
                        final String projectId =
                            projectName.startsWith('summary_')
                                ? projectName.substring(8)
                                : projectName;

                        Navigator.of(context).pop(); // 팝업 닫기
                        await _saveToExistingProject(context, projectId);
                      },
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

Future<void> _saveToExistingProject(BuildContext context, String projectId) async {
  try {
    // 서버로 보낼 데이터: 요약 데이터와 원본 데이터
    print("Saving to project ID: $projectId");

    // 1. 요약 데이터 저장
    final responseSummary = await http.post(
      Uri.parse('http://127.0.0.1:5000/archives/save_summary/$userId/$projectId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data), // Summary data
    );

    if (responseSummary.statusCode == 201) {
      // 2. 원본 데이터 저장
      final responseOriginal = await http.post(
        Uri.parse('http://127.0.0.1:5000/messages/save_message/$userId/$projectId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(originalData), // Original data
      );

      if (responseOriginal.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("기존 프로젝트에 성공적으로 저장되었습니다.")),
        );
      } else {
        print("Response Body for messages/save_message: ${responseOriginal.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("원본 데이터 저장에 실패했습니다.")),
        );
      }
    } else {
      print("Response Body for archives/save_summary: ${responseSummary.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("요약 데이터 저장에 실패했습니다.")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("저장 중 오류 발생: $e")),
    );
  }
}


  // 새로운 프로젝트로 기록하기 버튼 기능
Future<void> _createNewProject(BuildContext context, List<dynamic> summaryData, List<dynamic> originalData) async {
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
                try {
                  // 요약 데이터를 저장
                  final responseSummary = await http.post(
                    Uri.parse('http://127.0.0.1:5000/archives/save_summary/$userId/$projectId'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(summaryData),
                  );

                  if (responseSummary.statusCode == 201) {
                    // 원본 데이터를 저장
                    final responseOriginal = await http.post(
                      Uri.parse('http://127.0.0.1:5000/messages/save_message/$userId/$projectId'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(originalData),
                    );

                    if (responseOriginal.statusCode == 201) {
                      Navigator.of(context).pop(); // 팝업 닫기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("프로젝트가 성공적으로 저장되었습니다.")),
                      );
                    } else {
                      throw Exception("원본 데이터 저장 실패: ${responseOriginal.body}");
                    }
                  } else {
                    throw Exception("요약 데이터 저장 실패: ${responseSummary.body}");
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // 팝업 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("저장 중 오류 발생: $e")),
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
Future<void> _downloadSummary(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/export/export_json_to_csv'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data), // 전송할 요약 데이터
    );

    if (response.statusCode == 200) {
      final content = response.body; // 서버에서 반환된 CSV 데이터
      final bytes = utf8.encode(content); // UTF-8로 인코딩
      final blob = html.Blob([bytes]); // Blob 생성
      final url = html.Url.createObjectUrlFromBlob(blob); // Blob URL 생성
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'summary_result.csv'; // 다운로드 파일 이름 설정
      anchor.click(); // 파일 다운로드 트리거
      html.Url.revokeObjectUrl(url); // URL 메모리 해제

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("요약 결과 다운로드 완료")),
      );
    } else {
      throw Exception("다운로드 실패: ${response.body}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("다운로드 중 오류 발생: $e")),
    );
  }
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
            onPressed: () async {
              await _showExistingTasksPopup(context);
            },
            child: Text("기존 업무에 기록하기"),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await _createNewProject(context, data, originalData);
            },
            child: Text("새로운 프로젝트로 기록하기"),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await _downloadSummary(context);
            },
            child: Text("요약 결과 다운로드"),
          ),
        ],
      ),
    ),
  );
}
}