import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_achievements_player.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../../../../controllers/controller_coach/player_controller/update_player_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/loading.dart';
import '../../widget/text_title_add_player.dart';

class UpdateVideoScreen extends StatefulWidget {
  final String playerId;

  const UpdateVideoScreen({required this.playerId, Key? key}) : super(key: key);

  @override
  State<UpdateVideoScreen> createState() => _UpdateVideoScreenState();
}

class _UpdateVideoScreenState extends State<UpdateVideoScreen> {
  late UpdatePlayerController _updatePlayerController;
  late List<VideoPlayerController?> _controllers = []; // قائمة ديناميكية
  late List<bool> _isVideoPlayingList = [];           // قائمة ديناميكية


  @override
  void initState() {
    super.initState();
    _updatePlayerController = Get.find<UpdatePlayerController>();
    _isVideoPlayingList = [];
    _controllers = [];
    _fetchVideos();

  }

  Future<void> _fetchVideos() async {
    // إذا كانت قائمة الفيديوهات فارغة، قم بتحميل الفيديوهات
    if (_updatePlayerController.videos.isEmpty) {
      setState(() {
        _updatePlayerController.isLoading.value = true;
      });

      await _updatePlayerController.fetchVideos(widget.playerId);

      if (!mounted) return;

      setState(() {
        // تأكد من تهيئة القوائم بناءً على عدد الفيديوهات
        _controllers = List.generate(
          _updatePlayerController.videos.length,
              (_) => null,
        );
        _isVideoPlayingList = List.filled(_updatePlayerController.videos.length, false);
        _updatePlayerController.isLoading.value = false;
      });
    }
  }


  void _playOrPauseVideo(int index) {
    if (_controllers.isEmpty || index < 0 || index >= _controllers.length) return;

    // تحقق من أن VideoPlayerController تم تهيئته
    if (_controllers[index] == null) {
      // Get.snackbar('Error', 'Video is not loaded properly.');
       print('Video is not loaded properly.');
      // تحميل الفيديو في حال عدم تحميله
      final videoPath = _updatePlayerController.videos[index]['videoUrl'] ?? '';
      if (videoPath.isNotEmpty) {
        final isLocal = File(videoPath).existsSync();
        _controllers[index] = isLocal
            ? VideoPlayerController.file(File(videoPath))
            : VideoPlayerController.network(videoPath);

        // بدء تحميل الفيديو
        _controllers[index]!.initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controllers[index]!.play();
            setState(() {
              _isVideoPlayingList[index] = true;
            });
          }
        }).catchError((e) {
          // Get.snackbar('Error', 'Failed to load video: $e');
          print('Failed to load video: $e');
        });
      }
      return;
    }

    // إذا كان الفيديو قيد التشغيل، إيقافه
    if (_controllers[index]!.value.isPlaying) {
      _controllers[index]!.pause();
      setState(() {
        _isVideoPlayingList[index] = false;
      });
    } else {
      // إيقاف الفيديوهات الأخرى
      for (int i = 0; i < _controllers.length; i++) {
        if (i != index && _controllers[i] != null) {
          _controllers[i]!.pause();
          _isVideoPlayingList[i] = false;
        }
      }
      // تشغيل الفيديو المحدد
      _controllers[index]!.play();
      setState(() {
        _isVideoPlayingList[index] = true;
      });
    }
  }

  Widget _buildVideoPlayer(int index, String videoPath) {
    if (_controllers[index] == null) {
      final isLocal = File(videoPath).existsSync();
      _controllers[index] = isLocal
          ? VideoPlayerController.file(File(videoPath))
          : VideoPlayerController.network(videoPath);

      _controllers[index]!.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((e) {
        Get.snackbar('Error', 'Failed to load video: $e');
      });
    }

    return _controllers[index]!.value.isInitialized
        ? FittedBox(
      fit: BoxFit.contain, // لضمان الحفاظ على أبعاد الفيديو الأصلية
      child: SizedBox(
        width: _controllers[index]!.value.size.width,
        height: _controllers[index]!.value.size.height,
        child: VideoPlayer(_controllers[index]!),
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }



  Future<void> _pickVideo(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (index < _updatePlayerController.videos.length) {
          _updatePlayerController.videos[index]['videoUrl'] = pickedFile.path;
        }
      });
    } else {
      Get.snackbar('Error', 'No video selected.');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'Edit Videos'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (_updatePlayerController.isLoading.value) {
                  return const Loading();
                }
                if (_updatePlayerController.videos.isEmpty) {
                  return const Center(child: Text('No videos added.'));
                }

                return ListView.builder(
                  itemCount: _updatePlayerController.videos.length,
                  itemBuilder: (context, index) {
                    final video = _updatePlayerController.videos[index];
                    final titleController = TextEditingController(text: video['title']);
                    final descriptionController = TextEditingController(text: video['description']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: Key(video['title'] ?? 'video_$index'),
                        onDismissed: (direction) {
                          setState(() {
                            _updatePlayerController.videos.removeAt(index);

                            // إزالة الفيديو من قائمة الـ controllers و الـ isVideoPlayingList
                            _controllers.removeAt(index);
                            _isVideoPlayingList.removeAt(index);

                            Get.snackbar('Video Removed', 'The video has been removed.');
                          });
                          // Get.snackbar('Video Removed', 'The video has been removed.');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          elevation: 4,
                          color: Colors.white54,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(labelText: 'Video Title'),
                                  onChanged: (value) {
                                    _updatePlayerController.videos[index]['title'] = value;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: descriptionController,
                                  decoration: const InputDecoration(labelText: 'Video Description'),
                                  onChanged: (value) {
                                    _updatePlayerController.videos[index]['description'] = value;
                                  },
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => _playOrPauseVideo(index),
                                  child:  video['videoUrl'] != null && video['videoUrl']!.isNotEmpty
                                      ? Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: const BoxDecoration(color: Colors.black),
                                    child: index >= 0 && index < _isVideoPlayingList.length && _isVideoPlayingList[index]
                                        ? _buildVideoPlayer(index, video['videoUrl']!)
                                        : const Center(
                                      child: Icon(Icons.play_arrow, color: Colors.white, size: 50),
                                    ),
                                  )
                                      : ElevatedButton(
                                    onPressed: () async {
                                      await _pickVideo(index);
                                    },
                                    child: const Text('Select Video'),
                                  ),
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
            const SizedBox(height: 10),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updatePlayerController.videos.add({'title': '', 'description': '', 'videoUrl': ''});
                      _controllers.add(null);
                      setState(() {
                        _isVideoPlayingList.add(false);
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Video'),
                    style: ElevatedButton.styleFrom(backgroundColor: ColorApp.oasisGreen),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                       Get.back();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text('Back',style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: ColorApp.oasisGreen),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Future.delayed(Duration(milliseconds: 20), () {
                          Get.to(() => UpdateAchievementsScreen(),
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
