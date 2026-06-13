import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/player_controller/update_player_controller.dart';

import '../../../../core/color.dart';
import '../../widget/text_title_add_player.dart';

class UpdateAchievementsScreen extends StatefulWidget {
  const UpdateAchievementsScreen({super.key});

  @override
  State<UpdateAchievementsScreen> createState() => _EditAchievementsScreenState();
}

class _EditAchievementsScreenState extends State<UpdateAchievementsScreen> {
  final UpdatePlayerController updatePlayerController = Get.put(UpdatePlayerController());

  // هذه الدالة ستقوم بإظهار تاريخ الإنجاز
  Future<void> _pickDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        updatePlayerController.achievements[index]['date'] = picked;
      });
    }
  }

  // هذه دالة لحذف الإنجاز
  void _removeAchievement(int index) {
    setState(() {
      updatePlayerController.removeAchievement(index);
    });
  }

  // هذه دالة لتحديث بيانات الإنجاز
  void _updateAchievement(int index) {
    final achievement = updatePlayerController.achievements[index];
    if (achievement['title'].isNotEmpty && achievement['type'] != null && achievement['date'] != null) {
      // يمكنك هنا تنفيذ المنطق لتحديث الإنجاز في قاعدة البيانات.
      // في هذا المثال، نستخدم فقط إضافة الإنجاز مرة أخرى.
      updatePlayerController.addAchievement(
          achievement['title'],
          achievement['type'],
          achievement['date']
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title:const TextTitleAddPlayer(text: 'Edit Achievements'),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: updatePlayerController.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = updatePlayerController.achievements[index];

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
                    child: Card(
                      color: Colors.white12,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: TextEditingController(text: achievement['title']),
                              decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: TextStyle(color: Colors.white54),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),

                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              onChanged: (value) {
                                achievement['title'] = value;
                              },
                            ),
                            SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(context, index),
                                  child: AbsorbPointer(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        labelStyle: TextStyle(color: Colors.white54),
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today, color: Colors.green),
                                      ),
                                        style: TextStyle(color: Colors.white),
                                      controller: TextEditingController(
                                        text:  getFormattedDate(achievement['date']),  // تحويل التاريخ إذا كان String

                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  borderRadius: BorderRadius.circular(22),
                                  value: achievement['type'] != '' ? achievement['type'] : null,

                                  items: [
                                    DropdownMenuItem(value: 'championship', child: Text('Championship')),
                                    DropdownMenuItem(value: 'awards', child: Text('Awards')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      achievement['type'] = value ?? '';
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Type',
                                    labelStyle: TextStyle(color: Colors.white54),
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  icon: Icon(Icons.arrow_drop_down, color: ColorApp.oasisGreen),
                                  dropdownColor: ColorApp.oasisGreen,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                            SizedBox(height: 9),
                            // Divider(color: Colors.grey, thickness: 1.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      updatePlayerController.addAchievement('', '', null);
                    });
                  },
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text("Add Achievement", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // تحديث اللاعب بما في ذلك الإنجازات المعدلة
                    updatePlayerController.updatePlayerProfile();

                  },
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text("Save Changes", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  String getFormattedDate(dynamic date) {
    // إذا كانت القيمة null، نعيد سلسلة فارغة
    if (date == null) {
      return '';
    }

    if (date is String) {
      // إذا كانت القيمة من النوع String، نحاول تحويلها إلى DateTime.
      DateTime? parsedDate = DateTime.tryParse(date);
      if (parsedDate != null) {
        date = parsedDate;
      } else {
        return '';  // إذا لم نتمكن من تحويل التاريخ إلى DateTime، نعيد قيمة فارغة.
      }
    }

    // إذا كانت القيمة فعلاً DateTime، نعود بالتاريخ بشكل منسق.
    if (date is DateTime) {
      return '${date.day}-${date.month}-${date.year}';
    } else {
      return ''; // إعادة قيمة فارغة إذا لم يكن التاريخ صالحاً.
    }
  }


}
