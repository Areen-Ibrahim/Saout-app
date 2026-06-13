import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_player.dart';
import '../../../../controllers/controller_scout/home_page_controller/player_list_by_goals_controller.dart';
import '../../../../core/color.dart';
import '../../../../core/loading.dart';
import '../../widget/home_page/player_list_by_goals.dart';

class PlayerByGoals extends StatefulWidget {
  const PlayerByGoals({super.key});

  @override
  State<PlayerByGoals> createState() => _PlayerByGoalsState();
}

class _PlayerByGoalsState extends State<PlayerByGoals> {
  final PlayerListByGoalsController playerListByGoalsController = Get.put(PlayerListByGoalsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Players By Goals", style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: playerListByGoalsController.getPlayersSortedByGoals(), // استخدام الكونترولر لجلب اللاعبين
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading(); // عرض مؤشر التحميل أثناء الانتظار
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching players.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No players found.'));
          }

          List<Map<String, dynamic>> players = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> player = players[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlayListInfoByGoals(
                    name: '${player['firstName']} ${player['lastName']}',
                    age: "Age ${player['age'].toString()}",
                    position: "Goals ${player['goals']}",
                    profile: player['image'] ?? '',
                    onTap: () {
                      Future.delayed(Duration(milliseconds: 100), () {
                        Get.to(
                              () => PlayerDetailScreen(),
                          arguments: {
                            'playerId': player['playerId'],
                          },
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 660),
                        );
                      });
                    },
                  ).animate().fadeIn().slide(duration: 500.ms, curve: Curves.easeInOut),
                ).animate().shimmer(delay: 100.ms, duration: 300.ms);
              },
            ),
          );
        },
      ),
    );
  }
}
