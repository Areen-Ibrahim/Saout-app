import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_achievements_player.dart';
import 'package:saoutapp/view/homePage/screen/update_player/update_video_screen.dart';
import 'package:saoutapp/view/homePage/widget/player_statistics_widget_update.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../controllers/controller_coach/player_controller/update_player_controller.dart';
import '../../../../core/color.dart';
import '../../widget/player_statistics_widget.dart';
import '../../widget/text_title_add_player.dart';

class UpdatePlayerStatistics extends StatefulWidget {
  const UpdatePlayerStatistics({super.key});

  @override
  State<UpdatePlayerStatistics> createState() => UpdatePlayerStatisticsState();
}

class UpdatePlayerStatisticsState extends State<UpdatePlayerStatistics> {
  final UpdatePlayerController playerController = Get.put(UpdatePlayerController());
  bool isLoading = false;
  final PlayerController _playerControllerrr = Get.find();
  late   String playerIdD  ;

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
    playerController.fetchPlayerData(playerId);

      playerIdD = playerId;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title:const TextTitleAddPlayer(text: 'Player Statistics'),
        iconTheme: IconThemeData(color: Colors.white),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PlayerStatisticsWidget(
                text: 'Goals',
                value: playerController.goalsController,
                onIncrement: () => setState(() {
                  playerController.goalsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.goalsController > 0) {
                    playerController.goalsController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Assists',
                value: playerController.assistsController,
                onIncrement: () => setState(() {
                  playerController.assistsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.assistsController > 0) {
                    playerController.assistsController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Shots On Target',
                value: playerController.shotsOnTargetController,
                onIncrement: () => setState(() {
                  playerController.shotsOnTargetController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.shotsOnTargetController > 0) {
                    playerController.shotsOnTargetController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Tackles',
                value: playerController.tacklesController,
                onIncrement: () => setState(() {
                  playerController.tacklesController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.tacklesController > 0) {
                    playerController.tacklesController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Interceptions',
                value: playerController.interceptionsController,
                onIncrement: () => setState(() {
                  playerController.interceptionsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.interceptionsController > 0) {
                    playerController.interceptionsController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Dribbles Completed',
                value: playerController.dribblesCompletedController,
                onIncrement: () => setState(() {
                  playerController.dribblesCompletedController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.dribblesCompletedController > 0) {
                    playerController.dribblesCompletedController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Yellow Cards',
                value: playerController.yellowCardsController,
                onIncrement: () => setState(() {
                  playerController.yellowCardsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.yellowCardsController > 0) {
                    playerController.yellowCardsController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Red Cards',
                value: playerController.redCardsController,
                onIncrement: () => setState(() {
                  playerController.redCardsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.redCardsController > 0) {
                    playerController.redCardsController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Foul Goals',
                value: playerController.foulGoalsController,
                onIncrement: () => setState(() {
                  playerController.foulGoalsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.foulGoalsController > 0) {
                    playerController.foulGoalsController--;
                  }
                }),
              ),
              PlayerStatisticsWidget(
                text: 'Penalty Goals',
                value: playerController.penaltyGoalsController,
                onIncrement: () => setState(() {
                  playerController.penaltyGoalsController++;
                }),
                onDecrement: () => setState(() {
                  if (playerController.penaltyGoalsController > 0) {
                    playerController.penaltyGoalsController--;
                  }
                }),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10, width: 2),
                  color: Colors.white12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pass Accuracy", style: TextStyle(color: Colors.white, fontSize: 18)),
                    Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: playerController.passAccuracyController.value,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: "${playerController.passAccuracyController.value.toStringAsFixed(0)} %",
                          activeColor: ColorApp.blue,
                          inactiveColor: Colors.grey.shade400,
                          onChanged: (value) {
                            playerController.passAccuracyController.value = value;
                          },
                        ),
                        Text(
                          "${playerController.passAccuracyController.value.toStringAsFixed(0)} %", // عرض القيمة الحالية
                          style: TextStyle(color: Colors.white, fontSize: 17), // تنسيق النص
                        ),
                      ],

                    )),

                  ],
                ),
              ),
              const SizedBox(height: 50),
              // isLoading
                  // ? const CircularProgressIndicator()
                  // :
              // GestureDetector(
              //   onTap: () async {
              //     // setState(() {
              //     //   isLoading = true;
              //     // });
              //
              //     // await playerController.updatePlayerProfile();
              //
              //     Future.delayed(Duration(milliseconds: 20), () {
              //       Get.to(() => UpdateAchievementsScreen(),
              //           transition: Transition.rightToLeft,
              //           duration: const Duration(milliseconds: 770));
              //     });
              //
              //     // setState(() {
              //     //   isLoading = false;
              //     // });
              //   },
              //   child:
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
                          Get.to(() => UpdateVideoScreen(playerId: playerIdD,),
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
      ),
    );
  }
}
