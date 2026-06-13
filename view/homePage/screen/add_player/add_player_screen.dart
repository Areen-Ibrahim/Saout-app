import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saoutapp/core/color.dart';
import 'package:saoutapp/view/homePage/screen/add_player/vedios_screen.dart';
import 'package:video_player/video_player.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../../controllers/controller_coach/team_controller.dart';
import '../../../signup/signupScout/widget/profile_picture.dart';
import '../../widget/text_form_add_player.dart';
import '../../widget/text_title_add_player.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final PlayerController playerController = Get.put(PlayerController());
  final _formKey = GlobalKey<FormState>();
  late VideoPlayerController? _videoPlayerController;
  final CoachController _coachController = Get.find();
  final TeamController _teamController = Get.find();

  @override
  void initState() {
    super.initState();
    playerController.requestStoragePermission();
    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    print(
        "Passed Coach ID addddddddddddddddddddddddddddddddddddddd: $passedCoachId"); // تحقق من هذه القيم
    print(
        "Passed Team ID adddddddddddddddddddddddddddddddddddddddd: $passedTeamId"); // تحقق من هذه القيم

    if (passedTeamId != null) {
      _coachController.coachId.value = passedCoachId;
      _teamController.teamId.value = passedTeamId;
    }
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    playerController.firstNameController.clear();
    playerController.lastNameController.clear();
    playerController.playerNumberController.clear();
    playerController.ageController.clear();
    playerController.heightController.clear();
    playerController.weightController.clear();
    playerController.cityController.clear();
    playerController.selectedType.value = ''; // إعادة تعيين النوع المحدد
    playerController.requestStoragePermission();
    playerController.profileImage.value = null;
    super.dispose();
  }

  Future<void> initializeVideoPlayer(File videoFile) async {
    _videoPlayerController = VideoPlayerController.file(videoFile);
    await _videoPlayerController!.initialize();
    setState(() {});
  }

  bool validateInputs() {
    if (playerController.firstNameController.text.isEmpty ||
        playerController.lastNameController.text.isEmpty ||
        playerController.playerNumberController.text.isEmpty ||
        playerController.ageController.text.isEmpty ||
        playerController.heightController.text.isEmpty ||
        playerController.weightController.text.isEmpty ||
        playerController.cityController.text.isEmpty) {
      return false;
    }
    return true;
  }

  final String defaultProfilePicture = 'image/avatarDefault.png';
  bool validateImage() {
    if (playerController.profileImage.value == null) {
      return false;  // الصورة غير موجودة
    }
    return true;  // الصورة موجودة
  }

  final List<String> teamTypeOptions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Forward',
  ];

  final selectedTeamType = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'Player Information'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // استخدم المفتاح هنا
            child: Column(
              children: [
                SizedBox(height: 19),
                // صورة الملف الشخصي
                Center(
                    child: ProfilePictureWidget(
                      pickImage: playerController.pickImage,
                      image: playerController.profileImage, // تأكد من أن الصورة هي Rx<File?>
                    ),
                    ),
                SizedBox(height: 19),
                // استخدم validator هنا
                TextFormAddPlayer(
                  controller: playerController.firstNameController,
                  text: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                TextFormAddPlayer(
                  controller: playerController.lastNameController,
                  text: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },

                ),
                TextFormAddPlayer(
                  controller: playerController.playerNumberController,
                  text: 'Player Id',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter player ID';
                    }
                    return null;
                  },
                ),
                TextFormAddPlayer(
                  controller: playerController.ageController,
                  text: 'Player Age',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age';
                    } if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Please enter numbers only';
                    } if (!RegExp(r'^(6|[7-9]|1[0-7]|18)$').hasMatch(value)) {
                      return 'Age must be between 6 and 18';
                    }
                    return null;
                  },
                ),

                TextFormAddPlayer(
                  controller: playerController.cityController,
                  text: 'City',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                  type: TextInputType.text,

                ),
                TextFormAddPlayer(
                  controller: playerController.heightController,
                  text: 'Player Height (cm)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Height';
                    } if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Please enter numbers only';
                    }
                    return null;
                  },
                ),
                TextFormAddPlayer(
                  controller: playerController.weightController,
                  text: 'Player Weight (kg)',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter weight';
                    } if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'Please enter numbers only';
                    }
                    return null;
                  },


                ),
                SizedBox(height: 20),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: selectedTeamType.value.isNotEmpty ? selectedTeamType
                        .value : null,
                    hint: Text('Player Position'),
                    items: teamTypeOptions.map<DropdownMenuItem<String>>((
                        String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedTeamType.value = value;
                        playerController.selectedType.value = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a position';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  );
                }),
                // حقل إدخال الفيديو
                // SizedBox(height: 50),
                // Divider(),
                // TextTitleAddPlayer(text: 'Video'),
                // Divider(),
                // SizedBox(height: 20),
                // MaterialButton(
                //   color: Colors.purple,
                //   onPressed: ()  {
                //     // await playerController.pickVideo();
                //     // if (playerController.highlightVideo.value != null) {
                //     //   await initializeVideoPlayer(
                //     //       playerController.highlightVideo.value!);
                //     // }
                //     Get.to(() => VideoUploadPage());
                //   },
                //   child: Text(
                //       "Choose Video", style: TextStyle(color: Colors.white)),
                // ),
                // SizedBox(height: 10),
                // if (_videoPlayerController != null &&
                //     _videoPlayerController!.value.isInitialized)
                //   Column(
                //     children: [
                //       AspectRatio(
                //         aspectRatio: _videoPlayerController!.value.aspectRatio,
                //         child: VideoPlayer(_videoPlayerController!),
                //       ),
                //       SizedBox(height: 10),
                //       MaterialButton(
                //         color: Colors.green,
                //         onPressed: () {
                //           setState(() {
                //             _videoPlayerController!.value.isPlaying
                //                 ? _videoPlayerController!.pause()
                //                 : _videoPlayerController!.play();
                //           });
                //         },
                //         child: Text(
                //           _videoPlayerController!.value.isPlaying
                //               ? "Pause Video"
                //               : "Play Video",
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ),
                //     ],
                //   ),
                SizedBox(height: 19),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        if (_formKey.currentState!.validate() && validateImage()) {
                          playerController.validateAndProceed();
                        }else {
                          if (!validateImage()) {
                            Get.snackbar(
                              "Error",
                              "Please select a profile picture",
                              backgroundColor: ColorApp.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.white),
                      label: Text("Next", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class VideoUploadPage extends StatefulWidget {
//   @override
//   _VideoUploadPageState createState() => _VideoUploadPageState();
// }
//
// class _VideoUploadPageState extends State<VideoUploadPage> {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final PlayerController playerController = Get.put(PlayerController());
//
//   File? selectedVideo;
//   String? videoUrl;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorApp.background,
//       appBar: AppBar(
//         backgroundColor: Colors.white10,
//         title: TextTitleAddPlayer(text: 'Add Videos'),
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // قائمة الفيديوهات الموجودة
//             Obx(() {
//               return Expanded(
//                 child: ListView.builder(
//                   itemCount: playerController.videos.length,
//                   itemBuilder: (context, index) {
//                     var video = playerController.videos[index];
//                     final titleController = TextEditingController(text: video['title']);
//                     final descriptionController = TextEditingController(text: video['description']);
//
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 10),
//                       child: Dismissible(
//                         key: Key(video['title']!),
//                         onDismissed: (direction) {
//                           setState(() {
//                             playerController.videos.removeAt(index);
//                           });
//                           Get.snackbar('Video Removed', 'The video has been removed.');
//                         },
//                         background: Container(
//                           color: Colors.red,
//                           alignment: Alignment.centerRight,
//                           padding: EdgeInsets.symmetric(horizontal: 20),
//                           child: Icon(Icons.delete, color: Colors.white),
//                         ),
//                         child: Card(
//                           elevation: 4,
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 TextField(
//                                   controller: titleController,
//                                   decoration: InputDecoration(labelText: 'Video Title'),
//                                   onChanged: (value) {
//                                     playerController.videos[index]['title'] = value;
//                                   },
//                                 ),
//                                 SizedBox(height: 10),
//                                 TextField(
//                                   controller: descriptionController,
//                                   decoration: InputDecoration(labelText: 'Video Description'),
//                                   onChanged: (value) {
//                                     playerController.videos[index]['description'] = value;
//                                   },
//                                 ),
//                                 SizedBox(height: 10),
//                                 ElevatedButton(
//                                   onPressed: () async {
//                                     await _pickVideo();
//                                   },
//                                   child: Text('Select Video'),
//                                 ),
//                                 SizedBox(height: 10),
//                                 // زر لمعاينة الفيديو
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     if (video['videoUrl'] != null) {
//                                       _showVideoPlayer(video['videoUrl']!);
//                                     }
//                                   },
//                                   child: Text('Watch Video'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             }),
//
//             // زر إضافة Card جديد
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: Icon(Icons.add, size: 40, color: ColorApp.oasisGreen),
//                   onPressed: () {
//                     // إضافة مجموعة جديدة مع العنوان والوصف فقط
//                     playerController.videos.add({
//                       'title': '',
//                       'description': '',
//                       'videoUrl': '',
//                     });
//                     setState(() {});
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // وظيفة لاختيار فيديو من المعرض
//   Future<void> _pickVideo() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         selectedVideo = File(pickedFile.path);
//       });
//     } else {
//       Get.snackbar('Error', 'No video selected.');
//     }
//   }
//
//   // وظيفة لعرض الفيديو باستخدام video_player
//   void _showVideoPlayer(String videoUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VideoPlayerPage(videoUrl: videoUrl),
//       ),
//     );
//   }
// }
//
// class VideoPlayerPage extends StatefulWidget {
//   final String videoUrl;
//
//   VideoPlayerPage({required this.videoUrl});
//
//   @override
//   _VideoPlayerPageState createState() => _VideoPlayerPageState();
// }
//
// class _VideoPlayerPageState extends State<VideoPlayerPage> {
//   late VideoPlayerController _controller;
//   bool isMuted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Video Player')),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // زر إيقاف/تشغيل الفيديو
//                 IconButton(
//                   icon: Icon(
//                     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _controller.value.isPlaying ? _controller.pause() : _controller.play();
//                     });
//                   },
//                 ),
//                 // زر إيقاف/تشغيل الصوت
//                 IconButton(
//                   icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
//                   onPressed: () {
//                     setState(() {
//                       isMuted = !isMuted;
//                       _controller.setVolume(isMuted ? 0 : 1);
//                     });
//                   },
//                 ),
//                 // زر التقديم والتأخير
//                 IconButton(
//                   icon: Icon(Icons.fast_forward),
//                   onPressed: () {
//                     _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.fast_rewind),
//                   onPressed: () {
//                     _controller.seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
//                   },
//                 ),
//               ],
//             ),
//           ],
//         )
//             : CircularProgressIndicator(),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }
