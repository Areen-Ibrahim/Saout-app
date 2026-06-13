import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/notify_player.dart';
import 'package:saoutapp/routes.dart';
import 'package:saoutapp/view/homePage/screen/add_player/vedios_screen.dart';

import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../core/color.dart';
import '../../widget/player_statistics_widget.dart';
import '../../widget/text_title_add_player.dart';
import 'achievements_player_screen.dart';

class GoalkeeperStatistics extends StatefulWidget {
  const GoalkeeperStatistics({super.key});

  @override
  State<GoalkeeperStatistics> createState() => _GoalkeeperStatisticsState();
}

class _GoalkeeperStatisticsState extends State<GoalkeeperStatistics> {
  final PlayerController playerController = Get.put(PlayerController());
  // final NotifyPlayerController notifyPlayerController = Get.put(NotifyPlayerController());

  // final TextEditingController goalsController = TextEditingController();
  // final TextEditingController assistsController = TextEditingController();
  bool isLoading = false; // متغير لحالة التحميل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorApp.blue,
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 19, vertical: 90),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Divider(),
                  TextTitleAddPlayer(text: 'GoalKeeper Statistics'),
                  Divider(),
                  // SizedBox(height: 19),
                  PlayerStatisticsWidget(
                    text: 'Clean Sheets',
                    value: playerController.cleanSheets,
                    onIncrement: () => playerController.cleanSheets.value++, // زيادة القيمة
                    onDecrement: () => playerController.cleanSheets.value > 0 ? playerController.cleanSheets.value-- : null, // نقصان القيمة مع التحقق
                  ),
                  PlayerStatisticsWidget(
                    text: 'Penalties Saved',
                    value: playerController.penaltiesSaved,
                    onIncrement: () => playerController.penaltiesSaved.value++,
                    onDecrement: () => playerController.penaltiesSaved.value > 0 ? playerController.penaltiesSaved.value-- : null,
                  ),
                  PlayerStatisticsWidget(
                    text: 'Saves',
                    value: playerController.saves,
                    onIncrement: () => playerController.saves.value++,
                    onDecrement: () => playerController.saves.value > 0 ? playerController.saves.value-- : null,
                  ),
                  PlayerStatisticsWidget(
                    text: 'Goals Conceded',
                    value: playerController.goalsConceded,
                    onIncrement: () => playerController.goalsConceded.value++,
                    onDecrement: () => playerController.goalsConceded.value > 0 ? playerController.goalsConceded.value-- : null,
                  ),
                  PlayerStatisticsWidget(
                    text: 'Own Goals',
                    value: playerController.ownGoals,
                    onIncrement: () => playerController.ownGoals.value++,
                    onDecrement: () => playerController.ownGoals.value > 0 ? playerController.ownGoals.value-- : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // MaterialButton(
                      //   color: ColorApp.oasisGreen,
                      //   onPressed: () {
                      //     Get.back();
                      //   },
                      //   child: Text(
                      //     "Back",
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),
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
                      // isLoading // إذا كانت عملية الإضافة جارية
                      //     ? CircularProgressIndicator() // عرض إشارة الانتظار
                      //     :
                      ElevatedButton.icon(
                        iconAlignment: IconAlignment.end,
                        onPressed: ()  {
                          Future.delayed(Duration(milliseconds: 20), () {
                            Get.to(() => VideoUploadPage(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 770));
                          });
                          // await notifyPlayerController.notifyFollowersOnPlayerAdded(
                          //     playerController.teamId.value,
                          //     playerController.playerId.value,
                          //     context
                          // );
                        },
                        icon: Icon(Icons.arrow_forward, color: Colors.white),
                        label: Text("Next", style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      // ElevatedButton(
                      //
                      //   onPressed: () async {
                      //     // setState(() {
                      //     //   isLoading = true; // بدء التحميل
                      //     // });
                      //
                      //     // محاولة إضافة اللاعب
                      //     // await playerController.addPlayer();
                      //     // Future.delayed(Duration(milliseconds: 20), () {
                      //     //   Get.to(() => AchievementsPlayerScreen(),
                      //     //       transition: Transition.rightToLeft,
                      //     //       duration: const Duration(milliseconds: 770));
                      //     // });
                      //     // await notifyPlayerController.notifyFollowersOnPlayerAdded(
                      //     //     playerController.teamId.value,
                      //     //     playerController.playerId.value,
                      //     //     context
                      //     // );
                      //     // // بعد الانتهاء من الإضافة، قم بتغيير حالة التحميل
                      //     // setState(() {
                      //     //   isLoading = false; // انتهاء التحميل
                      //     // });
                      //
                      //   },
                      //   child: Text('Next'),
                      // ),
                    ],
                  ),



                ]
            )
        )
    );
  }
}
