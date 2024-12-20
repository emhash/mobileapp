import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'exam_detail.dart';

class AllExamsScreen extends StatefulWidget {
  final String token;

  AllExamsScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AllExamsScreenState createState() => _AllExamsScreenState();
}

class _AllExamsScreenState extends State<AllExamsScreen> {
  late ApiService _apiService;
  List<Map<String, dynamic>> upcomingExams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      final exams = await _apiService.getUpcomingExams();
      setState(() {
        upcomingExams = exams;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching exams: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Upcoming Exams'),
        backgroundColor: Colors.green.shade700,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: upcomingExams.length,
              itemBuilder: (context, index) {
                var exam = upcomingExams[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExamDetailScreen(
                              examId: exam['uid'], token: widget.token),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Icon section
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.school,
                              color: Colors.green.shade700,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Exam details section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exam['exam_name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.green.shade600,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      exam['date'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Arrow icon for navigation
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green.shade700,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
