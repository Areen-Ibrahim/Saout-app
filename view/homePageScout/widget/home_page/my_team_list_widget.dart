import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/controller_scout/home_page_controller/my_team_list_controller.dart';
import '../../../../core/date.dart';
import '../../../../core/loading.dart';
import '../../../../core/random_color.dart';

class MyTeamListWidget extends StatelessWidget {
  final List<String> teamIds;
  final MyTeamListController controller = Get.put(MyTeamListController());

  MyTeamListWidget({super.key, required this.teamIds});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(  // جلب البيانات الأولية
      future: controller.fetchTeamsData(teamIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Text(
            "No teams available",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          );
        }

        List<Map<String, dynamic>> teamsData = snapshot.data!;

        return FutureBuilder<List<Map<String, dynamic>>>(  // جلب المباريات القادمة
          future: controller.fetchUpcomingMatches(teamsData),
          builder: (context, matchSnapshot) {
            if (matchSnapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            }

            if (!matchSnapshot.hasData || matchSnapshot.data == null) {
              return Text(
                "No upcoming matches available",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              );
            }

            List<Map<String, dynamic>> matchesData = matchSnapshot.data!;
            List<Widget> teamsWidgets = [];

            for (int i = 0; i < teamsData.length; i++) {
              Map<String, dynamic> team = teamsData[i];
              Map<String, dynamic> matchData = matchesData[i];
              String teamName = team['teamName'];
              String? teamImage = team['image'];
              String teamLocation = team['location'] ?? "Location not available";

              String matchDate = matchData.isNotEmpty
                  ? "${formatDate(matchData['matchDate'])} at ${formatTime(matchData['matchDate'])}"
                  : "No upcoming match";
              String matchLocation = matchData['matchLocation'] ?? "Location not available";

              Color backgroundColor = getRandomColor();

              teamsWidgets.add(
                Container(
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
                        backgroundImage: NetworkImage(teamImage ?? 'image/avatar.png'),
                        radius: 40,
                      ),
                      SizedBox(height: 14),
                      Text(
                        teamName,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(
                        matchDate,
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          matchLocation,
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(  // إضافة الـ RefreshIndicator هنا
              onRefresh: () async {
                // إعادة تحميل البيانات عند السحب للأسفل
                await controller.fetchTeamsData(teamIds);  // جلب بيانات الفرق من جديد
                await controller.fetchUpcomingMatches(teamsData);  // جلب المباريات القادمة من جديد
              },
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: teamsWidgets.length,
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
                    child: teamsWidgets[index],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
