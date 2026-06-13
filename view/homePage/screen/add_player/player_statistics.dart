import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/view/homePage/screen/add_player/vedios_screen.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../controllers/controller_coach/player_controller/notify_player.dart';
import '../../../../core/color.dart';
import '../../widget/player_statistics_widget.dart';
import '../../widget/text_title_add_player.dart';
import 'achievements_player_screen.dart';

class PlayerStatistics extends StatefulWidget {
  const PlayerStatistics({super.key});

  @override
  State<PlayerStatistics> createState() => _PlayerStatisticsState();
}

class _PlayerStatisticsState extends State<PlayerStatistics> {
  final PlayerController playerController = Get.put(PlayerController());
  // final NotifyPlayerController notifyPlayerController = Get.put(NotifyPlayerController());

  bool isLoading = false; // متغير لحالة التحميل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title:  TextTitleAddPlayer(text: 'Player Statistics'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 19, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Divider(),
              // TextTitleAddPlayer(text: 'Player Statistics'),
              // Divider(),
              SizedBox(height: 19),
              PlayerStatisticsWidget(
                text: 'Goals',
                value: playerController.goals,
                onIncrement: () => playerController.goals.value++, // زيادة القيمة
                onDecrement: () => playerController.goals.value > 0 ? playerController.goals.value-- : null, // نقصان القيمة مع التحقق
              ),
              PlayerStatisticsWidget(
                text: 'Assists',
                value: playerController.assists,
                onIncrement: () => playerController.assists.value++,
                onDecrement: () => playerController.assists.value > 0 ? playerController.assists.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Shots On Target',
                value: playerController.shotsOnTarget,
                onIncrement: () => playerController.shotsOnTarget.value++,
                onDecrement: () => playerController.shotsOnTarget.value > 0 ? playerController.shotsOnTarget.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Tackles',
                value: playerController.tackles,
                onIncrement: () => playerController.tackles.value++,
                onDecrement: () => playerController.tackles.value > 0 ? playerController.tackles.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Interceptions',
                value: playerController.interceptions,
                onIncrement: () => playerController.interceptions.value++,
                onDecrement: () => playerController.interceptions.value > 0 ? playerController.interceptions.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Dribbles Completed',
                value: playerController.dribblesCompleted,
                onIncrement: () => playerController.dribblesCompleted.value++,
                onDecrement: () => playerController.dribblesCompleted.value > 0 ? playerController.dribblesCompleted.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Yellow Cards',
                value: playerController.yellowCards,
                onIncrement: () => playerController.yellowCards.value++,
                onDecrement: () => playerController.yellowCards.value > 0 ? playerController.yellowCards.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Red Cards',
                value: playerController.redCards,
                onIncrement: () => playerController.redCards.value++,
                onDecrement: () => playerController.redCards.value > 0 ? playerController.redCards.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Foul Goals',
                value: playerController.foulGoals,
                onIncrement: () => playerController.foulGoals.value++,
                onDecrement: () => playerController.foulGoals.value > 0 ? playerController.foulGoals.value-- : null,
              ),
              PlayerStatisticsWidget(
                text: 'Penalty Goals',
                value: playerController.penaltyGoals,
                onIncrement: () => playerController.penaltyGoals.value++,
                onDecrement: () => playerController.penaltyGoals.value > 0 ? playerController.penaltyGoals.value-- : null,
              ),
              SizedBox(height: 25),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pass Accuracy", style: TextStyle(color: Colors.white, fontSize: 18)),
                    Obx(() => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: playerController.passAccuracy.value,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: "${playerController.passAccuracy.value.toStringAsFixed(0)} %",
                          activeColor: ColorApp.blue,
                          inactiveColor: Colors.grey.shade400,
                          onChanged: (value) {
                            playerController.passAccuracy.value = value;
                          },
                        ),
                        Text(
                          "${playerController.passAccuracy.value.toStringAsFixed(0)} %", // عرض القيمة الحالية
                          style: TextStyle(color: Colors.white, fontSize: 16), // تنسيق النص
                        ),
                      ],
                    ),

                    ),

                  ],
                ),
              ),
              SizedBox(height: 25),
              // isLoading // إذا كانت عملية الإضافة جارية
                  // عرض إشارة الانتظار
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
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text("Back", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
