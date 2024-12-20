import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'login_screen.dart';

class FinalRegistrationScreen extends StatefulWidget {
  final String token;

  const FinalRegistrationScreen({Key? key, required this.token})
      : super(key: key);

  @override
  _FinalRegistrationScreenState createState() =>
      _FinalRegistrationScreenState();
}

class _FinalRegistrationScreenState extends State<FinalRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _personalIdController = TextEditingController();
  String? _selectedDepartment,
      _selectedSection,
      _selectedIntake,
      _selectedShift,
      _selectedGender;

  List<dynamic> departments = [];
  List<dynamic> sections = [];
  List<dynamic> intakes = [];
  final List<String> shifts = ["Day", "Evening"];
  final Map<String, String> genderMap = {"Male": "male", "Female": "female"};

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final apiService = ApiService(token: widget.token);
    departments = await apiService.getDepartments();
    sections = await apiService.getSections();
    intakes = await apiService.getIntakes();

    setState(() {});
  }

  Future<void> _submitFinalRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService(token: widget.token);

        // Prepare Data to Submit
        final data = {
          "name": _nameController.text,
          "personal_id": _personalIdController.text,
          "intake": _selectedIntake,
          "section": _selectedSection,
          "department": _selectedDepartment,
          "shift": _selectedShift,
          "gender": _selectedGender,
        };

        // Call the API
        final response = await apiService.registerFinalStep(data);

        if (response['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Logout and Navigate to Login Screen
          final isLoggedOut = await apiService.logout();
          if (isLoggedOut) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration completed, but logout failed.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['errors']?.toString() ??
                  'Registration failed due to errors.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Section
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  'Complete Your Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person,
                    ),
                    _buildInputField(
                      controller: _personalIdController,
                      label: 'Personal ID',
                      icon: Icons.perm_identity,
                    ),
                    _buildDropdownField(
                      label: 'Gender',
                      items: genderMap.entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.value,
                                child: Text(entry.key),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedGender = value;
                      }),
                    ),
                    _buildDropdownField(
                      label: 'Department',
                      items: departments
                          .map((dept) => DropdownMenuItem(
                                value: dept['uid'].toString(),
                                child: Text(dept['name'].toString()),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedDepartment = value;
                      }),
                    ),
                    _buildDropdownField(
                      label: 'Section',
                      items: sections
                          .map((section) => DropdownMenuItem(
                                value: section['uid'].toString(),
                                child: Text(section['section'].toString()),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedSection = value;
                      }),
                    ),
                    _buildDropdownField(
                      label: 'Intake',
                      items: intakes
                          .map((intake) => DropdownMenuItem(
                                value: intake['uid'].toString(),
                                child: Text(intake['intake'].toString()),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedIntake = value;
                      }),
                    ),
                    _buildDropdownField(
                      label: 'Shift',
                      items: shifts
                          .map((shift) => DropdownMenuItem(
                                value: shift,
                                child: Text(shift),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedShift = value;
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _submitFinalRegistration,
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      {required TextEditingController controller,
      required String label,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value!.isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items,
        onChanged: onChanged,
        validator: (value) => value == null ? 'Select $label' : null,
      ),
    );
  }
}
