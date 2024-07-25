import 'package:flutter/material.dart';
import 'package:muiscprofileapp/pages/livesessionUi.dart';
 // Import the LiveSession page

class HostJam extends StatelessWidget {
  final String channelName; // Add this line to accept the channel name

  const HostJam({super.key, required this.channelName}); // Add this parameter to the constructor

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
                      'Host a Jam Session',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Handle file picking here
                      },
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildFileGridView(),
                    const SizedBox(height: 30),
                    _buildTextFieldWithTitle(
                      title: 'Description',
                      hintText: 'Write something about the jam session...',
                      controller: TextEditingController(), // Use appropriate controller
                      backgroundColor: Color(0xFFfc92dd),
                    ),
                    const SizedBox(height: 30),
                    _buildTextFieldWithTitle(
                      title: 'Add Tags',
                      hintText: 'Enter tags separated by commas...',
                      controller: TextEditingController(), // Use appropriate controller
                      backgroundColor: Color(0xFFfc92dd),
                      withIcon: true,
                    ),
                    const SizedBox(height: 30),
                    _buildTagPeopleSection(),
                    const SizedBox(height: 40),
                    _buildHostButton(context), // Pass the BuildContext to the button
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
    // Placeholder for file grid view
    return Container(
      height: 200,
      child: GridView.builder(
        itemCount: 0, // Update as needed
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey, // Placeholder color
            ),
          );
        },
      ),
    );
  }

  Widget _buildHostButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveSession(channelName: channelName),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFFb83786),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Host Jam',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
