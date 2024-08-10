import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  const ChatPage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
        final chatDocRef = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

        // Check if the document exists
        final docSnapshot = await chatDocRef.get();
        if (!docSnapshot.exists) {
          print('Chat document does not exist. Creating a new one.');
          await chatDocRef.set({
            'messages': [],
          });
        }

        await chatDocRef.update({
          'messages': FieldValue.arrayUnion([
            {
              'senderId': currentUserUsername,
              'message': messageText,
              'timestamp': Timestamp.now(),
              'imageUrl': '',
              'read': false,
            },
          ]),
        });

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
                          widget.chatId,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Chat Partner',
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
                        .collection('chats')
                        .doc(widget.chatId)
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

                      final chatDoc = snapshot.data!;
                      final messages = chatDoc['messages'] as List<dynamic>? ?? [];

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
                            senderUsername: senderUsername,
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
                      color: Color.fromRGBO(252, 146, 221, 1),
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
  final String senderUsername;
  final bool read;

  const MessageBubble({
    Key? key,
    required this.isUser,
    required this.message,
    required this.timestamp,
    required this.senderUsername,
    required this.read,
  }) : super(key: key);

  Future<String> _fetchProfileImageUrl(String username) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final profileImageUrl = userDoc.docs.first.data()['imageUrl'] as String?;
        // Return the profile image URL if it's not null, otherwise return the placeholder image
        return profileImageUrl ?? 'assets/default_profile.png';
      } else {
        return 'assets/default_profile.png'; // Placeholder image
      }
    } catch (e) {
      print('Error fetching profile image: $e');
      return 'assets/default_profile.png'; // Placeholder image
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchProfileImageUrl(senderUsername),
      builder: (context, snapshot) {
        String profileImage = 'assets/default_profile.png'; // Placeholder image
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            profileImage = snapshot.data!;
          } else {
            print('Error fetching profile image: ${snapshot.error}');
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // User message
              if (isUser) ...[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 173, 231), // Color for user message
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(0.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        timestamp,
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Nunito',
                          fontSize: 12.0,
                        ),
                      ),
                      if (read) ...[
                        SizedBox(height: 4.0),
                        Icon(Icons.check_circle, color: Colors.black54, size: 16.0),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImage),
                  radius: 20.0, // Adjust the radius as needed
                ),
              ],
              // Non-user message
              if (!isUser) ...[
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImage),
                  radius: 20.0, // Adjust the radius as needed
                ),
                SizedBox(width: 8.0),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 186, 146, 224), // Color for non-user message
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        timestamp,
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Nunito',
                          fontSize: 12.0,
                        ),
                      ),
                      if (read) ...[
                        SizedBox(height: 4.0),
                        Icon(Icons.check_circle, color: Colors.black54, size: 16.0),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
