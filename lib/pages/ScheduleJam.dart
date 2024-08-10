import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // For date and time formatting
import 'dart:io';

class ScheduleJam extends StatefulWidget {
  final String channelName;

  const ScheduleJam({super.key, required this.channelName});

  @override
  _ScheduleJamState createState() => _ScheduleJamState();
}

class _ScheduleJamState extends State<ScheduleJam> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _username = '';
  File? _selectedFile; // To hold the selected file
  String? _fileType; // To store the type of the selected file

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String email = user.email!;

      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final data = doc.data();
          setState(() {
            _username = data['username'] ?? 'Unknown User';
          });
        } else {
          setState(() {
            _username = 'Unknown User';
          });
        }
      } catch (e) {
        setState(() {
          _username = 'Unknown User';
        });
        print('Error fetching username: $e');
      }
    } else {
      setState(() {
        _username = 'Unknown User';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime(2101);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null && pickedTime != initialTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileType = result.files.single.extension;
      });
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = storage.ref().child('jam_files/$fileName');
      final UploadTask uploadTask = ref.putFile(file);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _scheduleJam() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time.')),
      );
      return;
    }

    final DateTime scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    String? fileUrl;
    if (_selectedFile != null) {
      fileUrl = await _uploadFile(_selectedFile!);
    }

    final jamDetails = {
      'channelName': widget.channelName,
      'description': _descriptionController.text,
      'dateTime': scheduledDateTime,
      'username': _username,
      'fileUrl': fileUrl, // Store the file URL if available
      'fileType': _fileType, // Store the file type (image or video)
    };

    try {
      await FirebaseFirestore.instance.collection('scheduled_jams').add(jamDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam scheduled successfully.')),
      );
      Navigator.pop(context); // Navigate back after scheduling
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule jam: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1f0d1d),
              Color(0xFF140f13),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Schedule a Jam Session',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white24,
                    ),
                    child: _selectedFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.music_note,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to Upload Music or Video',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                        : _fileType == 'mp4' || _fileType == 'mov'
                        ? Center(
                      child: Text(
                        'Video Selected',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                        : Image.file(
                      _selectedFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextFieldWithTitle(
                  title: 'Description',
                  hintText: 'Write something about the jam session...',
                  controller: _descriptionController,
                  backgroundColor: Color(0xFFfc92dd),
                ),
                const SizedBox(height: 30),
                _buildDateTimeSelectors(context),
                const SizedBox(height: 40),
                _buildScheduleButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithTitle({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Color backgroundColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: title == 'Description' ? 4 : 1,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black54),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectors(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFfc92dd),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFfc92dd),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context),
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleButton() {
    return GestureDetector(
      onTap: _scheduleJam,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFb83786),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Schedule Jam',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
