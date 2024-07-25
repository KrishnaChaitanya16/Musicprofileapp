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
    // Retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    // Check if permissions are granted
    if (await Permission.camera.isGranted && await Permission.microphone.isGranted) {
      // Create the engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("local user ${connection.localUid} joined");
            setState(() {
              _localUserJoined = true;
            });
            _storeLiveSession();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("remote user $remoteUid joined");
            setState(() {
              _remoteUid = remoteUid;
            });
            _updateParticipantList();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left channel");
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
      // Show an error message if permissions are not granted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please grant camera and microphone permissions.')),
      );
    }
  }

  Future<void> _storeLiveSession() async {
    await _sessionRef.set({
      'channelName': widget.channelName,
      'status': 'ongoing',
      'startTime': Timestamp.now(),
      'participants': [],
    });
  }

  Future<void> _updateParticipantList() async {
    final doc = await _sessionRef.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null) {
      final participants = List<int>.from(data['participants'] ?? []);
      if (_remoteUid != null && !participants.contains(_remoteUid!)) {
        participants.add(_remoteUid!);
      }
      await _sessionRef.update({'participants': participants});
    }
  }

  Future<void> _endSession() async {
    await _engine.leaveChannel();
    await _engine.release();
    await _sessionRef.update({
      'status': 'completed',
      'endTime': Timestamp.now(),
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Session'),
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
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              onPressed: _endSession,
              backgroundColor: Colors.red,
              child: const Icon(Icons.call_end),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid!),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
