import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddExamScreen extends StatefulWidget {
  final String token;

  const AddExamScreen({Key? key, required this.token}) : super(key: key);

  @override
  _AddExamScreenState createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _topicController = TextEditingController();
  final _detailController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  final Color _primaryColor = Colors.green;
  final Color _inputFillColor = Colors.green.withOpacity(0.08);

  @override
  Widget build(BuildContext context) {
    final TextStyle sectionTitleStyle = TextStyle(
      color: _primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add New Exam', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f2f1), Color(0xFFb2dfdb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exam Name
                      Text('Exam Name', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _buildExamNameDropdown(),

                      const SizedBox(height: 16),

                      // Date
                      Text('Date', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _buildDateField(),

                      const SizedBox(height: 16),

                      // Course Name
                      Text('Course Name', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _courseNameController,
                        hint: 'Enter course name',
                        validatorText: 'Please enter course name',
                        prefixIcon: Icons.book,
                      ),

                      const SizedBox(height: 16),

                      // Course Code
                      Text('Course Code', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _courseCodeController,
                        hint: 'Enter course code',
                        validatorText: 'Please enter course code',
                        prefixIcon: Icons.code,
                      ),

                      const SizedBox(height: 16),

                      // Topic
                      Text('Topic', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _topicController,
                        hint: 'Enter topic',
                        validatorText: 'Please enter topic',
                        prefixIcon: Icons.topic,
                      ),

                      const SizedBox(height: 16),

                      // Details
                      Text('Details', style: sectionTitleStyle),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _detailController,
                        hint: 'Enter details',
                        validatorText: 'Please enter details',
                        prefixIcon: Icons.description,
                        maxLines: 5,
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamNameDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Select exam type',
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.black),
      iconEnabledColor: _primaryColor,
      items: [
        'Class Test',
        'Quiz Test',
        'Mid Term',
        'Final Test',
        'Lab Mid',
        'Lab Evaluation'
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: _primaryColor)),
        );
      }).toList(),
      onChanged: (value) {
        _examNameController.text = value ?? '';
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an exam type';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Select a date',
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: _primaryColor),
      ),
      style: TextStyle(color: _primaryColor),
      controller: TextEditingController(
        text: _selectedDate != null
            ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
            : '',
      ),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2025),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      validator: (value) {
        if (_selectedDate == null) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String validatorText,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: _primaryColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: _inputFillColor,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: _primaryColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService(token: widget.token);
        final success = await apiService.addExam(
          examName: _examNameController.text,
          courseName: _courseNameController.text,
          courseCode: _courseCodeController.text,
          date: _selectedDate!,
          topic: _topicController.text,
          detail: _detailController.text,
        );

        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add exam. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _topicController.dispose();
    _detailController.dispose();
    super.dispose();
  }
}
