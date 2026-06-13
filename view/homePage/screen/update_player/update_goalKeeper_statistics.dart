
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_achievements_player.dart';

import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../controllers/controller_coach/player_controller/update_player_controller.dart';
import '../../../../core/color.dart';
import '../../widget/player_statistics_widget.dart';
import '../../widget/text_title_add_player.dart';

class UpdateGoalkeeperStatistics extends StatefulWidget {
  const UpdateGoalkeeperStatistics({super.key});

  @override
  State<UpdateGoalkeeperStatistics> createState() => _UpdateGoalkeeperStatisticsState();
}

class _UpdateGoalkeeperStatisticsState extends State<UpdateGoalkeeperStatistics> {
  final UpdatePlayerController playerController = Get.find();
  bool isLoading = false;

  // // نصوص تحكم البيانات
  // final TextEditingController cleanSheetsController = TextEditingController();
  // final TextEditingController savesController = TextEditingController();
  // final TextEditingController penaltiesSavedController = TextEditingController();
  // final TextEditingController ownGoalsController = TextEditingController();
  // final TextEditingController goalsConcededController = TextEditingController();
  final UpdatePlayerController _updatePlayerController = Get.find();
  final PlayerController _playerControllerrr = Get.find();


  @override
  void initState() {
    super.initState();

    String? playerId = Get.arguments['playerId'];
    String? passedCoachId = Get.arguments['coachId'];
    String? passedTeamId = Get.arguments['teamId'];

    if (passedTeamId != null) {
      _playerControllerrr.coachId.value = passedCoachId;
      _playerControllerrr.teamId.value = passedTeamId;
    }

    _playerControllerrr.playerId.value = playerId;
    _updatePlayerController.fetchPlayerData(playerId);
    print(_updatePlayerController.fetchPlayerData(playerId));

      print('Player ID is missing==========================================================================. $playerId');
    print('Coach ID is missing==========================================================================. $passedCoachId');
    print('Team ID is missing==========================================================================. $passedTeamId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.white10,
        title: TextTitleAddPlayer(text: 'Edit Goalkeeper Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 50),
        child: Column(
          children: [
            // const Divider(),
            // const TextTitleAddPlayer(text: 'Edit Goalkeeper Stats'),
            // const Divider(),
            const SizedBox(height: 19),
            PlayerStatisticsWidget(
              text: 'Clean Sheets',
              value: playerController.cleanSheetsController,
              onIncrement: () => setState(() {
                playerController.cleanSheetsController++;
              }),
              onDecrement: () => setState(() {
                if (playerController.cleanSheetsController > 0) {
                  playerController.cleanSheetsController--;
                }
              }),
            ),
            PlayerStatisticsWidget(
              text: 'Saves',
              value: playerController.savesController,
              onIncrement: () => setState(() {
                playerController.savesController++;
              }),
              onDecrement: () => setState(() {
                if (playerController.savesController > 0) {
                  playerController.savesController--;
                }
              }),
            ),
            PlayerStatisticsWidget(
              text: 'Penalties Saved',
              value: playerController.penaltiesSavedController,
              onIncrement: () => setState(() {
                playerController.penaltiesSavedController++;
              }),
              onDecrement: () => setState(() {
                if (playerController.penaltiesSavedController > 0) {
                  playerController.penaltiesSavedController--;
                }
              }),
            ),

            PlayerStatisticsWidget(
              text: 'Own Goals',
              value: playerController.ownGoalsController,
              onIncrement: () => setState(() {
                playerController.ownGoalsController++;
              }),
              onDecrement: () => setState(() {
                if (playerController.ownGoalsController > 0) {
                  playerController.ownGoalsController--;
                }
              }),
            ),
            PlayerStatisticsWidget(
              text: 'Goals Conceded',
              value: playerController.goalsConcededController,
              onIncrement: () => setState(() {
                playerController.goalsConcededController++;
              }),
              onDecrement: () => setState(() {
                if (playerController.goalsConcededController > 0) {
                  playerController.goalsConcededController--;
                }
              }),
            ),


            const SizedBox(height: 50),
            // isLoading
            //     ? const CircularProgressIndicator()
            //     : GestureDetector(
            //   onTap: () async {
            //     setState(() {
            //       isLoading = true;
            //     });
            //
            //     await playerController.updatePlayerProfile();
            //
            //     setState(() {
            //       isLoading = false;
            //     });
            //   },
            //   child: Container(
            //     height: 40,
            //     width: 220,
            //     decoration: BoxDecoration(
            //         color: ColorApp.oasisGreen,
            //         borderRadius: BorderRadius.circular(8)),
            //     child: const Center(
            //       child: Text('Update GoalKeeper Statistics',
            //           style: TextStyle(color: Colors.white, fontSize: 14)),
            //     ),
            //   ),
            // ),
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
                  onPressed: () {
                    Future.delayed(Duration(milliseconds: 20), () {
                      Get.to(() => UpdateAchievementsScreen(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 770));
                    });
                  },
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text("Next", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
