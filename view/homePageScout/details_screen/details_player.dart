import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/controllers/controller_scout/welcome_controller/all_players_controller.dart';
import 'package:saoutapp/core/loading.dart';
import 'package:saoutapp/routes.dart';
import 'package:saoutapp/view/homePageScout/screen/compare_player.dart';
import 'package:video_player/video_player.dart';
import '../../../core/color.dart';
import '../../../core/date.dart';
import '../../homePage/screen/home_page_coach/chart.dart';
import '../../homePage/screen/home_page_coach/pdf_screen.dart';
import '../../homePage/widget/chart_screen.dart';
import '../../homePage/widget/text_title_add_player.dart';

class PlayerDetailScreen extends StatefulWidget {
  const PlayerDetailScreen({super.key});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  final AllPlayersController allPlayersController = Get.find<AllPlayersController>();
  late String playerId;
  final PlayerController playerController = Get.put(PlayerController());
  final UserController userController = Get.find();

  final PageController _pageController = PageController();
  RxInt activePage = 0.obs;

  @override
  void initState() {
    super.initState();
    String? id = Get.arguments['playerId'];
    playerId = id;
    playerController.playerId.value = id;
    print('Player ID: $playerId');
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'Player Details',),
        iconTheme: IconThemeData(color: Colors.white, size: 20),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: allPlayersController.getPlayerDetails(playerId),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if  (snapshot.hasError) {
            // طباعة الخطأ في الكونسول
            debugPrint('Error loading player details: ${snapshot.error}');
            debugPrint('Stack trace: ${snapshot.stackTrace}'); // طباعة الـ StackTrace لمعرفة مكان الخطأ بالتحديد

            return Center(
              child: Text(
                'Error loading player details: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Player not found.'));
          } else {
            Map<String, dynamic> player = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: _getImageProvider(player['image']),
                          radius: 30,
                        ),
                        title: Text(
                          '${player['firstName']} ${player['lastName']}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          '${player['position'].toString()}',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Get.to(
                                        () => ComparePlayer(),
                                    arguments: {
                                      'playerId': playerId,
                                      'position': player['position']
                                    },
                                    transition: Transition.zoom,
                                    duration: const Duration(milliseconds: 660),
                                  );
                                });
                              },
                              icon: Icon(Icons.group_outlined, color: Colors.greenAccent),
                            ),
                            IconButton(
                              onPressed: () {
                                generatePlayerPDF(player);
                              },
                              icon: Icon(Icons.file_copy, color: ColorApp.oasisGreen,),
                            ),
                            Obx(() {
                              bool isFollowing = userController.isFollowing(playerId);
                              bool isLoading = userController.loadingPlayerId.value == playerId;

                              return isLoading
                                  ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                                )
                                  : IconButton(
                                onPressed: () async {
                                  await userController.toggleFollowPlayer(userController.currentUserUid.value, playerId);
                                },
                                icon: Icon(
                                  isFollowing ? Icons.check_circle : Icons.add_circle_outline_rounded,
                                  color: isFollowing ? Colors.green : Colors.white,
                                  size: 23,
                                ),
                              );
                            }),

                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),

                // أزرار التنقل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(0);
                            activePage.value = 0; // تحديث الحالة النشطة
                          },
                          child: Text(
                            'Basic Info',
                            style: TextStyle(color: activePage.value == 0 ? Colors.white : Colors.grey),
                          ),
                        )),
                        Obx(() => Container(
                          height: 2,
                          width: 80,
                          color: activePage.value == 0 ? Colors.green : Colors.transparent,
                        )),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(1);
                            activePage.value = 1;
                          },
                          child: Text(
                            'Position Stats',
                            style: TextStyle(color: activePage.value == 1 ? Colors.white : Colors.grey),
                          ),
                        )),
                        Obx(() => Container(
                          height: 2,
                          width: 80,
                          color: activePage.value == 1 ? Colors.green : Colors.transparent,
                        )),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(2);
                            activePage.value = 2;
                          },
                          child: Text(
                            'Achievements',
                            style: TextStyle(color: activePage.value == 2 ? Colors.white : Colors.grey),
                          ),
                        )),
                        Obx(() => Container(
                          height: 2,
                          width: 80,
                          color: activePage.value == 2 ? Colors.green : Colors.transparent,
                        )),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(3);
                            activePage.value = 3;
                          },
                          child: Text(
                            'Vedio',
                            style: TextStyle(color: activePage.value == 3 ? Colors.white : Colors.grey),
                          ),
                        )),
                        Obx(() => Container(
                          height: 2,
                          width: 80,
                          color: activePage.value == 3 ? Colors.green : Colors.transparent,
                        )),
                      ],
                    ),
                  ],
                ),

                // صفحة التفاصيل مع الانيميشن
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      activePage.value = index;
                    },
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            AnimatedOpacity(
                              opacity: 1,
                              duration: Duration(seconds: 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabelValue('Height:', '${player['height'].toString()} cm'),
                                  _buildLabelValue('Weight:', '${player['weight'].toString()} kg'),
                                  _buildLabelValue('Position:', player['position']),
                                  _buildLabelValue('City:', player['city']),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // الصفحة الثانية مع انيميشن
                      AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        child: _displayPlayerStats(player),
                      ),
                    // الصفحة الثالثة
                      if (player['achievements'] != null && player['achievements'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(player['achievements'].length, (index) {
                                final achievement = player['achievements'][index];
                                String formattedDate = formatDateAch(achievement['date'] ?? ""); // تنسيق التاريخ

                                return Card(
                                  color: Colors.grey[900], // لون خلفية الكارد
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // عنوان الإنجاز
                                        TextField(
                                          controller: TextEditingController(text: achievement['title'] ?? "No Title"),
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: "Title",
                                            labelStyle: TextStyle(color: Colors.grey),
                                            border: OutlineInputBorder(),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 16),

                                        // حقول التاريخ والنوع في صف واحد
                                        Row(
                                          children: [
                                            // حقل التاريخ
                                            Expanded(
                                              child: TextField(
                                                controller: TextEditingController(text: formattedDate),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: "Date",
                                                  labelStyle: TextStyle(color: Colors.grey),
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12), // مسافة بين الحقول

                                            // حقل النوع
                                            Expanded(
                                              child: TextField(
                                                controller: TextEditingController(text: achievement['type'] ?? "Unknown"),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  labelText: "Type",
                                                  labelStyle: TextStyle(color: Colors.grey),
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        )
                      else
                      // رسالة إذا لم تكن هناك إنجازات
                        Text(
                          "No achievements available.",
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                          ),
                        ),

                      // الصفحة الرابعة
                      VideoTab(
                        videos: List<Map<String, dynamic>>.from(player['videos'] ?? []),

                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  ImageProvider _getImageProvider(String? profile) {
    if (profile != null && profile.isNotEmpty) {
      if (profile.startsWith('http')) {
        return NetworkImage(profile);
      } else {
        return AssetImage("image/avatar.png");
      }
    } else {
      return AssetImage("image/avatar.png");
    }
  }

  Widget _displayPlayerStats(Map<String, dynamic> player) {
    String position = player['position'] ?? '';

    if (position.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),
            if (position == 'Goalkeeper') ...[
              _buildLabelValue('Clean Sheets:', player['cleanSheets'].toString()),
              _buildLabelValue('Saves:', player['saves'].toString()),
              _buildLabelValue('Penalties Saved:', player['penaltiesSaved'].toString()),
              _buildLabelValue('Own Goals:', player['ownGoals'].toString()),
              _buildLabelValue('Goals Conceded:', player['goalsConceded'].toString()),
            ] else ...[
              _buildLabelValue('Goals:', player['goals'].toString()),
              _buildLabelValue('Assists:', player['assists'].toString()),
              _buildLabelValue('Shots on Target:', player['shotsOnTarget'].toString()),
              _buildLabelValue('Tackles:', player['tackles'].toString()),
              _buildLabelValue('Interceptions:', player['interceptions'].toString()),
              _buildLabelValue('Pass Accuracy:', '${player['passAccuracy'].toStringAsFixed(2)}%'),
              _buildLabelValue('Dribbles Completed:', player['dribblesCompleted'].toString()),
              _buildLabelValue('Yellow Cards:', player['yellowCards'].toString()),
              _buildLabelValue('Red Cards:', player['redCards'].toString()),
              _buildLabelValue('Foul Goals:', player['foulGoals'].toString()),
              _buildLabelValue('Penalty Goals:', player['penaltyGoals'].toString()),
            ],
            SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                Future.delayed(Duration(milliseconds: 100), () {
                  Get.to(
                        () => ChartPlayersScreen(playerId: playerId, position: position),
                    transition: Transition.zoom,
                    duration: const Duration(milliseconds: 660),
                  );
                });
              },
              child: Text("view graph"),
            ),
          ],
        ),
      );
    } else {
      return Text('Position not available.');
    }
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(width: 18),
            Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoTab extends StatefulWidget {
  final List<Map<String, dynamic>> videos;

  VideoTab({required this.videos});

  @override
  _VideoTabState createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> with AutomaticKeepAliveClientMixin {
  late List<VideoPlayerController> _videoControllers;

  @override
  void initState() {
    super.initState();
    // إنشاء قائمة بمشغلات الفيديو
    _videoControllers = widget.videos.map((video) {
      return VideoPlayerController.network(video['videoUrl']!)
        ..initialize().then((_) {
          setState(() {}); // تحديث الحالة لعرض الفيديو عند التهيئة
        });
    }).toList();
  }

  @override
  void dispose() {
    // تنظيف الموارد عند الخروج
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // تحقق من أن الفيديوهات غير فارغة
    if (widget.videos.isEmpty) {
      return Center(
        child: Text(
          "No videos available.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        final controller = _videoControllers[index];

        return Card(
          color: Colors.grey[900],
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(video['title'], style: TextStyle(color: Colors.white)),
                subtitle: Text(video['description'], style: TextStyle(color: Colors.grey)),
              ),
              if (controller.value.isInitialized)
              // تقييد الفيديو داخل حدود مع الحفاظ على أبعاده الأصلية
                Container(
                  width: MediaQuery.of(context).size.width * 0.8, // تقليل العرض
                  height: MediaQuery.of(context).size.width * 0.8 / controller.value.aspectRatio, // الحفاظ على نسبة العرض إلى الارتفاع
                  child: VideoPlayer(controller),
                )
              else
                Container(
                  height: 200,
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator()),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },
                    icon: Icon(
                      controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}



