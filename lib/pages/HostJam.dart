import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // Import the file picker package
import 'package:muiscprofileapp/pages/livesessionUi.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the LiveSession page

class HostJam extends StatefulWidget {
  final String channelName; // Add this line to accept the channel name

  const HostJam({super.key, required this.channelName}); // Add this parameter to the constructor

  @override
  _HostJamState createState() => _HostJamState();
}

class _HostJamState extends State<HostJam> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  final CollectionReference _jamSessionsCollection =
  FirebaseFirestore.instance.collection('jam_sessions');

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveJamSession() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      await _jamSessionsCollection.add({
        'channelName': widget.channelName,
        'description': _descriptionController.text,
        'tags': _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        'timestamp': Timestamp.now(), // Add timestamp for sorting or querying
        'userId': user.uid, // Save the current user's ID
        'startTime': Timestamp.now(), // Initialize start time to now
        'endTime': Timestamp.now(), // Initialize end time to now
        'status': 'Started', // Initialize status to "Started"
        'participants': [user.displayName ?? 'Anonymous'], // Initialize participants with the current user's name
      });

      // Clear the controllers after saving
      _descriptionController.clear();
      _tagsController.clear();

      // Log success
      print("Jam session saved successfully");

      // Navigate to the LiveSession page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveSession(
            channelName: widget.channelName,
          ),
        ),
      );
    } catch (e) {
      // Log error to console
      print("Error saving jam session: $e");

      // Show an alert dialog with the error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save jam session: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission is granted, proceed with file picking
      _pickFile();
    } else {
      // Handle the case when permission is denied
      print("Permission denied");
    }
  }

  Future<void> _pickFile() async {
    // Ensure permission is granted before picking the file
    await _requestPermissions();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null) {
        print("File picked: ${result.files.single.path}");
        // Handle the picked file
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background for the entire page
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black, // Darker background color
              Colors.black, // Consistent color
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20), // Reduced top spacing
                Text(
                  'Host a Jam Session',
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 10), // Reduced spacing
                GestureDetector(
                  onTap: _pickFile, // Updated to use the file picker
                  child: Container(
                    height: 300, // Reduced container height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Color.fromARGB(255, 237, 154, 209), // Highlight color for the container
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.music_note,
                          size: 60,
                          color: Colors.black,
                        ),
                        SizedBox(height: 8), // Reduced icon spacing
                        Text(
                          'Tap to Upload Music or Video',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Reduced spacing
                _buildFileGridView(),
                const SizedBox(height: 10), // Reduced spacing
                _buildTextFieldWithTitle(
                  title: 'Description',
                  hintText: 'Write something about the jam session...',
                  controller: _descriptionController,
                  backgroundColor: Color(0xFFfc92dd),
                ),
                const SizedBox(height: 10), // Reduced spacing
                _buildTextFieldWithTitle(
                  title: 'Add Tags',
                  hintText: 'Enter tags separated by commas...',
                  controller: _tagsController,
                  backgroundColor: Color(0xFFfc92dd),
                  withIcon: true,
                ),
                const SizedBox(height: 10), // Reduced spacing
                _buildTagPeopleSection(),
                const SizedBox(height: 20), // Spacing before Host Button
                _buildHostButton(context), // Pass the BuildContext to the button
                const SizedBox(height: 20), // Spacing after Host Button
                if (_isCameraInitialized)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Camera Preview',
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 8), // Reduced heading spacing
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: CameraPreview(_cameraController!),
                      ),
                    ],
                  ),
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
    bool withIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8), // Reduced title spacing
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            maxLines: title == 'Description' ? 4 : 1,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black54),
              border: InputBorder.none,
              prefixIcon: withIcon
                  ? Icon(Icons.people, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagPeopleSection() {
    return GestureDetector(
      onTap: () {
        // Handle onTap for tagging people
        // Implement your logic here
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.people, color: Colors.white),
          const SizedBox(width: 8), // Reduced spacing
          Text(
            'Tag People',
            style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFileGridView() {
    // Placeholder for file grid view
    return Container(
      height: 150, // Reduced height
      child: GridView.builder(
        itemCount: 0, // Update as needed
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6.0, // Reduced spacing
          mainAxisSpacing: 6.0, // Reduced spacing
        ),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey,
            child: Center(
              child: Text(
                'File $index',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHostButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _saveJamSession,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Color(0xFFb83786),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Host Jam',
              style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
