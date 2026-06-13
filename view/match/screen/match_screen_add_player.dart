import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/notifications_controller.dart';
import 'package:saoutapp/routes.dart';
import 'package:saoutapp/view/match/screen/formatios/4-2-3-1.dart';
import 'package:saoutapp/view/match/screen/formatios/4-3-3.dart';
import 'package:saoutapp/view/match/screen/formatios/4-4-2.dart';
import 'package:saoutapp/view/match/screen/formatios/5-3-2.dart';
import '../../../controllers/controller_coach/match_controller/add_match_controller.dart';
import '../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../controllers/controller_coach/team_controller.dart';
import '../../../core/color.dart';
import '../widget/back_add_widget.dart';
import 'formatios/4-4-1-1.dart';

class MatchScreenAddPlayer extends StatefulWidget {
  const MatchScreenAddPlayer({super.key});

  @override
  State<MatchScreenAddPlayer> createState() => _MatchScreenAddPlayerState();
}

class _MatchScreenAddPlayerState extends State<MatchScreenAddPlayer> {

  final PlayerController playerController = Get.find();
  final CoachController _coachController = Get.find();
  final TeamController _teamController = Get.find();
  final AddMatchController _controller = Get.put(AddMatchController());
  final NotificationsController notificationsController = Get.put(NotificationsController());

  String? selectedGoalScorerId;
  String? goalMinute;
  List<Map<String, dynamic>> goals = []; // لتخزين أهداف المباراة
  int numberOfGoals = 0; // لحفظ عدد الأهداف

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      playerController.requestStoragePermission();
      numberOfGoals = Get.arguments['goals'] ?? 0;

      // تهيئة قائمة الأهداف
      _controller.goalsList.clear();
      for (int i = 0; i < numberOfGoals; i++) {
        _controller.goalsList.add({'minute': '', 'playerId': null});
      }

      String? passedCoachId = Get.arguments['coachId'];
      String? passedTeamId = Get.arguments['teamId'];

