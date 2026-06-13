import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/controller_scout/home_page_controller/upcoming_match_controller.dart';
import '../../../../core/loading.dart';
import '../../details_screen/details_match.dart';

class UpcomingMatchesWidget extends StatelessWidget {
  final List<String> ids;
  final GetUpcomingMatchesController controller = Get.put(GetUpcomingMatchesController());

  UpcomingMatchesWidget({required this.ids});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: controller.getUpcomingMatches(ids),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading(); // عرض مؤشر تحميل أثناء انتظار البيانات
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Text("No upcoming matches available", style: TextStyle(color: Colors.white54, fontSize: 12));
        }

        List<List<Map<String, dynamic>>> allUpcomingMatches = snapshot.data!;

        List<Widget> matchesWidgets = [];
        for (int i = 0; i < allUpcomingMatches.length; i++) {
          List<Map<String, dynamic>> upcomingMatches = allUpcomingMatches[i];

          // تكرار المباريات القادمة لهذا الفريق
          for (var match in upcomingMatches) {
            String teamName = match['teamName'] ?? '';
            String? teamImage = match['teamImage'] ?? '';
            String opponentName = match['opponentTeamName'] ?? '';
            String teamScore = match['myResult']?.toString() ?? "N/A";
            String opponentScore = match['opponentResult']?.toString() ?? "N/A";
            String matchID = match['matchID'];


            // استخراج الوقت والتاريخ بصيغة يوم ووقت فقط
            DateTime matchDate = (match['matchDate'] as Timestamp).toDate();
            String formattedDate = "${matchDate.day}/${matchDate.month}/${matchDate.year}";
            String matchTime = "${matchDate.hour}:${matchDate.minute.toString().padLeft(2, '0')}";

            // إضافة المباراة إلى الواجهة
            matchesWidgets.add(
              InkWell(
                onTap: (){
                  Future.delayed(Duration(milliseconds: 100), () {
                    Get.to(
                          () => DetailsMatchScreen(),
                      arguments: {
                        'matchID' : matchID,
                      },
                      transition: Transition.zoom,
                      duration: const Duration(milliseconds: 660),
                    );
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // صورة الفريق
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: teamImage != null
                                    ? NetworkImage(teamImage)
                                    : AssetImage('assets/default_team_image.png') as ImageProvider,
                                radius: 30,
                              ),
                              SizedBox(height: 5),
                              Text(
                                teamName,
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          // عرض النتيجة
                          Column(
                            children: [
                              Text(
                                "$teamScore - $opponentScore",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "$formattedDate\n$matchTime",
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          // صورة الفريق المنافس
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 30,
                              ),
                              SizedBox(height: 5),
                              Text(
                                opponentName,
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
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
          child: Column(
            children: matchesWidgets,
          ),
        );
      },
    );
  }
}
