import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecordScreen extends StatefulWidget {
  final String userId;

  const RecordScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _showProjectList = false; // 프로젝트 목록 토글 상태
  bool _showSummaryList = false; // 요약 목록 토글 상태
  List<dynamic> _projectList = []; // 프로젝트 목록 데이터
  List<dynamic> _summaryList = []; // 요약 목록 데이터
  bool _isLoadingProjects = true; // 프로젝트 데이터 로딩 상태
  bool _isLoadingSummaries = true; // 요약 데이터 로딩 상태

  @override
  void initState() {
    super.initState();
    _fetchProjectList();
    _fetchSummaryList();
  }

  Future<void> _fetchProjectList() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/messages/get_project_tables/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> projects = responseData['summary_tables'] ?? [];

        setState(() {
          _projectList = projects;
          _isLoadingProjects = false;
        });
      } else {
        throw Exception("Failed to load project list");
      }
    } catch (e) {
      setState(() {
        _isLoadingProjects = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("프로젝트 목록 불러오기 실패: $e")),
      );
    }
  }

  Future<void> _fetchSummaryList() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/archives/get_summary_tables/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> summaries = responseData['summary_tables'] ?? [];

        setState(() {
          _summaryList = summaries;
          _isLoadingSummaries = false;
        });
      } else {
        throw Exception("Failed to load summary list");
      }
    } catch (e) {
      setState(() {
        _isLoadingSummaries = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("요약 목록 불러오기 실패: $e")),
      );
    }
  }

  Future<void> _fetchAndShowDetails(String endpoint) async {
  try {
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List && data.isNotEmpty && data[0] is List) {
        // 데이터가 List<List<dynamic>>인 경우 처리
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Details"),
              content: SingleChildScrollView(
                child: DataTable(
                  // 첫 번째 항목을 사용해 열 헤더 정의
                  columns: [
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("Task")),
                    DataColumn(label: Text("Description")),
                    DataColumn(label: Text("Created At")),
                    DataColumn(label: Text("Updated At")),
                    DataColumn(label: Text("Last Accessed At")),
                  ],
                  rows: data
                      .map<DataRow>(
                        (row) => DataRow(
                          cells: row
                              .map<DataCell>(
                                (cell) => DataCell(Text(cell.toString())),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("닫기"),
                ),
              ],
            );
          },
        );
      } else if (data is List && data.isEmpty) {
        // 데이터가 빈 List인 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("표시할 데이터가 없습니다.")),
        );
      } else {
        // 예상하지 못한 데이터 형식인 경우
        throw Exception("Unexpected data format: $data");
      }
    } else {
      throw Exception("Failed to fetch details");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("데이터 불러오기 실패: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Record Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로젝트 목록 토글
              ListTile(
                title: Text("프로젝트 목록"),
                trailing: Icon(
                  _showProjectList ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
                onTap: () {
                  setState(() {
                    _showProjectList = !_showProjectList;
                  });
                },
              ),
              if (_showProjectList)
                _isLoadingProjects
                    ? Center(child: CircularProgressIndicator())
                    : _projectList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _projectList.length,
                            itemBuilder: (context, index) {
                              final projectName = _projectList[index];
                              final displayName = projectName.startsWith('project_')
                                  ? projectName.substring(8)
                                  : projectName;

                              return ListTile(
                                title: Text(displayName),
                                onTap: () {
                                  final endpoint =
                                      'http://127.0.0.1:5000/messages/get_message/${widget.userId}/$displayName';
                                  _fetchAndShowDetails(endpoint);
                                },
                              );
                            },
                          )
                        : Text("프로젝트가 없습니다."),

              Divider(),

              // 요약 목록 토글
              ListTile(
                title: Text("요약 목록"),
                trailing: Icon(
                  _showSummaryList ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                ),
                onTap: () {
                  setState(() {
                    _showSummaryList = !_showSummaryList;
                  });
                },
              ),
              if (_showSummaryList)
                _isLoadingSummaries
                    ? Center(child: CircularProgressIndicator())
                    : _summaryList.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _summaryList.length,
                            itemBuilder: (context, index) {
                              final summaryName = _summaryList[index];
                              final displayName = summaryName.startsWith('summary_')
                                  ? summaryName.substring(8)
                                  : summaryName;

                              return ListTile(
                                title: Text(displayName),
                                onTap: () {
                                  final endpoint =
                                      'http://127.0.0.1:5000/archives/get_summary/${widget.userId}/$displayName';
                                  _fetchAndShowDetails(endpoint);
                                },
                              );
                            },
                          )
                        : Text("요약이 없습니다."),
            ],
          ),
        ),
      ),
    );
  }
}
