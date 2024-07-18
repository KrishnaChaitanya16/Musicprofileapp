import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  List<PlatformFile> _selectedFiles = [];
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  Future<void> _uploadFilesAndCreatePost() async {
    List<String> uploadedFileUrls = [];

    // Upload files to Firebase Storage
    for (PlatformFile file in _selectedFiles) {
      try {
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        firebase_storage.UploadTask uploadTask = ref.putFile(File(file.path!));
        firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        uploadedFileUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading file: $e');
        // Handle error as needed
      }
    }

    // Create post document in Firestore
    try {
      CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
      await postsRef.add({
        'description': _descriptionController.text.trim(),
        'tags': _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        'files': uploadedFileUrls,
        'createdAt': Timestamp.now(),
        'likes': 0,
        // Add more fields as needed, such as createdBy
      });

      // Clear fields after successful upload
      _descriptionController.clear();
      _tagsController.clear();
      setState(() {
        _selectedFiles.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully')),
      );

    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post. Please try again later.')),
      );
      // Handle error as needed
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Create Post',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickFiles,
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.cloud_upload,
                              size: 60,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap to Upload Images/Videos',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildFileGridView(),
                    const SizedBox(height: 30),
                    _buildTextFieldWithTitle(
                      title: 'Description',
                      hintText: 'Write something...',
                      controller: _descriptionController,
                      backgroundColor: Color(0xFFfc92dd),
                    ),
                    const SizedBox(height: 30),
                    _buildTextFieldWithTitle(
                      title: 'Add Tags',
                      hintText: 'Enter tags separated by commas...',
                      controller: _tagsController,
                      backgroundColor: Color(0xFFfc92dd),
                      withIcon: true,
                    ),
                    const SizedBox(height: 30),
                    _buildTagPeopleSection(),
                    const SizedBox(height: 40),
                    _buildShareButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
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
              hintStyle: const TextStyle(color: Colors.white54),
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
          const SizedBox(width: 10),
          Text(
            'Tag People',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFileGridView() {
    return _selectedFiles.isNotEmpty
        ? Container(
      height: 200,
      child: GridView.builder(
        itemCount: _selectedFiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: FileImage(File(file.path!)),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    )
        : const Center(
      child: Text(
        'No files selected',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: _uploadFilesAndCreatePost,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFb83786),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Share',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
