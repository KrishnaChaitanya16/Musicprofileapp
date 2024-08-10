import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CircleChatPage extends StatefulWidget {
  final String circleId;

  const CircleChatPage({
    Key? key,
    required this.circleId,
  }) : super(key: key);

  @override
  _CircleChatPageState createState() => _CircleChatPageState();
}

class _CircleChatPageState extends State<CircleChatPage> {
  final _messageController = TextEditingController();
  String? _currentUserUsername;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserUsername();
  }

  Future<void> _fetchCurrentUserUsername() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
        setState(() {
          _currentUserUsername = userDoc['username'] as String?;
        });
      } catch (e) {
        print('Error fetching user username: $e');
      }
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final currentUserUsername = _currentUserUsername;
      if (currentUserUsername == null) {
        // Handle case where user username is not available
        return;
      }

      try {
        // Get the circleId for the current chat
        final circleId = widget.circleId;
        final circleDocRef = FirebaseFirestore.instance.collection('circles').doc(circleId);

        // Check if the document exists
        final docSnapshot = await circleDocRef.get();
        if (!docSnapshot.exists) {
          print('Circle document does not exist. Creating a new one.');
          // Create a new document with an empty messages array if it doesn't exist
          await circleDocRef.set({
            'messages': [],
          });
        }

        // Append the new message to the existing messages array
        await circleDocRef.update({
          'messages': FieldValue.arrayUnion([
            {
              'senderId': currentUserUsername,
              'message': messageText,
              'timestamp': Timestamp.now(), // Using Timestamp for Firestore
              'imageUrl': '', // Assuming empty string if not provided
              'read': false,
            },
          ]),
        });

        // Clear the message input field after sending
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserUsername == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
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
                    colors: [Color(0xFF1f0d1d), Color(0xFF140f13)],
                    stops: [0.01, 0.1],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.circleId,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Circle Chat',
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
                      colors: [Color(0xFF754567), Color(0xFF271629)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('circles')
                        .doc(widget.circleId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error fetching messages: ${snapshot.error}',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Center(child: Text('No messages available', style: TextStyle(color: Colors.white)));
                      }

                      final circleDoc = snapshot.data!;
                      final messages = circleDoc['messages'] as List<dynamic>? ?? [];

                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index] as Map<String, dynamic>;
                          final senderUsername = message['senderId'] as String? ?? 'Unknown';
                          final messageText = message['message'] as String? ?? '';
                          final timestamp = message['timestamp'] as Timestamp?;
                          final imageUrl = message['imageUrl'] as String? ?? '';
                          final read = message['read'] as bool? ?? false;

                          final isUser = senderUsername == _currentUserUsername;

                          return MessageBubble(
                            isUser: isUser,
                            message: messageText,
                            timestamp: timestamp != null ? formatTimeAgo(timestamp) : 'Unknown time',
                            profileImage: imageUrl,
                            read: read,
                          );
                        },
                      );
                    },
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
                        controller: _messageController,
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
                        _sendMessage();
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

  String formatTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class MessageBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String timestamp;
  final String profileImage; // Assuming this is the URL or path to the profile image
  final bool read;

  const MessageBubble({
    Key? key,
    required this.isUser,
    required this.message,
    required this.timestamp,
    required this.profileImage,
    required this.read,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a default placeholder image if profileImage is empty or null
    final displayProfileImage = profileImage.isNotEmpty ? profileImage : 'assets/default_profile.png';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundImage: NetworkImage(displayProfileImage),
              radius: 20.0, // Adjust the radius as needed
            ),
          SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isUser ? Color.fromARGB(255, 255, 173, 231) : Color.fromARGB(255, 186, 146, 224),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                    bottomLeft: isUser ? Radius.circular(12.0) : Radius.circular(0.0),
                    bottomRight: isUser ? Radius.circular(0.0) : Radius.circular(12.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(color: Colors.black, fontFamily: 'Nunito'),
                    ),
                    if (read) ...[
                      SizedBox(height: 8.0),
                      Text(
                        'Read',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                timestamp,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
