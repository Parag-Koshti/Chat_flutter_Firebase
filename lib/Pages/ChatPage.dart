import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/Components/videoFullscreen.dart';
import 'package:chat/services/chatservice/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../Components/imageFullscreen.dart';

class ChatPage extends StatefulWidget {
  final String reciverUserEmail;
  final String reciverUserID;
  final String reciverUsername;

  const ChatPage({
    super.key,
    required this.reciverUserEmail,
    required this.reciverUserID,
    required this.reciverUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

enum MediaType { photo, video }

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  File? _media;
  MediaType? _mediaType;
  final Map<String, VideoPlayerController> _videoControllers = {};

  List<String> _pendingUploads = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _chatService.sendMessage(
          widget.reciverUserID,
          _messageController.text,
          widget.reciverUsername,
          isImage: false,
          mediaUrl: null, // No media URL for text messages
          hasMedia: false, // No media for text messages
        );
        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        print("Error sending message: $e");
      }
    } else {
      print("Error: Message is empty");
    }
  }

  Future<void> sendMedia() async {
    if (_media != null) {
      final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _pendingUploads.add(tempId);
      });

      try {
        final storageRef = FirebaseStorage.instance.ref();
        final uploadTask = storageRef
            .child(
                '${_mediaType == MediaType.photo ? 'images' : 'videos'}/${DateTime.now().millisecondsSinceEpoch}')
            .putFile(_media!);
        final snapshot = await uploadTask.whenComplete(() => null);
        final url = await snapshot.ref.getDownloadURL();

        print("Uploaded media URL: $url");

        await _chatService.sendMessage(
          widget.reciverUserID,
          url,
          widget.reciverUsername,
          isImage: _mediaType == MediaType.photo,
          mediaUrl: url, // Media URL for media messages
          hasMedia: true, // Media is present for media messages
        );

        setState(() {
          _pendingUploads.remove(tempId);
        });

        _media = null;
        _scrollToBottom();
      } catch (e) {
        print("Error uploading media: $e");
        setState(() {
          _pendingUploads.remove(tempId);
        });
      }
    } else {
      print("Error: No media selected");
    }
  }

  Future<void> _selectAndSendMedia(MediaType mediaType) async {
    final XFile? media;
    if (mediaType == MediaType.photo) {
      media = await _imagePicker.pickImage(source: ImageSource.gallery);
    } else {
      media = await _imagePicker.pickVideo(source: ImageSource.gallery);
    }
    if (media != null) {
      final File file = File(media.path);
      _media = file;
      _mediaType = mediaType;
      await sendMedia();
      _media = null;
    } else {
      print("No media selected");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _initializeVideoPlayer(String url) async {
    if (!_videoControllers.containsKey(url)) {
      try {
        print("Initializing video player with URL: $url");
        VideoPlayerController controller = VideoPlayerController.network(url);
        await controller.initialize();
        setState(() {
          _videoControllers[url] = controller;
        });
      } catch (e) {
        print('Error initializing video player: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _videoControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(child: _buildMessageList()),
            _messageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessage(
        _firebaseAuth.currentUser!.uid,
        widget.reciverUserID,
      ),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView(
          controller: _scrollController,
          children: [
            ...snapshot.data!.docs.map((document) {
              return _buildMessageItem(document);
            }).toList(),
            ..._pendingUploads.map((tempId) => _buildShimmerItem()).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var isCurrentUser = data['SenderId'] == _firebaseAuth.currentUser!.uid;
    var alignment = isCurrentUser ? Alignment.topRight : Alignment.topLeft;
    var bgColor = isCurrentUser ? Colors.blue : Colors.grey[200];
    var textColor = isCurrentUser ? Colors.white : Colors.black;
    var timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    var formattedTime = DateFormat('hh:mm a').format(timestamp);

    if (data['isImage'] == true) {
      // Image message
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoDialogRoute(
                        builder: (context) => FullImageScreen(
                              imageUrl: data['message'],
                            ),
                        context: context));
              },
              child: Container(
                alignment: alignment,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    height: 250,
                    width: 150,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: data['message'],
                      placeholder: (context, url) => _buildSkeletonView(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            if (isCurrentUser)
              Icon(Icons.image, color: Colors.grey[400], size: 18),
            if (!isCurrentUser)
              Icon(Icons.image, color: Colors.grey[600], size: 18),
          ],
        ),
      );
    } else if (data['hasMedia'] == true) {
      // Video message
      _initializeVideoPlayer(data['message']);
      return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _videoControllers.containsKey(data['message'])
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenVideoPage(
                              videoUrl: data['message'],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          height: 250,
                          width: 150,
                          child: AspectRatio(
                            aspectRatio: _videoControllers[data['message']]!
                                .value
                                .aspectRatio,
                            child: Stack(
                              children: [
                                VideoPlayer(
                                  _videoControllers[data['message']]!,
                                ),
                                Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : _buildSkeletonView(),
            if (isCurrentUser)
              Icon(Icons.videocam, color: Colors.grey[400], size: 18),
            if (!isCurrentUser)
              Icon(Icons.videocam, color: Colors.grey[600], size: 18),
          ],
        ),
      );
    } else {
      // Text message
      return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    data['message'],
                    style: TextStyle(color: textColor),
                  ),
                  SizedBox(height: 5),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSkeletonView() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.grey[300],
        ),
        height: 250,
        width: 150,
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.topRight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildSkeletonView(),
            ),
          ),
          Icon(Icons.image, color: Colors.grey[400], size: 18),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Material(
      elevation: 5,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          children: [
            SizedBox(
              height: 5,
            ),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                )),
            SizedBox(
              width: MediaQuery.of(context).size.height * 0.12,
            ),
            Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/b1.jpg'),
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.reciverUsername,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _messageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () async {
                await _selectAndSendMedia(MediaType.photo);
              },
              icon: Icon(CupertinoIcons.camera_fill)),
          IconButton(
              onPressed: () async {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    title: Text('Select Media Type'),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          _selectAndSendMedia(MediaType.photo);
                        },
                        child: Text('Photo'),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                          _selectAndSendMedia(MediaType.video);
                        },
                        child: Text('Video'),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.photo)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  suffixIcon: IconButton(
                    onPressed: sendMessage,
                    icon: Icon(
                      CupertinoIcons.arrow_up_circle_fill,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
