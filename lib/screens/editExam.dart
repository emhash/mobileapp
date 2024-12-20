import 'package:flutter/material.dart';
import '../services/api_services.dart';

class EditExamScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> examDetails;

  const EditExamScreen({
    Key? key,
    required this.token,
    required this.examDetails,
  }) : super(key: key);

  @override
  _EditExamScreenState createState() => _EditExamScreenState();
}

class _EditExamScreenState extends State<EditExamScreen> {
  late TextEditingController _courseNameController;
  late TextEditingController _courseCodeController;
  late TextEditingController _topicController;
  late TextEditingController _detailController;
  DateTime? _selectedDate;
  String? _selectedExamName;

  final List<String> _examTypes = [
    'Class Test',
    'Quiz Test',
    'Mid Term',
    'Final Test',
    'Lab Mid',
    'Lab Evaluation',
  ];

  @override
  void initState() {
    super.initState();
    _courseNameController =
        TextEditingController(text: widget.examDetails['course_name']);
    _courseCodeController =
        TextEditingController(text: widget.examDetails['course_code']);
    _topicController = TextEditingController(text: widget.examDetails['topic']);
    _detailController =
        TextEditingController(text: widget.examDetails['detail']);
    _selectedDate = DateTime.parse(widget.examDetails['date']);
    _selectedExamName = widget.examDetails['exam_name'];
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _topicController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateExam() async {
    bool updated = await ApiService(token: widget.token).updateExam(
      examId: widget.examDetails['uid'],
      examName: _selectedExamName!,
      courseName: _courseNameController.text,
      courseCode: _courseCodeController.text,
      date: _selectedDate!,
      topic: _topicController.text,
      detail: _detailController.text,
    );
    if (updated) {
      Navigator.pop(context, true); // Pop with true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update exam')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Exam',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedExamName,
                    decoration: InputDecoration(
                      labelText: 'Exam Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.green.shade50,
                      prefixIcon:
                          Icon(Icons.menu_book, color: Colors.green.shade700),
                    ),
                    items: _examTypes
                        .map((examType) => DropdownMenuItem<String>(
                              value: examType,
                              child: Text(
                                examType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedExamName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _courseNameController,
                    label: 'Course Name',
                    icon: Icons.book,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _courseCodeController,
                    label: 'Course Code',
                    icon: Icons.code,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _topicController,
                    label: 'Topic',
                    icon: Icons.topic,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _detailController,
                    label: 'Details',
                    icon: Icons.details,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${_selectedDate?.toString().split(' ')[0] ?? 'Select a date'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _updateExam,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        filled: true,
        fillColor: Colors.green.shade50,
      ),
    );
  }
}
