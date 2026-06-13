import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/controller_scout/home_page_controller/player_two_goals_controller.dart';
import '../../../../core/loading.dart';
import '../../details_screen/details_player.dart';

class PlayerTwoGoalsWidget extends StatelessWidget {
  final List<String> ids;
  final PlayerTwoGoalsController playerTwoGoalsController = Get.put(PlayerTwoGoalsController());

  PlayerTwoGoalsWidget({super.key, required this.ids});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: playerTwoGoalsController.fetchPlayerData(ids), // استدعاء الدالة من الكونترولر
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox.shrink();
        }

        List<Map<String, dynamic>> playersData = snapshot.data!;

        // عرض جميع اللاعبين دون تصنيف بناءً على الـ route
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: playersData.length,
          itemBuilder: (context, index) {
            var player = playersData[index];
            return FutureBuilder<String>(
              future: playerTwoGoalsController.fetchTeamData(player['teamId']), // استدعاء الدالة من الكونترولر
              builder: (context, teamSnapshot) {
                if (teamSnapshot.connectionState == ConnectionState.waiting) {
                  return Loading();
                }

                String teamImage = teamSnapshot.data ?? '';

                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 470),
                  builder: (context, double opacity, child) {
                    return AnimatedOpacity(
                      opacity: opacity,
                      duration: Duration(milliseconds: 400),
                      child: child,
                    );
                  },
                  child: InkWell(
                    onTap: (){
                      Future.delayed(Duration(milliseconds: 100), () {
                        Get.to(
                              () => PlayerDetailScreen(),
                          arguments: {
                            'playerId' : player['playerId'],
                          },
                          transition: Transition.zoom,
                          duration: const Duration(milliseconds: 660),
                        );
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 65,
                                height: 75,
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: _getImageProvider(player['image'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${player['firstName']}",
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  SizedBox(height: 10),
                                  CircleAvatar(
                                    backgroundImage: _getImageProvider(teamImage),
                                    radius: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 9),
                          Row(
                            children: [
                              Text(
                                "${player['goals']} Goals",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  ImageProvider _getImageProvider(String? profile) {
    return profile != null && profile.isNotEmpty
        ? NetworkImage(profile)
        : AssetImage("image/icon.png") as ImageProvider;
  }
}
