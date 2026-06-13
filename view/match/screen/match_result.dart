import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/add_match_controller.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:saoutapp/controllers/controller_coach/team_controller.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/update_match.dart';
import 'package:saoutapp/view/match/screen/update_formations/F4231_update.dart';
import 'package:saoutapp/view/match/screen/update_formations/F433_update.dart';
import 'package:saoutapp/view/match/screen/update_formations/F4411_update.dart';
import 'package:saoutapp/view/match/screen/update_formations/F442_update.dart';
import 'package:saoutapp/view/match/screen/update_formations/F532_update.dart';
import '../../../controllers/controller_coach/sign_up_coach_controller.dart';
import '../../../controllers/controller_scout/welcome_controller/all_match_controller.dart';
import '../../../core/color.dart';
import '../../../routes.dart';

class MatchResultsScreen extends StatefulWidget {
  const MatchResultsScreen({super.key});

  @override
  State<MatchResultsScreen> createState() => _MatchResultsScreenState();
}

class _MatchResultsScreenState extends State<MatchResultsScreen> {
  final UpdateMatchController updateMatchController = Get.put(UpdateMatchController());
  final AddMatchController addMatchController = Get.find();
  final TeamController teamController = Get.find();
  final AllMatchesController allMatchesController = Get.put(AllMatchesController());
  final TeamController _teamController = Get.find();
  final CoachController _coachController = Get.find();

  late String matchId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // مفتاح النموذج للتحقق

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    String? id = args['matchID'];
    String? passedCoachId = args['coachId'];
    String? passedTeamId = args['teamId'];
    if (passedCoachId != null) {
      _coachController.coachId.value = passedCoachId;
      _teamController.teamId.value = passedTeamId;}

