import 'package:flutter/material.dart';

class Activity {
  final String type;
  final String description;
  final String profilePic;

  Activity({
    required this.type,
    required this.description,
    required this.profilePic,
  });
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key? key}) : super(key: key);

  List<Activity> getPast7DaysActivities() {
    return [
      Activity(
        type: 'like',
        description: 'User1 liked your post',
        profilePic: 'assets/profile1.png',
      ),
      Activity(
        type: 'comment',
        description: 'User2 commented on your post',
        profilePic: 'assets/profile2.png',
      ),
      Activity(
        type: 'reply',
        description: 'User3 liked your reply',
        profilePic: 'assets/profile3.png',
      ),
    ];
  }

  List<Activity> getPast30DaysActivities() {
    return [
      Activity(
        type: 'like',
        description: 'User4 liked your post',
        profilePic: 'assets/profile4.png',
      ),
      Activity(
        type: 'comment',
        description: 'User5 commented on your post',
        profilePic: 'assets/profile5.png',
      ),
      Activity(
        type: 'reply',
        description: 'User6 liked your reply',
        profilePic: 'assets/profile6.png',
      ),
      Activity(
        type: 'link_request',
        description: 'User7 sent you a link request',
        profilePic: 'assets/profile7.png',
      ),
      Activity(
        type: 'invitation_to_jam',
        description: 'User8 invited you to jam',
        profilePic: 'assets/profile8.png',
      ),
    ];
  }

  Widget _getActivityIcon(String type) {
    switch (type) {
      case 'like':
        return Icon(Icons.favorite_border_outlined, color: Colors.white);
      case 'comment':
        return Image.asset('lib/icons/chat.png', height: 30, color: Colors.white);
      case 'reply':
        return Icon(Icons.reply, color: Colors.white);
      case 'link_request':
        return Icon(Icons.link, color: Colors.white);
      case 'invitation_to_jam':
        return Image.asset('lib/icons/hotspot.png', height: 30, color: Colors.white);
      default:
        return Icon(Icons.notifications, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final past7DaysActivities = getPast7DaysActivities();
    final past30DaysActivities = getPast30DaysActivities();

    return Scaffold(
      backgroundColor: const Color(0xFF110F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF110F12),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),  // Increased size to 30
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Past 7 Days',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(
            color: Colors.white54,
            thickness: 0.5,
          ),
          ...past7DaysActivities.map((activity) => Column(
            children: [
              _buildActivityTile(activity),
              const SizedBox(height: 10),
            ],
          )),
          const SizedBox(height: 20),
          const Text(
            'Past 30 Days',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(
            color: Colors.white54,
            thickness: 0.5,
          ),
          ...past30DaysActivities.map((activity) => Column(
            children: [
              _buildActivityTile(activity),
              const SizedBox(height: 10),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      leading: CircleAvatar(
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _getActivityIcon(activity.type),
        ),
        radius: 30,  // Increased the radius to make the avatar bigger
      ),
      title: Text(
        activity.description,
        style: const TextStyle(color: Colors.white, fontSize: 16),  // Increased the font size
      ),
      trailing: activity.type == 'link_request' || activity.type == 'invitation_to_jam'
          ? CircleAvatar(
        backgroundImage: AssetImage(activity.profilePic),
        radius: 30,  // Increased the radius to make the avatar bigger
      )
          : Container(
        width: 50,  // Increased the width
        height: 50,  // Increased the height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey,
        ),
      ),
    );
  }
}
