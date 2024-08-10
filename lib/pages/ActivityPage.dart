import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Activity {
  final String type;
  final String description;
  final String profilePic;
  final String userName;
  final String? postImage;
  final Timestamp timestamp; // Add timestamp for sorting and filtering

  Activity({
    required this.type,
    required this.description,
    required this.profilePic,
    required this.userName,
    this.postImage,
    required this.timestamp,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      type: data['type'] ?? 'unknown',
      description: data['description'] ?? '',
      profilePic: data['profilePic'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      postImage: data['postImage'],
      timestamp: data['timestamp'], // Make sure timestamp is included
    );
  }
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({Key? key}) : super(key: key);

  Future<List<Activity>> _fetchActivities() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User ID is null');
        return [];
      }

      final now = DateTime.now();
      final startDate30Days = now.subtract(Duration(days: 30));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .where('timestamp', isGreaterThanOrEqualTo: startDate30Days)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      print('Fetched ${querySnapshot.docs.length} activities');
      return querySnapshot.docs
          .map((doc) => Activity.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF110F12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF110F12),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<Activity>>(
        future: _fetchActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading activities'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No activities available'));
          }

          final allActivities = snapshot.data!;
          final now = DateTime.now();
          final startDate7Days = now.subtract(Duration(days: 7));

          final past7DaysActivities = allActivities.where((activity) {
            final activityDate = activity.timestamp.toDate();
            return activityDate.isAfter(startDate7Days);
          }).toList();

          final past30DaysActivities = allActivities.where((activity) {
            final activityDate = activity.timestamp.toDate();
            return activityDate.isBefore(startDate7Days);
          }).toList();

          return ListView(
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
          );
        },
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
        radius: 30,
      ),
      title: Text(
        '${activity.userName} ${activity.description}',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: activity.type == 'link_request' || activity.type == 'invitation_to_jam'
          ? CircleAvatar(
        backgroundImage: AssetImage(activity.profilePic),
        radius: 30,
      )
          : Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: activity.postImage != null && activity.postImage!.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(activity.postImage!),
            fit: BoxFit.cover,
          )
              : null,
          color: activity.postImage == null || activity.postImage!.isEmpty
              ? Colors.grey
              : Colors.transparent,
        ),
      ),
    );
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
}
