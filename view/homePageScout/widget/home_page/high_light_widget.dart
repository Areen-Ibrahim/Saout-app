import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:video_player/video_player.dart';

class HighlightsWidget extends StatefulWidget {
  final List<String> playerIds;

  HighlightsWidget({required this.playerIds});

  @override
  _HighlightsWidgetState createState() => _HighlightsWidgetState();
}

class _HighlightsWidgetState extends State<HighlightsWidget> {
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, bool> _isPlayingMap = {};

  // دالة لجلب فيديوهات جميع اللاعبين
  Future<List<Map<String, String>>> _fetchAllPlayerVideos(List<String> playerIds) async {
    List<Map<String, String>> allVideos = [];

    for (String playerId in playerIds) {
      try {
        List<Map<String, String>> playerVideos = await getPlayerVideos(playerId);
        allVideos.addAll(playerVideos);
      } catch (e) {
        print('Error fetching videos for player $playerId: $e');
      }
    }

    return allVideos;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _fetchAllPlayerVideos(widget.playerIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading highlights'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No highlights available'));
        }

        final videos = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final videoUrl = videos[index]['videoUrl'];
            final title = videos[index]['title'] ?? 'Player Video';
            final description = videos[index]['description'] ?? '';
            final isPlaying = _isPlayingMap[index] ?? false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () => _toggleVideoPlayback(index, videoUrl),
                  ),
                ),
                if (_videoControllers.containsKey(index) &&
                    _videoControllers[index]!.value.isInitialized)
                  AspectRatio(
                    aspectRatio: _videoControllers[index]!.value.aspectRatio,
                    child: VideoPlayer(_videoControllers[index]!),
                  ),
                Divider(),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleVideoPlayback(int index, String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      return;
    }

    if (_videoControllers.containsKey(index)) {
      final controller = _videoControllers[index]!;
      if (_isPlayingMap[index] == true) {
        await controller.pause();
      } else {
        await controller.play();
      }
      setState(() {
        _isPlayingMap[index] = !_isPlayingMap[index]!;
      });
    } else {
      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      setState(() {
        _videoControllers[index] = controller;
        _isPlayingMap[index] = true;
      });
      controller.play();
    }
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}



Future<List<Map<String, String>>> getPlayerVideos(String playerId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('players')
        .doc(playerId)
        .get();

    Map<String, dynamic>? data = snapshot.data();
    if (data['videos'] == null || !(data['videos'] is List)) {
      return []; // إذا لم يكن هناك فيديوهات
    }

    // تحويل الفيديوهات إلى قائمة من الخرائط
    return List<Map<String, String>>.from(
      data['videos'].map((video) => Map<String, String>.from(video as Map)),
    );
  } catch (e) {
    print('Error fetching videos for player $playerId: $e');
    return [];
  }
}
