import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddAnnouncementScreen extends StatefulWidget {
  final String token;

  const AddAnnouncementScreen({Key? key, required this.token})
      : super(key: key);

  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final TextEditingController _announcementController = TextEditingController();
  bool isSubmitting = false;

  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(token: widget.token);
  }

  Future<void> _submitAnnouncement() async {
    if (_announcementController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement cannot be empty')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    bool success =
        await _apiService.addAnnouncement(_announcementController.text);

    setState(() {
      isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement added successfully')),
      );
      Navigator.pop(context, true); // Pass `true` to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add announcement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Announcement'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _announcementController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Announcement',
                hintText: 'Write your announcement here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitAnnouncement,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
