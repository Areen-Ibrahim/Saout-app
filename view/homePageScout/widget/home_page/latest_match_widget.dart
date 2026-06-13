import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:saoutapp/controllers/controller_scout/home_page_controller/get_team_list_with_follow_controller.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_match.dart';

import '../../../../core/loading.dart';

class FollowingTeamsListPage extends StatelessWidget {
  final List<String> ids;
  final GetTeamListWithFollowController getTeamListWithFollowController = Get.put(GetTeamListWithFollowController());


  FollowingTeamsListPage({required this.ids});

  @override
  // الويدجت الذي سيعرض قائمة المباريات القادمة
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getTeamListWithFollowController.getTeamsWithMatches(ids), // استدعاء الكونترولر
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading(); // عرض مؤشر تحميل أثناء انتظار البيانات
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text("No teams or matches available", style: TextStyle(color: Colors.white54, fontSize: 14)));
        }

        List<Map<String, dynamic>> allMatches = snapshot.data!;

        // عرض آخر مباراة فقط
        Map<String, dynamic> latestMatch = allMatches.isNotEmpty ? allMatches.first : {};

        String teamName = latestMatch['teamName'] ?? '';
        String opponentName = latestMatch['opponentName'] ?? '';
        String? teamImage = latestMatch['image'] ?? '';
        String teamScore = latestMatch['myResult'].toString();
        String opponentScore = latestMatch['opponentResult'].toString();
        String matchTime = (latestMatch['matchDate'] as Timestamp).toDate().toLocal().toString().split(' ')[1].substring(0, 5);
        String matchID = latestMatch['matchID'];
        return InkWell(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // صورة الفريق
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(teamImage ?? 'https://via.placeholder.com/150'),
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
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        "$matchTime",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // صورة الفريق المنافس
                // عرض صورة الفريق المنافس
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(latestMatch['opponentImage'] ?? 'image/icon.png'), // عرض صورة الفريق المنافس
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
          ),
        );
      },
    );
  }
}