    matchId = id;
    addMatchController.matchId.value = id;
    updateMatchController.fetchMatchData(matchId);
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title: Text(
          "Update Match Results",
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white, size: 20),
        actions: [
          IconButton(
            onPressed: () async {
              bool? confirmDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Delete'),
                  content: Text('Are you sure you want to delete this match?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                await addMatchController.deleteMatch(addMatchController.matchId.value);
                Get.toNamed(AppRoutes.matchHome, arguments: {
                  'coachId': teamController.coachId.value,
                  'teamId': teamController.teamId.value,
                });
              }
            },
            icon: Icon(Icons.delete_sweep_outlined, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Row(
                 children: [

                   Expanded(
                     child: TextFormField(
                       controller: updateMatchController.opposingTeamController,
                       decoration: InputDecoration(
                         labelText: "Opponent Team Name",
                         labelStyle: TextStyle(color: ColorApp.oasisGreen),
                         filled: true,
                         fillColor: Colors.grey[800],
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8.0),
                           borderSide: BorderSide(color: ColorApp.oasisGreen),
                         ),
                       ),
                       style: TextStyle(color: Colors.white),
                       validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Please enter opponent team name.';
                         }
                         return null;
                       },
                     ),
                   ),
                   SizedBox(width: 8),
                   Obx(() {
                     return updateMatchController.opposingTeamImageUrl.value.isNotEmpty
                         ? Image.network(
                       updateMatchController.opposingTeamImageUrl.value,  // رابط الصورة المخزن
                       width: 45,  // عرض الصورة
                       height: 45, // ارتفاع الصورة
                       fit: BoxFit.cover,  // طريقة ملائمة الصورة
                     )
                         : Container(); // عرض مكون فارغ في حال عدم وجود صورة
                   }),
                 ],
               ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // حقل إدخال التاريخ
                    TextFormField(
                      controller: updateMatchController.dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Match Date",
                        filled: true,
                        fillColor: Colors.grey[800],
                        labelStyle: TextStyle(color: ColorApp.oasisGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: ColorApp.oasisGreen),

                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: updateMatchController.matchDate.value,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        updateMatchController.matchDate.value = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          updateMatchController.matchDate.value.hour,
                          updateMatchController.matchDate.value.minute,
                        );
                        updateMatchController.dateController.text =
                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                            },
                    ),
                    SizedBox(height: 20),

                    // حقل إدخال الوقت
                    TextFormField(
                      controller: updateMatchController.timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Match Time",
                        labelStyle: TextStyle(color: ColorApp.oasisGreen),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: ColorApp.oasisGreen),

                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(updateMatchController.matchDate.value),
                        );
                        if (pickedTime != null) {
                          updateMatchController.matchDate.value = DateTime(
                            updateMatchController.matchDate.value.year,
                            updateMatchController.matchDate.value.month,
                            updateMatchController.matchDate.value.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          updateMatchController.timeController.text =
                          "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

               Row(
                 children: [
                   Expanded(
                     child: TextFormField(
                       controller: updateMatchController.opponentResultController,
                       decoration: InputDecoration(
                         labelText: "Opponent Result",
                         labelStyle: TextStyle(color: ColorApp.oasisGreen),
                         filled: true,
                         fillColor: Colors.grey[800],
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8.0),
                           borderSide: BorderSide(color: ColorApp.oasisGreen),
                         ),
                       ),
                       style: TextStyle(color: Colors.white),
                       validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Please enter opponent result.';
                         }
                         return null;
                       },
                     ),
                   ),
                   SizedBox(width: 9),
                   Expanded(
                     child: TextFormField(
                       controller: updateMatchController.myResultController,
                       decoration: InputDecoration(
                         labelText: "Your Result",
                         labelStyle: TextStyle(color: ColorApp.oasisGreen),
                         filled: true,
                         fillColor: Colors.grey[800],
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(8.0),
                           borderSide: BorderSide(color: ColorApp.oasisGreen),
                         ),
                       ),
                       style: TextStyle(color: Colors.white),
                       validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Please enter your result.';
                         }
                         return null;
                       },
                     ),
                   ),
                 ],
               ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      iconAlignment: IconAlignment.start,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await updateMatchController.updateMatch(matchId)
                              .then((_) {
                            Get.toNamed(AppRoutes.matchHome, arguments: {
                              'coachId': teamController.coachId.value,
                              'teamId': teamController.teamId.value,
                            });
                          });
                        }
                      },
                      icon:  Icon(Icons.update, color: Colors.white),
                      label: Text("Update", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      iconAlignment: IconAlignment.end,
                      onPressed: () {
                        Future.delayed(Duration(milliseconds: 20), () {
                          Get.to(() => FormationsUpdateScreen(matchId: matchId), arguments: {
                            'goals': int.tryParse(updateMatchController.myResultController.text),
                          },
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 770));
                        });
                      },
                      icon:  Icon(Icons.arrow_forward, color: Colors.white),
                      label: Text("Next", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Text("LineUp",
                        style: TextStyle(
                            color: ColorApp.richLavender,
                            fontFamily: 'play',
                            fontWeight: FontWeight.w500,
                            fontSize: 15
                        ),),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("${updateMatchController.selectedFormation.value}",
                          style: TextStyle(color: ColorApp.yellow),
                        ),
                      )
                    ],
                  ),
                ),
                Obx(() {
                  String formation = updateMatchController.selectedFormation.value;
                  if (formation == "4-4-1-1") {
                    return FourFourOneOneUpdate(
                      selectedPlayerImages: List<String>.filled(11, ''),
                      selectedPlayerNames: List<String>.filled(11, ''),
                      selectedPlayerNumbers: List<String>.filled(11, ''),
                      matchId: matchId,
                    );
                  } else if (formation == "4-4-2") {
                    return FourFourTwoUpdate(
                      selectedPlayerImages: List<String>.filled(11, ''),
                      selectedPlayerNames: List<String>.filled(11, ''),
                      selectedPlayerNumbers: List<String>.filled(11, ''),
                      matchId: matchId,
                    );
                  } else if (formation == "4-3-3") {
                    return FourThreeThreeUpdate(
                      selectedPlayerImages: List<String>.filled(11, ''),
                      selectedPlayerNames: List<String>.filled(11, ''),
                      selectedPlayerNumbers: List<String>.filled(11, ''),
                      matchId: matchId,
                    );
                  } else if (formation == "4-2-3-1") {
                    return FourTwoThreeOneUpdate(
                      selectedPlayerImages: List<String>.filled(11, ''),
                      selectedPlayerNames: List<String>.filled(11, ''),
                      selectedPlayerNumbers: List<String>.filled(11, ''),
                      matchId: matchId,
                    );
                  } else if (formation == "5-3-2") {
                    return FiveThreeTwoUpdate(
                      selectedPlayerImages: List<String>.filled(11, ''),
                      selectedPlayerNames: List<String>.filled(11, ''),
                      selectedPlayerNumbers: List<String>.filled(11, ''),
                      matchId: matchId,
                    );
                  } else {
                    return Text(
                      'No formation selected',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                }),

              ],
            ),
          ))],
            ),
          ),
        ),
      ),
    );
  }
}

