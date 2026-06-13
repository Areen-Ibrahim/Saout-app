import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/delete_player_controller.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/update_player_controller.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_goalKeeper_statistics.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_player-statistics.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/color.dart';
import '../../../../routes.dart';
import '../../widget/image_profile.dart';
import '../../widget/text_form_add_player.dart';
import '../../widget/text_title_add_player.dart';

class UpdatePlayerScreen extends StatefulWidget {
  @override
  _UpdatePlayerScreenState createState() => _UpdatePlayerScreenState();
}

class _UpdatePlayerScreenState extends State<UpdatePlayerScreen> {
  final UpdatePlayerController _updatePlayerController = Get.find();
  final PlayerController _playerController = Get.find();
  final DeletePlayerController deletePlayerController = Get.put(DeletePlayerController());
  late VideoPlayerController _videoPlayerController;
  bool _isLoadingVideo = false; // Loading state for the video

  @override
  void initState() {
    super.initState();
    String? playerId = Get.arguments['playerId'];
    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    if (passedTeamId != null) {
      _playerController.coachId.value = passedCoachId;
      _playerController.teamId.value = passedTeamId;
    }

    _playerController.playerId.value = playerId;
    _updatePlayerController.fetchPlayerData(playerId);
    }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(String videoUrl) {
    // Start loading the video and update the loading state.
    _isLoadingVideo = true; // Set loading to true when starting to load the video.

    // Check if the videoUrl is a valid URL or a File path.
    if (videoUrl.startsWith('http') || videoUrl.startsWith('https')) {
      _videoPlayerController = VideoPlayerController.network(videoUrl);
    } else {
      _videoPlayerController = VideoPlayerController.file(File(videoUrl));
    }

    // Use the `addListener` method to listen for changes to the video player state.
    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isInitialized) {
        setState(() {
          _isLoadingVideo = false; // Set loading to false once video is loaded.
        });
      }
    });

    // Initialize the video player and handle potential errors.
    _videoPlayerController.initialize().catchError((error) {
      setState(() {
        _isLoadingVideo = false; // Handle error and stop loading.
      });
      print("Error initializing video: $error"); // Log any errors.
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
        title: TextTitleAddPlayer(text: 'Edit Player Basic Info'),
      actions: [
        IconButton(
          onPressed: () async {
            // تأكيد الحذف
            bool? confirmDelete = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirm Delete'),
                content: Text('Are you sure you want to delete this player?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirmDelete == true) {
              // استدعاء دالة الحذف من PlayerController
              await deletePlayerController.deletePlayer(_playerController.playerId.value);
              // العودة إلى الصفحة الرئيسية بعد الحذف
              Get.toNamed(AppRoutes.homePage, arguments: {
                'coachId': _playerController.coachId.value,
                'teamId': _playerController.teamId.value,
              });
            }
          },
          icon: Icon(Icons.delete, color: Colors.red),
        )
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 33, horizontal: 22),
        child: GetBuilder<UpdatePlayerController>(builder: (_) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 19),
                Obx(() {
                  return ImageProfile(
                    playerImageUrl: _updatePlayerController.getPlayerImageUrl(),
                  );
                }),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => _updatePlayerController.pickImage(),
                  child: Text('Change Profile Image', style: TextStyle(fontSize: 12),),
                ),
                SizedBox(height: 20),
                TextFormAddPlayer(
                    controller: _updatePlayerController.firstNameController,
                    text: 'First Name'),
                TextFormAddPlayer(
                    controller: _updatePlayerController.lastNameController,
                    text: 'Last Name'),
                TextFormAddPlayer(
                    controller: _updatePlayerController.playerNumberController,
                    text: 'Player Id'),
                TextFormAddPlayer(
                    controller: _updatePlayerController.ageController,
                    text: 'Player Age'),
                TextFormAddPlayer(
                    controller: _updatePlayerController.cityController,
                    text: 'City'),
                TextFormAddPlayer(
                    controller: _updatePlayerController.heightController,
                    text: 'Player Height (cm)'),
                TextFormAddPlayer(
                    controller: _updatePlayerController.weightController,
                    text: 'Player Weight (kg)'),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _updatePlayerController.selectedType.value.isNotEmpty
                      ? _updatePlayerController.selectedType.value
                      : null,
                  hint: Text('Player Position'),
                  items: [
                    'Goalkeeper',
                    'Defender',
                    'Midfielder',
                    'Forward',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _updatePlayerController.selectedType.value = value;
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Obx(() {
                  final videoFile = _updatePlayerController.highlightVideo.value;
                  if (videoFile != null) {
                    _initializeVideoPlayer(videoFile.path); // Make sure to use .path if it's a File
                    return Column(
                      children: [
                        Text('Video Uploaded!', style: TextStyle(color: Colors.white)),
                        if (_isLoadingVideo) // Show loading indicator while the video is loading
                          CircularProgressIndicator(color: Colors.white)
                        else
                          Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: VideoPlayer(_videoPlayerController),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _videoPlayerController.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _videoPlayerController.value.isPlaying
                                            ? _videoPlayerController.pause()
                                            : _videoPlayerController.play();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    );
                  } else {
                    return Text('No Video Uploaded', style: TextStyle(color: Colors.white));
                  }
                }),
                // ElevatedButton(
                //   onPressed: () => _updatePlayerController.pickVideo(),
                //   child: Text('Change Highlight Video'),
                // ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Obx(() {
                    //   return ElevatedButton(
                    //     onPressed: _updatePlayerController.isLoading.value ? null : () async {
                    //       await _updatePlayerController.updatePlayerProfile();
                    //       Get.toNamed(AppRoutes.homePage, arguments: {
                    //         'coachId': _playerController.coachId.value,
                    //         'teamId': _playerController.teamId.value,
                    //       });
                    //     },
                    //     child: _updatePlayerController.isLoading.value
                    //         ? CircularProgressIndicator(color: Colors.white)
                    //         : Text('Update Player'),
                    //   );
                    // }),
                    ElevatedButton.icon(
                      iconAlignment: IconAlignment.start,
                      onPressed: () {
                        Future.delayed(Duration(milliseconds: 20), () {
                          Get.back();
                        });
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      label: Text("Back", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      iconAlignment: IconAlignment.end,
                      onPressed: () async {
                        if (_updatePlayerController.selectedType.value == 'Goalkeeper') {
                          Future.delayed(Duration(milliseconds: 20), () {
                            Get.to(() => UpdateGoalkeeperStatistics(), arguments: {
                              'playerId': _playerController.playerId.value,
                              'coachId': _playerController.coachId.value,
                              'teamId': _playerController.teamId.value,
                            },
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 770));
                          });
                        } else {
                          Future.delayed(Duration(milliseconds: 20), () {
                            Get.to(() => UpdatePlayerStatistics(), arguments: {
                              'playerId': _playerController.playerId.value,
                              'coachId': _playerController.coachId.value,
                              'teamId': _playerController.teamId.value,
                            },
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 770));
                          });
                        }
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                      label: Text("Next", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     if (_updatePlayerController.selectedType.value == 'Goalkeeper') {
                    //       // Get.toNamed(AppRoutes.updateGoalKeeperStatistics, arguments: {
                    //       //   'playerId': _playerController.playerId.value,
                    //       //   'coachId': _playerController.coachId.value,
                    //       //   'teamId': _playerController.teamId.value,
                    //       // });
                    //       Future.delayed(Duration(milliseconds: 20), () {
                    //         Get.to(() => UpdateGoalkeeperStatistics(), arguments: {
                    //           'playerId': _playerController.playerId.value,
                    //           'coachId': _playerController.coachId.value,
                    //           'teamId': _playerController.teamId.value,
                    //         },
                    //             transition: Transition.rightToLeft,
                    //             duration: const Duration(milliseconds: 770));
                    //       });
                    //     } else {
                    //       // Get.toNamed(AppRoutes.updatePlayerStatistics, arguments: {
                    //       //   'playerId': _playerController.playerId.value,
                    //       //   'coachId': _playerController.coachId.value,
                    //       //   'teamId': _playerController.teamId.value,
                    //       // });
                    //       Future.delayed(Duration(milliseconds: 20), () {
                    //         Get.to(() => UpdatePlayerStatistics(), arguments: {
                    //           'playerId': _playerController.playerId.value,
                    //           'coachId': _playerController.coachId.value,
                    //           'teamId': _playerController.teamId.value,
                    //         },
                    //             transition: Transition.rightToLeft,
                    //             duration: const Duration(milliseconds: 770));
                    //       });
                    //     }
                    //   },
                    //   child: Text('Next'),
                    // ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
