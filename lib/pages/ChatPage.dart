import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String title;

  const ChatPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color of the page
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1f0d1d),
                      Color(0xFF140f13),
                    ],
                    stops: [0.01, 0.1],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Go back to the previous screen
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username', // Replace with actual username
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          title, // Replace with actual name if different from title
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Add action for three vertical dots
                      },
                      child: Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF754567),
                        Color(0xFF271629),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      MessageBubble(
                        isUser: true,
                        message: 'Hello!',
                        timestamp: '10:30 AM',
                        profileImage: 'assets/user_profile.png', // Replace with actual image path
                      ),
                      MessageBubble(
                        isUser: false,
                        message: 'Hi there!',
                        timestamp: '10:32 AM',
                        profileImage: 'assets/other_profile.png', // Replace with actual image path
                      ),
                      // Add more MessageBubble widgets here
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter your message...',
                          hintStyle: TextStyle(color: Colors.white54, fontFamily: 'Nunito'),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        // Add action to send the message
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String timestamp;
  final String profileImage;

  const MessageBubble({
    Key? key,
    required this.isUser,
    required this.message,
    required this.timestamp,
    required this.profileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            backgroundImage: AssetImage(profileImage),
            radius: 25, // Increased size
          ),
          SizedBox(width: 10),
        ],
        Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(16.0), // Increased size
              decoration: BoxDecoration(
                color: isUser ? Color.fromRGBO(255, 173, 231, 1) : Color.fromRGBO(186, 146, 224, 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: isUser ? Radius.circular(12) : Radius.circular(0),
                  bottomRight: isUser ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito'),
              ),
            ),
            Text(
              timestamp,
              style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Nunito'),
            ),
          ],
        ),
        if (isUser) ...[
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: AssetImage(profileImage),
            radius: 25, // Increased size
          ),
        ],
      ],
    );
  }
}
