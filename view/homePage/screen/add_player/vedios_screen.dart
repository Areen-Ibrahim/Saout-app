import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../core/color.dart';
import '../../widget/text_title_add_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'achievements_player_screen.dart';

class VideoUploadPage extends StatefulWidget {
  @override
  _VideoUploadPageState createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> {
  final PlayerController playerController = Get.put(PlayerController());
  bool _isVideoPlaying = false;
  bool _isMuted = false; // التحكم في الصوت
  List<VideoPlayerController?> _controllers = [];
  List<String?> _thumbnailPaths = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'Add Videos'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (playerController.videos.isEmpty) {
                  return Center(child: Text('No videos added.'));
                }

                return ListView.builder(
                  itemCount: playerController.videos.length,
                  itemBuilder: (context, index) {
                    var video = playerController.videos[index];
                    final titleController = TextEditingController(
                        text: video['title']);
                    final descriptionController = TextEditingController(
                        text: video['description']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: Key(video['title']!),
                        onDismissed: (direction) {
                          setState(() {
                            playerController.videos.removeAt(index);
                            _controllers[index]?.dispose();
                            _controllers.removeAt(index);
                          });
                          Get.snackbar(
                              'Video Removed', 'The video has been removed.');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 4,
                          color: Colors.white54,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                      labelText: 'Video Title'),
                                  onChanged: (value) {
                                    playerController.videos[index]['title'] =
                                        value;
                                  },
                                ),
                                SizedBox(height: 10),
                                SingleChildScrollView(
                                  child: TextField(
                                    controller: descriptionController,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        labelText: 'Video Description'),
                                    onChanged: (value) {
                                      playerController
                                          .videos[index]['description'] = value;
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                video['videoUrl'] != null &&
                                    video['videoUrl']!.isNotEmpty
                                    ? GestureDetector(
                                  onTap: () {
                                    bool isLocal = File(video['videoUrl']!)
                                        .existsSync();
                                    _playOrPauseVideo(
                                        index, video['videoUrl']!, isLocal);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      image: _thumbnailPaths.isNotEmpty &&
                                          _thumbnailPaths[index] != null
                                          ? DecorationImage(
                                        image: FileImage(
                                            File(_thumbnailPaths[index]!)),
                                        fit: BoxFit.cover,
                                      )
                                          : null,
                                    ),
                                    child: _isVideoPlaying
                                        ? _buildVideoPlayer(
                                        index, video['videoUrl']!)
                                        : Center(
                                      child: Icon(
                                        _isVideoPlaying ? Icons.pause : Icons
                                            .play_arrow,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                )
                                    : ElevatedButton(
                                  onPressed: () async {
                                    await _pickVideo(index);
                                  },
                                  child: Text('Select Video'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  playerController.videos.add({
                    'title': '',
                    'description': '',
                    'videoUrl': '',
                  });
                  _controllers.add(null);
                  _thumbnailPaths.add(null);
                  setState(() {});
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorApp.oasisGreen,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  label: Text('Back', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.oasisGreen,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Future.delayed(Duration(milliseconds: 20), () {
                      Get.to(() => AchievementsPlayerScreen(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 770));
                    });
                    },
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  iconAlignment: IconAlignment.end,
                  label: Text('Next', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorApp.oasisGreen,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        playerController.videos[index]['videoUrl'] = pickedFile.path;
      });

      _generateThumbnail(index, pickedFile.path);
    } else {
      Get.snackbar('Error', 'No video selected.');
    }
  }

  Future<void> _generateThumbnail(int index, String videoPath) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      quality: 75,
    );

    setState(() {
      _thumbnailPaths[index] = thumbnail;
    });
  }



  Widget _buildVideoPlayer(int index, String videoPath) {
    if (_controllers[index] == null || !_controllers[index]!.value.isInitialized) {
      _controllers[index] = VideoPlayerController.file(File(videoPath))
        ..initialize().then((_) {
          setState(() {});
          _controllers[index]!.play();
        }).catchError((error) {
          Get.snackbar('Error', 'Failed to load video.');
        });
    }

    // الحصول على أبعاد الفيديو الأصلية
    double videoWidth = _controllers[index]!.value.size.width;
    double videoHeight = _controllers[index]!.value.size.height;

    return Stack(
      children: [
        // خلفية سوداء مع الفيديو
        Center(
          child: Container(
            color: Colors.black, // الخلفية السوداء
            child: FittedBox(
              fit: BoxFit.contain, // الحفاظ على الأبعاد الأصلية مع التصغير
              child: SizedBox(
                width: videoWidth,
                height: videoHeight,
                child: AspectRatio(
                  aspectRatio: _controllers[index]!.value.aspectRatio,
                  child: VideoPlayer(_controllers[index]!),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: videoHeight / 2 - 25,
          left: videoWidth / 2 - 25,
          child: IconButton(
            icon: Icon(
              _controllers[index]!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              _playOrPauseVideo(index, videoPath, true); // استدعاء الدالة مع isLocal = true
            },
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _toggleMute(index);
            },
          ),
        ),
      ],
    );
  }




  void _playOrPauseVideo(int index, String videoPath, bool isLocal) {
    for (var i = 0; i < _controllers.length; i++) {
      if (i != index) {
        _controllers[i]?.pause();
      }
    }

    if (_controllers[index] != null && _controllers[index]!.value.isPlaying) {
      _controllers[index]!.pause();
      setState(() {
        _isVideoPlaying = false;
      });
    } else {
      _controllers[index]?.play();
      setState(() {
        _isVideoPlaying = true;
      });
    }
  }

  void _toggleMute(int index) {
    setState(() {
      _isMuted = !_isMuted;
      _controllers[index]?.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _toggleFullScreen(int index) {
    setState(() {
      double screenWidth = MediaQuery
          .of(context)
          .size
          .width;
      double screenHeight = MediaQuery
          .of(context)
          .size
          .height;

      if (screenWidth == _controllers[index]!.value.size.width &&
          screenHeight == _controllers[index]!.value.size.height) {
        _controllers[index]!.setVolume(1);
      } else {
        _controllers[index]!.setVolume(0);
      }
    });
  }
}