class FormationsUpdateScreen extends StatefulWidget {
  final String matchId;
  const FormationsUpdateScreen({super.key, required this.matchId});

  @override
  State<FormationsUpdateScreen> createState() => _FormationsUpdateScreenState();
}

class _FormationsUpdateScreenState extends State<FormationsUpdateScreen> {
  final UpdateMatchController updateMatchController = Get.put(UpdateMatchController());
  int numberOfGoals = 0;

  @override
  void initState() {
    super.initState();
    updateMatchController.fetchPlayers();

    // تأجيل إضافة الأهداف بعد عملية البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      numberOfGoals = Get.arguments['goals'] ?? 0;

      // تهيئة قائمة الأهداف بعد بناء الواجهة
      updateMatchController.goalsList.clear();
      for (int i = 0; i < numberOfGoals; i++) {
        updateMatchController.goalsList.add({'minute': '', 'playerId': null});
      }
      setState(() {});  // هنا يتم استدعاء setState بعد اكتمال البناء الأولي
    });
  }

  final TeamController teamController = Get.find();
  final CoachController coachController = Get.find();
  final PlayerController playerController = Get.put(PlayerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title: Text(
          "Update Formation",
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white, size: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                // فحص إذا كانت قائمة أصحاب الأهداف فارغة أو null
                if (updateMatchController.goalsList == null || updateMatchController.goalsList.isEmpty) {
                  return Center(
                    child: Text("No goals recorded yet.", style: TextStyle(color: Colors.red)),
                  );  // عرض رسالة في حال كانت القائمة فارغة
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: updateMatchController.goalsList.length,
                  itemBuilder: (context, index) {
                    var goal = updateMatchController.goalsList[index];
                    String selectedPlayerId = goal['playerId'] ?? '';
                    int goalMinute = int.tryParse(goal['minute'].toString()) ?? 0;

                    // جلب اسم اللاعب بناءً على playerId من playerIDs
                    String playerName = 'Unknown Player';

                    if (updateMatchController.playerIDs.contains(selectedPlayerId)) {
                      // إذا كان المعرف موجودًا في playerIDs، نعرض اسم اللاعب
                      playerName = selectedPlayerId; // استبدل هذا بتقديم اسم اللاعب من قاعدة بيانات أو من المصدر المناسب
                    }

                    return Row(
                      children: [
                        // حقل إدخال الدقيقة
                        Container(
                          width: 120,  // تحديد عرض ضيق لحقل الدقيقة
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            initialValue: goalMinute > 0 ? goalMinute.toString() : '',  // التأكد من عرض الدقيقة الصحيحة
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
                              if (minute >= 1 && minute <= 90) {
                                updateMatchController.addGoal(index, minute, selectedPlayerId);
                              } else {
                                Get.snackbar('Error', "Please enter a minute between 1 and 90.",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                              }
                            },
                          ),
                        ),

                        // قائمة اختيار اللاعبين الذين سجلوا أهدافًا
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              value: selectedPlayerId.isEmpty ? null : selectedPlayerId,
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
                              items: updateMatchController.playerIDs.map((playerId) {
                                return DropdownMenuItem<String>(
                                  value: playerId,
                                  child: Row(
                                    children: [
                                      Icon(Icons.sports_soccer, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(playerName, style: TextStyle(color: Colors.black)), // عرض المعرف أو الاسم المناسب
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                updateMatchController.addGoal(index, goalMinute, value ?? '');
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
                      return updateMatchController.playerIDs.contains(player['playerId']) &&
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
                        updateMatchController.assistProviders.assignAll(results.cast<String>());
                      },
                      chipDisplay: MultiSelectChipDisplay(
                        onTap: (value) {
                          // حذف العنصر عند الضغط عليه
                          updateMatchController.assistProviders.remove(value);
                        },
                      ),
                    );
                  })
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  iconAlignment: IconAlignment.start,
                  onPressed: () async {
                    await updateMatchController.updateMatch(widget.matchId)
                        .then((_) {
                      Get.toNamed(AppRoutes.matchHome, arguments: {
                        'coachId': teamController.coachId.value,
                        'teamId': teamController.teamId.value,
                      });
                    });
                  },
                  icon: Icon(Icons.update, color: Colors.white),
                  label: Text("Update", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