      if (passedCoachId != null) {
        _coachController.coachId.value = passedCoachId;
        _teamController.teamId.value = passedTeamId;
        playerController.fetchPlayers(passedTeamId, passedTeamId);
        playerController.fetchPlayersMatch(passedTeamId);
      }
    });
  }

  @override
  void dispose() {
    _controller.selectedPlayerIDs.clear();
    super.dispose();
  }

  String? _selectedFormation = '4-4-1-1';

  // قائمة التشكيلات
  final List<String> formations = [
    '4-4-1-1',
    '5-3-2',
    '4-2-3-1',
    '4-3-3',
    '4-4-2',
  ];


  // دالة لتوجيه المستخدم إلى الصفحات المناسبة بناءً على اختياره
  Widget _getFormationWidget(String formation) {
    switch (formation) {
      case '4-4-1-1':
        return FourFourOneOne();
      case '5-3-2':
        return FiveThreeTwo();
      case '4-2-3-1':
        return FourTwoThreeOne();
      case '4-3-3':
        return FourThreeThree();
      case '4-4-2':
        return FourFourTwo();
      default:
        return Container();
    }
  }

  // دالة لحفظ التشكيلة إلى قاعدة البيانات
  void saveMatchFormation(String matchID, String formation) async {
    await FirebaseFirestore.instance.collection('matches').doc(matchID).update({
      'match_formation': formation,
    });
  }

  // دالة لاسترجاع التشكيلة من قاعدة البيانات
  void getMatchFormation(String matchID) async {
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection('matches').doc(matchID).get();
    setState(() {
      _selectedFormation = doc['matchFormation'] ?? '4-4-1-1'; // تعيين قيمة افتراضية
    });
  }

  @override
  Widget build(BuildContext context) {
    String opposingTeamName = Get.arguments != null ? Get.arguments['opposingTeamName'] ?? "opposingTeamName" : "No data passed";

    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: Text(
          "Matches",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "LineUp",
                  style: TextStyle(
                    color: ColorApp.oasisGreen,
                    fontFamily: 'play',
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          opposingTeamName,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: DropdownButton<String>(
                              value: _selectedFormation,
                              items: formations.map((String formation) {
                                return DropdownMenuItem<String>(
                                  value: formation,
                                  child: Text(formation),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFormation = newValue; // تحديث القيمة هنا
                                  _controller.selectedFormations.value = newValue!;
                                  _controller.selectedPlayerIDs.clear(); // تفريغ قائمة اللاعبين عند تغيير التشكيلة
                                });
                              },

                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20)),
                          child: Obx((){
                            return Text(
                              _teamController.teamName.value,
                              style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18),
                            );
                          })
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            _selectedFormation != null
                ? _getFormationWidget(_selectedFormation!)
                : Container(),
            // قائمة الأهداف
            SizedBox(height: 15),

            Obx(() {
              // تحديث قائمة اللاعبين عند تغيير التشكيلة
              var selectedPlayers = playerController.playersList.where((player) {
                return _controller.selectedPlayerIDs.contains(player['playerId']) &&
                    player['position'] != 'Goalkeeper';
              }).toList();

              // تحديث القيم في goalsList إذا لم يكن playerId موجودًا
              for (var goal in _controller.goalsList) {
                if (!selectedPlayers.any((player) => player['playerId'] == goal['playerId'])) {
                  goal['playerId'] = ""; // تعيين القيمة إلى فارغة
                }
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _controller.goalsList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      // حقل إدخال الدقيقة مع شريط تمرير
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.timer, color: Colors.blueAccent),
                              labelText: "Minute (1-90)",
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              int minute = int.tryParse(value) ?? 0;
                              String playerId = _controller.goalsList[index]['playerId'] ?? '';

                              if (minute >= 1 && minute <= 90) {
                                _controller.addGoal(index, minute, playerId);
                              } else {
                                Get.snackbar('Error', "Please enter a minute between 1 and 90.",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.greenAccent),
                              labelText: "Select Player",
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.greenAccent, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // ضبط القيمة إلى null إذا لم يكن playerId موجودًا في selectedPlayers
                            value: selectedPlayers.any((player) =>
                            player['playerId'] == _controller.goalsList[index]['playerId'])
                                ? _controller.goalsList[index]['playerId']
                                : null,
                            items: [
                              DropdownMenuItem<String>(
                                value: null, // عنصر افتراضي للقائمة
                                child: Text("Select player", style: TextStyle(color: Colors.black54)),
                              ),
                              ...selectedPlayers.map((player) {
                                return DropdownMenuItem<String>(
                                  value: player['playerId'],
                                  child: Row(
                                    children: [
                                      Icon(Icons.sports_soccer, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(player['firstName'], style: TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              int minute = int.tryParse(_controller.goalsList[index]['minute']?.toString() ?? '0') ?? 0;
                              _controller.addGoal(index, minute, value ?? '');
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Obx((){
                var selectedPlayers = playerController.playersList.where((player) {
                  return _controller.selectedPlayerIDs.contains(player['playerId']) &&
                      player['position'] != 'Goalkeeper';
                }).toList();
                return MultiSelectDialogField(
                  items: selectedPlayers.map((player) => MultiSelectItem(player['playerId'], player['firstName']))
                      .toList(),
                  title: Text("Select Assist Providers"),
                  selectedColor: Colors.green,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                  buttonIcon: Icon(
                    Icons.sports_soccer_outlined,
                    color: Colors.green,
                  ),
                  buttonText: Text(
                    "Assist Providers",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onConfirm: (results) {
                    // تخزين العناصر المحددة في قائمة المساعدين
                    _controller.selectedAssistProviders.assignAll(results.cast<String>());
                  },
                  chipDisplay: MultiSelectChipDisplay(
                    onTap: (value) {
                      // حذف العنصر عند الضغط عليه
                      _controller.selectedAssistProviders.remove(value);
                    },
                  ),
                );
              })
            ),




            SizedBox(height: 15),

            Obx((){
              return
              BackAddWidget(addMatch: () async {
                _controller.addMatch(context);
                await notificationsController.sendNotificationsToFollowers(_controller.selectedPlayerIDs, context);
                Get.toNamed(AppRoutes.matchHome, arguments: {
                    'coachId' : _coachController.coachId.value,
                    'teamId'  : _teamController.teamId.value,
                });
              }, add: _controller.isLoading.value
                  ? CircularProgressIndicator(color: Colors.white) // عرض مؤشر التحميل
                  : Text('Add Match',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600
                  ),
              )
                );
            }),


          ],
        ),
      ),
    );
  }

}
