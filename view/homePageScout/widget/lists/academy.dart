import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_scout/controller_scout_auth/user_controller.dart';
import 'package:saoutapp/view/homePageScout/details_screen/details_team_ac.dart';
import '../../../../controllers/controller_scout/get_data_controller/get_teams.dart';
import '../../../../core/color.dart';
import '../../../../core/loading.dart';
import '../../../../routes.dart';
import '../../lists/list_team.dart';

class AcademyWidgetList extends StatefulWidget {
  const AcademyWidgetList({super.key});

  @override
  State<AcademyWidgetList> createState() => _AcademyWidgetListState();
}

class _AcademyWidgetListState extends State<AcademyWidgetList> {
  // final AllPlayersController allPlayersController = Get.put(AllPlayersController());
  final UserController userController = Get.put(UserController());
  final GetTeams getTeams = Get.put(GetTeams());
  List<Map<String, dynamic>>? filteredTeams; // حالة لتخزين الفرق المفلترة
  @override
  void initState() {
    super.initState();
    userController.fetchFollowListTeam();
  }

  Future<void> _refreshAcademy() async {
    setState(() {
      filteredTeams = null; // إعادة تعيين القائمة
    });
    await getTeams.getNonSchoolTeamPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: getTeams.getNonSchoolTeamPlayers(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching teams.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No teams found.'));
          } else {
            List<Map<String, dynamic>> teams = filteredTeams ?? snapshot.data!;

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
                        onPressed: () {
                          _showFilterDialog(snapshot.data!); // تمرير جميع الفرق للحوار
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            filteredTeams = null; // إعادة جميع الفرق بلا فلترة
                          });
                        },
                        icon: Icon(Icons.refresh, color: ColorApp.oasisGreen), // زر لإعادة التعيين
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> team = teams[index];
                          String teamId = team['teamId'];

                          return Obx((){
                            bool isFollowing = userController.followTeamList.contains(team['teamId']);
                            bool isLoading = userController.loadingTeamId.value == teamId;

                            return  Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTeam(
                              name: '${team['teamName']}',
                              age: team['teamType'].toString(),
                              position: team['location'],
                              profile: team['image'] ?? '',
                              onTap: () {
                                Future.delayed(Duration(milliseconds: 100), () {
                                  Get.to(() => DetailsTeamAc(), arguments: {
                                    'teamId': team['teamId'],},
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
                        },
                      );
                    })

                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // دالة لعرض حوار الفلترة وتحديث القائمة
  void _showFilterDialog(List<Map<String, dynamic>> allTeams) {
    final TextEditingController ageController = TextEditingController();
    final ValueNotifier<bool> isWinningFilter = ValueNotifier<bool>(false);

    Get.dialog(
      AlertDialog(
        backgroundColor: ColorApp.blue,
        title: Text('Filter Teams', style: TextStyle(color: Colors.purple)),
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
                  Text('Filter by Wins', style: TextStyle(color: Colors.white)),
                  ValueListenableBuilder<bool>(
                    valueListenable: isWinningFilter,
                    builder: (context, value, child) {
                      return Switch(
                        value: value,
                        onChanged: (newValue) {
                          isWinningFilter.value = newValue;
                        },
                        activeColor: Colors.purple,
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

              // فلترة البيانات بناءً على العمر أو الانتصارات
              List<Map<String, dynamic>> filtered = isWinningFilter.value
                  ? allTeams.where((team) => team['numberOfWins'] != null && team['numberOfWins'] > 0).toList()
                  : enteredAge != null
                  ? allTeams.where((team) => team['averageAgeOfPlayers'] != null && team['averageAgeOfPlayers'] == enteredAge).toList()
                  : [];

              setState(() {
                filteredTeams = filtered.isNotEmpty ? filtered : null;
              });

              Get.back();
            },
            style: TextButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Filter', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
