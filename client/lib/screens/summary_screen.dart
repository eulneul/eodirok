import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

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

  /// 1. 기존 업무에 기록하기
  Future<void> _showExistingTasksPopup(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/archives/get_summary_tables/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> summaryTables = responseData['summary_tables'] ?? [];

        if (summaryTables.isEmpty) {
          _showAlertDialog(context, "기존 업무 기록", "프로젝트 없음");
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
                          final String projectId = projectName.startsWith('summary_')
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
      _showAlertDialog(context, "오류", "데이터를 가져오는 데 실패했습니다: $e");
    }
  }

  Future<void> _saveToExistingProject(BuildContext context, String projectId) async {
    try {
      final responseSummary = await http.post(
        Uri.parse('http://127.0.0.1:5000/archives/save_summary/$userId/$projectId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (responseSummary.statusCode == 201) {
        final responseOriginal = await http.post(
          Uri.parse('http://127.0.0.1:5000/messages/save_message/$userId/$projectId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(originalData),
        );

        if (responseOriginal.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("기존 프로젝트에 성공적으로 저장되었습니다.")),
          );
        } else {
          throw Exception("원본 데이터 저장 실패: ${responseOriginal.body}");
        }
      } else {
        throw Exception("요약 데이터 저장 실패: ${responseSummary.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 중 오류 발생: $e")),
      );
    }
  }

  /// 2. 새로운 프로젝트로 기록하기
  Future<void> _createNewProject(
      BuildContext context, List<dynamic> summaryData, List<dynamic> originalData) async {
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
                    final responseSummary = await http.post(
                      Uri.parse('http://127.0.0.1:5000/archives/save_summary/$userId/$projectId'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode(summaryData),
                    );

                    if (responseSummary.statusCode == 201) {
                      final responseOriginal = await http.post(
                        Uri.parse('http://127.0.0.1:5000/messages/save_message/$userId/$projectId'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(originalData),
                      );

                      if (responseOriginal.statusCode == 201) {
                        Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
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

  /// 3. 요약 결과 다운로드
  Future<void> _downloadSummary(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/export/export_json_to_csv'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final content = response.body;
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'summary_result.csv';
        anchor.click();
        html.Url.revokeObjectUrl(url);

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

  /// 오류/정보 팝업
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

  /// 커스텀 버튼 생성 함수
  Widget _buildCustomButton(BuildContext context,
      {required String label, required VoidCallback onPressed, required IconData icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: Color(0xFFD1E5CE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Icon(
                icon,
                size: 32,
                color: Color(0xFF181D18),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF181D18),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: DataTable(
                    columns: [
                      DataColumn(label: Expanded(child: Text('Task Name'))),
                      DataColumn(label: Expanded(child: Text('Project Date'))),
                      DataColumn(label: Expanded(child: Text('Topics'))),
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
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: Color(0xFFEBEFE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCustomButton(
                    context,
                    label: '기존 업무에 기록하기',
                    onPressed: () async {
                      await _showExistingTasksPopup(context);
                    },
                    icon: Icons.edit,
                  ),
                  _buildCustomButton(
                    context,
                    label: '새로운 업무 기록 만들기',
                    onPressed: () async {
                      await _createNewProject(context, data, originalData);
                    },
                    icon: Icons.add,
                  ),
                  _buildCustomButton(
                    context,
                    label: 'CSV로 저장하기',
                    onPressed: () async {
                      await _downloadSummary(context);
                    },
                    icon: Icons.download,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
