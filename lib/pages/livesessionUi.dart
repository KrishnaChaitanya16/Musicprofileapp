import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "76abe41b5ae84e418e0189ac7ec56f05";
const token = "007eJxTYIh+6XzUMrv7Xn3xzKCVBU81elO4jP0DxI4YH5B/pbd29lIFBnOzxKRUE8Mk08RUCxMgwyLVwNDCMjHZPDXZ1CzNwPT2ztlpDYGMDNzCzQyMUAji8zPklhZnJhcU5adl5qQmFhQwMAAArUIjkA==";
const channel = "musicprofileapp";

class LiveSession extends StatefulWidget {
  final String channelName;
  const LiveSession({super.key, required this.channelName});

  @override
  _LiveSessionState createState() => _LiveSessionState();
}

class _LiveSessionState extends State<LiveSession> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  late DocumentReference _sessionRef;

  @override
  void initState() {
    super.initState();
    _sessionRef = FirebaseFirestore.instance.collection('live_sessions').doc(widget.channelName);
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    if (await Permission.camera.isGranted && await Permission.microphone.isGranted) {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("Local user ${connection.localUid} joined");
            setState(() {
              _localUserJoined = true;
            });
            _storeLiveSession();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Remote user $remoteUid joined");
            setState(() {
              _remoteUid = remoteUid;
            });
            _updateParticipantList();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("Remote user $remoteUid left channel");
            setState(() {
              _remoteUid = null;
            });
            _updateParticipantList();
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          },
        ),
      );

      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.enableVideo();
      await _engine.startPreview();

      await _engine.joinChannel(
        token: token,
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please grant camera and microphone permissions.')),
      );
    }
  }

  Future<void> _storeLiveSession() async {
    try {
      // Check if the document already exists
      final doc = await _sessionRef.get();
      if (!doc.exists) {
        debugPrint("Document does not exist. Attempting to store live session for channel: ${widget.channelName}");
        await _sessionRef.set({
          'channelName': widget.channelName,
          'status': 'ongoing',
          'startTime': Timestamp.now(),
          'participants': [], // Start with an empty list
        });
        debugPrint("Live session stored successfully.");
      } else {
        debugPrint("Document already exists. No need to create a new one.");
      }
    } catch (e) {
      debugPrint("Error storing live session: $e");
    }
  }

  Future<void> _updateParticipantList() async {
    try {
      final doc = await _sessionRef.get();
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        final participants = List<int>.from(data['participants'] ?? []);
        if (_remoteUid != null && !participants.contains(_remoteUid!)) {
          participants.add(_remoteUid!); // Add the remote UID to the list
        }
        await _sessionRef.update({'participants': participants});
        debugPrint("Updated participant list: $participants");
      } else {
        debugPrint("No data found for document: ${widget.channelName}");
      }
    } catch (e) {
      debugPrint("Error updating participant list: $e");
    }
  }

  Future<void> _endSession() async {
    try {
      // Check if the document exists
      final doc = await _sessionRef.get();
      if (!doc.exists) {
        debugPrint("Document does not exist.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session document not found.')),
        );
        return; // Exit early if document doesn't exist
      }

      // Update session status in Firestore
      await _sessionRef.update({
        'status': 'ended', // Change status to 'ended'
        'endTime': Timestamp.now(), // Record end time
      });

      // Stop and release the Agora engine
      await _engine.leaveChannel();
      await _engine.release();

      // Navigate back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Error ending session: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending session: $e')),
      );
    }
  }


  Future<void> _switchCamera() async {
    if (_localUserJoined) {
      await _engine.switchCamera();
    }
  }

  void _showChatBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Live Chat',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: 0, // Replace with actual chat messages count
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Chat message $index', style: TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.black87,
                  ),
                  style: TextStyle(color: Colors.white),
                  onSubmitted: (text) {
                    // Handle sending message
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    try {
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {
      debugPrint("Error disposing engine: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Live Session: ${widget.channelName}',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Implement info action
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Implement settings action
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0), // Local video feed
                  ),
                )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _switchCamera,
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.switch_camera),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _endSession,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _showChatBottomSheet,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.chat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid!),
        ),
      );
    } else {
      return Center(
        child: Text(
          'Waiting for remote users...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }
}
