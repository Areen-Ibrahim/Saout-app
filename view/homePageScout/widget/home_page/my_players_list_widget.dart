import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_player.dart';
import '../../../../controllers/controller_scout/home_page_controller/my_players_list_controller.dart';
import '../../../../core/loading.dart';
import '../../../../core/random_color.dart';

class MyPlayersListWidget extends StatelessWidget {
  final List<String> playerIds;
  final MyPlayersListController controller = Get.put(MyPlayersListController());

  MyPlayersListWidget({super.key, required this.playerIds});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.fetchPlayerData(playerIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No players available",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          );
        }

        // إنشاء قائمة بعناصر الواجهة لكل لاعب
        List<Widget> playersWidgets = snapshot.data!.map((player) {
          String firstName = player['firstName'];
          String lastName = player['lastName'];
          String playerImage = player['image'] ?? 'image/avatar.png';
          String playerCity = player['city'] ?? "City not available";
          int goals = player['goals'] ?? 0;
          String playerId = player['playerId']  ;

          Color backgroundColor = getRandomColor();

          return InkWell(
            onTap: (){
              Future.delayed(Duration(milliseconds: 100), () {
                Get.to(
                      () => PlayerDetailScreen(),
                  arguments: {
                   'playerId' : playerId,
                },
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 660),
                );
              });
            },
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(playerImage),
                    radius: 40,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "$firstName $lastName",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      _buildInfoChip("Goals: $goals"),
                      SizedBox(width: 8),
                      _buildInfoChip(playerCity),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList();

        return RefreshIndicator(  // إضافة RefreshIndicator هنا
          onRefresh: () async {
            // إعادة تحميل البيانات عند السحب للأسفل
            await controller.fetchPlayerData(playerIds);  // جلب بيانات اللاعبين من جديد
          },
          child: GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: playersWidgets.length,
            itemBuilder: (context, index) {
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
                child: playersWidgets[index],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white54, fontSize: 14),
      ),
    );
  }
}
