import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/add_player_controller.dart';
import 'package:saoutapp/view/homePage/screen/home_page_coach/home_page_coach.dart';
import '../../../../controllers/controller_coach/player_controller/notify_player.dart';
import '../../../../core/color.dart';
import '../../widget/text_title_add_player.dart';

class AchievementsPlayerScreen extends StatefulWidget {
  const AchievementsPlayerScreen({super.key});

  @override
  State<AchievementsPlayerScreen> createState() => _AchievementsPlayerScreenState();
}

class Achievement {
  final TextEditingController titleController;
  String? selectedOption;
  DateTime? selectedDate;

  Achievement({
    required this.titleController,
    this.selectedOption,
    this.selectedDate,
  });
}

class _AchievementsPlayerScreenState extends State<AchievementsPlayerScreen> {
  List<Achievement> _achievements = [
    Achievement(titleController: TextEditingController())
  ];

  final PlayerController playerController = Get.put(PlayerController());
  final NotifyPlayerController notifyPlayerController = Get.put(NotifyPlayerController());

  void _saveAchievements() {
    for (var achievement in _achievements) {
      if (achievement.titleController.text.isNotEmpty &&
          achievement.selectedOption != null &&
          achievement.selectedDate != null) {
        playerController.addAchievement(
          achievement.titleController.text,
          achievement.selectedOption!,
          achievement.selectedDate!,
        );
      }
    }
  }

  Future<void> _pickDate(BuildContext context, Achievement achievement) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        achievement.selectedDate = picked;
      });
    }
  }

  void _addAchievement() {
    setState(() {
      _achievements.add(Achievement(titleController: TextEditingController()));
    });
  }

  void _removeAchievement(int index) {
    setState(() {
      _achievements.removeAt(index);
    });
  }

  void _showLoadingDialog() {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _addPlayerWithLoading() async {
    _showLoadingDialog(); // إظهار مؤشر التحميل

    _saveAchievements();

    // قم بحفظ اللاعب في الخلفية
    await playerController.addPlayer(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
        title: TextTitleAddPlayer(text: 'Achievements'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  final achievement = _achievements[index];

                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeAchievement(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Achievement deleted')),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: achievement.titleController,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorApp.oasisGreen),
                                  ),
                                  labelStyle: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () => _pickDate(context, achievement),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: ColorApp.oasisGreen),
                                      ),
                                      suffixIcon: Icon(Icons.calendar_today, color: ColorApp.oasisGreen),
                                      labelStyle: TextStyle(color: Colors.white54),
                                    ),
                                    controller: TextEditingController(
                                      text: achievement.selectedDate == null
                                          ? ''
                                          : '${achievement.selectedDate!.day}-${achievement.selectedDate!.month}-${achievement.selectedDate!.year}',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                value: achievement.selectedOption,
                                items: [
                                  DropdownMenuItem(value: 'championship', child: Text('Championship')),
                                  DropdownMenuItem(value: 'awards', child: Text('Awards')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    achievement.selectedOption = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: ColorApp.oasisGreen),
                                  ),
                                  labelStyle: TextStyle(color: Colors.white54),
                                ),
                                icon: Icon(Icons.arrow_drop_down, color: ColorApp.oasisGreen),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 9),
                        Divider(color: Colors.grey, thickness: 1.0),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addAchievement,
                  icon: Icon(Icons.add, color: Colors.white,),
                  label: Text("Add Achievement", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.oasisGreen
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addPlayerWithLoading,
                  icon: Icon(Icons.add, color: Colors.white,),
                  label: Text("Add Player", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.oasisGreen
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
