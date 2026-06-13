import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_scout/get_data_controller/get_school.dart';
import '../../../../core/color.dart';
import '../../../../routes.dart';



void showAgeFilterDialogSchool() {
  final GetSchoolController getSchoolController = Get.put(GetSchoolController());
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    int? enteredAge = int.tryParse(ageController.text);

                    // إظهار إشارة تحميل
                    Get.dialog(
                      Center(child: CircularProgressIndicator()),
                    );

                    List<Map<String, dynamic>> teamsInfo = await getSchoolController.getAllTeamsInfoSchool();

                    List<Map<String, dynamic>> filteredTeams;
                    if (isWinningFilter.value) {
                      filteredTeams = teamsInfo.where((team) => team['numberOfWins'] > 0).toList();
                    } else {
                      filteredTeams = teamsInfo.where((team) => team['averageAgeOfPlayers'] == enteredAge).toList();
                    }

                    Get.back(); // إغلاق إشارة التحميل

                    if (filteredTeams.isNotEmpty) {
                      _showFilteredTeamsDialogSchool(filteredTeams);
                    } else {
                      Get.snackbar('No Teams Found', isWinningFilter.value
                          ? 'No teams with wins.'
                          : 'No teams with an average age of $enteredAge.',
                          backgroundColor: Colors.red);
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: Text(
                    'Filter',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    Get.back(); // إغلاق النافذة المنبثقة
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


// دالة لعرض الفرق المصفاة
void _showFilteredTeamsDialogSchool(List<Map<String, dynamic>> filteredTeams) {
  Get.dialog(
    AlertDialog(
      backgroundColor: ColorApp.blue,
      title: Text(
        'Filtered Teams',
        style: TextStyle(color: Colors.purple),
      ),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: filteredTeams.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> team = filteredTeams[index];
            return InkWell(
              onTap: (){
                Get.toNamed(AppRoutes.detailsTeamAc, arguments: {
                  'teamId' : team['teamId'],
                });
              },
              child: ListTile(
                title: Text(
                  team['teamName'],
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Type: ${team['teamType']} \n Average Age: ${team['averageAgeOfPlayers']} \n Wins: ${team['numberOfWins']}',
                  style: TextStyle(color: Colors.white),
                ),
                leading: CircleAvatar(
                  backgroundColor: team['image'] != null ? Colors.transparent : Colors.grey,
                  backgroundImage: team['image'] != null ? NetworkImage(team['image']) : null,
                  child: team['image'] == null
                      ? Icon(Icons.group, color: Colors.white)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // إغلاق النافذة المنبثقة
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
          child: Text(
            'Close',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

