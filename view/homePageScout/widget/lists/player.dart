import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_scout/welcome_controller/all_players_controller.dart';
import '../../../../controllers/controller_scout/controller_scout_auth/user_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/loading.dart';
import '../../details_screen/details_player.dart';
import '../play_list.dart';

class PlayerWidgetList extends StatefulWidget {
  const PlayerWidgetList({super.key});

  @override
  State<PlayerWidgetList> createState() => _PlayerState();
}

class _PlayerState extends State<PlayerWidgetList> {
  final AllPlayersController allPlayersController = Get.put(
      AllPlayersController());
  final UserController userController = Get.find();

  List<Map<String, dynamic>>? filteredPlayers; // قائمة اللاعبين المصفين
  // bool isFollowing = false; // حالة المتابعة
  Map<String, RxBool> followingStatus = {}; // تتبع حالة المتابعة لكل لاعب


  @override
  void initState() {
    super.initState();
    // userController.loadCurrentUserUid();
    userController.fetchFollowList();
  }

  Future<void> _refreshPlayers() async {
    setState(() {
      filteredPlayers = null; // إعادة تعيين القائمة
    });
    await allPlayersController.getAllPlayers();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (userController) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: allPlayersController.getAllPlayers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching players.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No players found.'));
            }

            List<Map<String, dynamic>> players = snapshot.data!;
            List<Map<String, dynamic>> displayedPlayers = filteredPlayers ??
                players;


            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.filter_list, color: ColorApp
                            .oasisGreen),
                        onPressed: () =>
                            showAgeFilterDialog(
                                players),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: ColorApp.oasisGreen),
                        // زر لإعادة التعيين
                        onPressed: () {
                          setState(() {
                            filteredPlayers = null;
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshPlayers,
                      child: ListView.builder(
                        itemCount: displayedPlayers.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> player = displayedPlayers[index];
                          String playerId = player['playerId'];
                          return Obx(() {
                            bool isFollowing = userController.followList
                                .contains(
                                player['playerId']);
                            bool isLoading = userController.loadingPlayerId
                                .value == playerId;

                            return AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              opacity: 1.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: PlayListInfo(
                                  name: '${player['firstName']} ${player['lastName']}',
                                  age: player['age'].toString(),
                                  position: player['position'],
                                  profile: player['image'] ?? '',
                                  onTap: () {
                                    Future.delayed(
                                        Duration(milliseconds: 100), () {
                                      Get.to(() => PlayerDetailScreen(),
                                        arguments: {
                                          'playerId': player['playerId'],
                                        },
                                        transition: Transition.rightToLeft,
                                        duration: const Duration(
                                            milliseconds: 660),
                                      )?.then((_) {
                                        userController.update();
                                      });
                                    });
                                  },
                                  icon: isFollowing ? Icons.check_circle : Icons
                                      .add_circle_outline_rounded,
                                  color: isFollowing ? Colors.green : Colors
                                      .white,
                                  onFollow: () async {
                                    await userController.toggleFollowPlayer(
                                        userController.currentUserUid.value,
                                        playerId);
                                  },
                                  teamName: player['teamName'],
                                  isLoading: isLoading,
                                ).animate().fadeIn().slide(
                                    duration: 500.ms, curve: Curves.easeInOut),
                              ).animate().shimmer(
                                  delay: 100.ms, duration: 300.ms),
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showAgeFilterDialog(List<Map<String, dynamic>> players) {
    final TextEditingController ageController = TextEditingController();
    bool isSortedByGoals = false;
    List<String> selectedPositions = [];

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorApp.blue,
        title: Text('Filter Players', style: TextStyle(color: Colors.purple)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Enter Age (6-18)',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort by Goals', style: TextStyle(color: Colors.white)),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Switch(
                        value: isSortedByGoals,
                        onChanged: (value) {
                          setState(() {
                            isSortedByGoals = value;
                          });
                        },
                        activeColor: Colors.purple,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Select Positions:', style: TextStyle(color: Colors.white)),
              ...['Goalkeeper', 'Defender', 'Midfielder', 'Forward'].map((
                  position) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: Text(position,
                          style: TextStyle(color: Colors.white)),
                      value: selectedPositions.contains(position),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            if (value) {
                              selectedPositions.add(position);
                            } else {
                              selectedPositions.remove(position);
                            }
                          });
                        }
                      },
                      activeColor: Colors.purple,
                      checkColor: Colors.white,
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              int? age = ageController.text.isEmpty ? null : int.tryParse(
                  ageController.text);
              List<Map<String, dynamic>> filtered = players;

              // إذا تم إدخال العمر، تأكد من أنه بين 6 و 18
              if (age != null && (age < 6 || age > 18)) {
                Get.snackbar(
                  'Invalid Age',
                  'Please enter a valid age between 6 and 18.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return; // إيقاف تنفيذ الدالة إذا كان العمر غير صحيح
              }

              // تصفية اللاعبين بناءً على العمر
              if (age != null) {
                filtered =
                    allPlayersController.filterPlayersByAge(filtered, age);
              }

              if (isSortedByGoals) {
                filtered.sort((a, b) => b['goals'].compareTo(a['goals']));
              }

              if (selectedPositions.isNotEmpty) {
                filtered = filtered.where((player) =>
                    selectedPositions.contains(player['position'])).toList();
              }

              setState(() {
                filteredPlayers = filtered; // تحديث قائمة اللاعبين المصفين
              });

              Get.back(); // إغلاق النافذة
            },
            style: TextButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Filter', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}