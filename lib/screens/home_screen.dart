import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:unimate/screens/pendings.dart';
import '../services/api_services.dart';
import '../screens/add_exam.dart';
import '../screens/exam_detail.dart';
import 'all_announcements_screen.dart';
import 'all_exams_screen.dart';
import 'auth/login_screen.dart';
import 'editExam.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final String token;

  const HomeScreen({Key? key, required this.userEmail, required this.token})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiService _apiService;
  List<Map<String, dynamic>> upcomingExams = [];
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  int _currentIndex = 0;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final profile = await _apiService.getProfile();
      setState(() {
        profileData = profile['data'];
      });

      final exams = await _apiService.getUpcomingExams();
      final announcs = await _apiService.getAnnouncements();
      setState(() {
        upcomingExams = exams;
        announcements = announcs;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteExam(String uid) async {
    try {
      await _apiService.deleteExam(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam deleted successfully')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete exam: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define some custom colors and styles for a more professional look
    final Color primaryColor = Colors.blueAccent;
    final Color secondaryColor = Colors.green;
    final Color backgroundColor = Colors.grey.shade100;
    final TextStyle headingStyle = const TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Column(
          children: [
            // Top Section with Profile
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                ClipPath(
                  clipper: OvalBottomBorderClipper(),
                  child: Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF4A90E2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Image with border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                profileData?['image'] ??
                                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                              ),
                              radius: 40,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Profile details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profileData?['name'] ?? 'Guest',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      "Intake: ${profileData?['intake'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Section: ${profileData?['section'] ?? 'N/A'}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Department: ${profileData?['department'] ?? 'N/A'}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            tooltip: 'Logout',
                            onPressed: () async {
                              final isLoggedOut = await _apiService.logout();
                              if (isLoggedOut) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Logout failed. Try again!')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section for Pending Tasks
                          Text('Pending Tasks', style: headingStyle),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTaskCard(
                                  'Exams',
                                  upcomingExams.length.toString(),
                                  secondaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTaskCard(
                                  'Assignments',
                                  '3',
                                  Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Upcoming Exams Section
                          Text('Upcoming Exams', style: headingStyle),
                          const SizedBox(height: 16),
                          if (upcomingExams.isEmpty)
                            const Center(
                              child: Text(
                                'No upcoming exams available.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            Column(
                              children: upcomingExams
                                  .map((exam) => _buildExamItem(exam))
                                  .toList(),
                            ),

                          const SizedBox(height: 32),

                          // Announcements Section
                          Text('Announcements', style: headingStyle),
                          const SizedBox(height: 16),
                          if (announcements.isEmpty)
                            const Center(
                              child: Text(
                                'No announcements available.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            Column(
                              children: announcements
                                  .map((announcement) =>
                                      _buildAnnouncementItem(announcement))
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExamScreen(token: widget.token),
            ),
          );
          if (result == true) {
            _loadData(); // Refresh the data
          }
        },
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Add Exam',
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: secondaryColor,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Exams',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Announcements',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pending_actions),
                label: 'Pendings',
              ),
            ],
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                switch (index) {
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllExamsScreen(token: widget.token),
                      ),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllAnnouncementsScreen(token: widget.token),
                      ),
                    );
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PendingApplicationsScreen(token: widget.token),
                      ),
                    );
                    break;
                  default:
                    break;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refreshPage() async {
    await _loadData();
  }

  Widget _buildTaskCard(String title, String count, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Let the card size itself to fit content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              title == 'Exams' ? Icons.book : Icons.assignment,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamItem(Map<String, dynamic> exam) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          exam['exam_name'] ?? '',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          exam['course_name'] ?? '',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamDetailScreen(
                        examId: exam['uid'], token: widget.token),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orangeAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditExamScreen(token: widget.token, examDetails: exam),
                  ),
                ).then((value) {
                  if (value == true) _loadData();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                // Show a beautiful confirmation dialog
                showDialog(
                  context: context,
                  barrierDismissible: false, // User must tap confirm or cancel
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: const Text(
                        'Confirm Deletion',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this exam? This action cannot be undone.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            _deleteExam(exam['uid']); // Proceed with deletion
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(Map<String, dynamic> announcement) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          announcement['announcement'] ?? '',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          announcement['created_at'] ?? '',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
