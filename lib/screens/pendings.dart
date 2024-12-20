import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class PendingApplicationsScreen extends StatefulWidget {
  final String token;

  const PendingApplicationsScreen({Key? key, required this.token})
      : super(key: key);

  @override
  _PendingApplicationsScreenState createState() =>
      _PendingApplicationsScreenState();
}

class _PendingApplicationsScreenState extends State<PendingApplicationsScreen> {
  late ApiService _apiService;
  List<dynamic> pendingApplications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
    _fetchPendingApplications();
  }

  Future<void> _fetchPendingApplications() async {
    setState(() => isLoading = true);
    try {
      final List<dynamic> applications = await _apiService.getPendings();
      setState(() {
        pendingApplications = applications;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pending applications: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _confirmAndApprove(String uid) async {
    final confirmed = await _showConfirmationDialog("Approve", "approve");
    if (confirmed) {
      // Placeholder API logic for Approve
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application Approved: $uid')),
      );
      _fetchPendingApplications();
    }
  }

  Future<void> _confirmAndDelete(String uid) async {
    final confirmed = await _showConfirmationDialog("Delete", "delete");
    if (confirmed) {
      // Placeholder API logic for Delete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application Deleted: $uid')),
      );
      _fetchPendingApplications();
    }
  }

  Future<void> _approveApplication(String uid) async {
    final success = await _apiService.approvePendingApplication(uid);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Approved Successfully!')),
      );
      _fetchPendingApplications(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve application.')),
      );
    }
  }

  Future<void> _deleteApplication(String uid) async {
    final success = await _apiService.deletePendingApplication(uid);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application Deleted Successfully!')),
      );
      _fetchPendingApplications(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete application.')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(String action, String verb) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$action Application'),
            content: Text('Are you sure you want to $verb this application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      action == "Delete" ? Colors.red : Colors.green,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Applications'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingApplications.isEmpty
              ? const Center(
                  child: Text(
                    'No pending applications available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingApplications.length,
                  itemBuilder: (context, index) {
                    final application = pendingApplications[index];
                    return _buildApplicationCard(application);
                  },
                ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            CircleAvatar(
              backgroundImage: NetworkImage(
                application['image'] ??
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
              ),
              radius: 30,
            ),
            const SizedBox(width: 12),
            // Applicant's Details
            // Applicant's Details (Updated Layout)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    application['phone'] ?? 'No phone number',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  // Updated Layout: Intake & Section in one row, Department & Shift in another
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildInfoItem(
                              "Intake", application['intake'].toString()),
                          _buildInfoItem("Section", application['section']),
                        ],
                      ),
                      Row(
                        children: [
                          _buildInfoItem("Dept.", application['department']),
                          _buildInfoItem("Shift", application['shift']),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            // Approve and Delete Buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: 'Approve',
                  onPressed: () => _approveApplication(application['uid']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () => _deleteApplication(application['uid']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}
