import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_team.dart';
import '../../../../controllers/controller_scout/get_data_controller/get_teams.dart';
import '../../../../core/color.dart';
import '../../../../core/loading.dart';
import '../../../../routes.dart';
import '../../lists/list_team.dart';

class SchoolWidgetList extends StatefulWidget {
  const SchoolWidgetList({super.key});

  @override
  State<SchoolWidgetList> createState() => _SchoolWidgetListState();
}

class _SchoolWidgetListState extends State<SchoolWidgetList> {
  // final AllPlayersController allPlayersController = Get.put(AllPlayersController());
  List<Map<String, dynamic>>? filteredTeams; // حالة لتخزين الفرق المفلترة
  final UserController userController = Get.put(UserController());
  final GetTeams getTeams = Get.put(GetTeams());

  Future<void> _refreshSchools() async {
    setState(() {
      filteredTeams = null; // إعادة تعيين القائمة
    });
    await getTeams.getSchoolTeamPlayers();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: getTeams.getSchoolTeamPlayers(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching school team.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No school team.'));
          } else {
            List<Map<String, dynamic>> team = filteredTeams ?? snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.filter_list, color: ColorApp.oasisGreen),
                        onPressed: () => _showFilterDialogSchool(snapshot.data!), // فتح حوار الفلترة
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            filteredTeams = null; // إعادة الفرق الأصلية
                          });
                        },
                        icon: Icon(Icons.refresh, color: ColorApp.oasisGreen), // زر إعادة التعيين
                      ),
                    ],
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh : _refreshSchools,
                      child: ListView.builder(
                        itemCount: team.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> teams = team[index];
                          String teamId = teams['teamId'];

                          return Obx((){
                            bool isFollowing = userController.followTeamList.contains(teams['teamId']);
                            bool isLoading = userController.loadingTeamId.value == teamId;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTeam(
                                name: '${teams['teamName']}',
                                age: teams['teamType'].toString(),
                                position: teams['location'],
                                profile: teams['image'] ?? '',
                                onTap: () {
                                 Future.delayed(Duration(milliseconds: 100), () {
                                  Get.to(() => DetailsTeam(), arguments: {
                                    'teamId': teams['teamId'],},
                                    transition: Transition.rightToLeft,
                                    duration: const Duration(milliseconds: 660),
                                  );
                                 });
                                },
                                icon: isFollowing ? Icons.check_circle : Icons.add_circle_outline_rounded,
                                color: isFollowing ? Colors.green : Colors.white,
                                iconButton: () async {
                                  await userController.toggleFollowTeams(userController.currentUserUid.value, teamId);
                                },
                                isLoading: isLoading,
                              ).animate().fadeIn().slide(duration: 500.ms, curve: Curves.easeInOut),
                            ).animate().shimmer(delay: 100.ms, duration: 300.ms);
                          }
                          );

                        },
                      ),
                    )
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // دالة عرض حوار الفلترة وتحديث القائمة
  void _showFilterDialogSchool(List<Map<String, dynamic>> allTeams) {
    final TextEditingController ageController = TextEditingController();
    final ValueNotifier<bool> isWinningFilter = ValueNotifier<bool>(false); // حالة Switch

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorApp.blue,
        title: Text(
          'Filter Teams',
          style: TextStyle(color: Colors.purple),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Enter Average Age',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Wins',
                    style: TextStyle(color: Colors.white),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isWinningFilter,
                    builder: (context, value, child) {
                      return Switch(
                        value: value,
                        onChanged: (newValue) {
                          isWinningFilter.value = newValue; // تحديث حالة الـ switch
                        },
                        activeColor: Colors.purple, // لون بنفسجي للـ switch
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              int? enteredAge = int.tryParse(ageController.text);

              List<Map<String, dynamic>> filtered = isWinningFilter.value
                  ? allTeams.where((team) => team['numberOfWins'] > 0).toList()
                  : allTeams.where((team) => team['averageAgeOfPlayers'] == enteredAge).toList();

              setState(() {
                filteredTeams = filtered.isEmpty ? null : filtered;
              });

              Get.back(); // إغلاق نافذة الفلترة
            },
            style: TextButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Filter', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق النافذة المنبثقة
            },
            style: TextButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
