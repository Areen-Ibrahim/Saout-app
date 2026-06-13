import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/controller_coach/match_controller/add_match_controller.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../widget/formations/list_player.dart';

class FourFourTwo extends StatelessWidget {
  final PlayerController playerController = Get.put(PlayerController());
  final AddMatchController addMatchController = Get.put(AddMatchController());

  // قوائم لحفظ صور، أسماء، وأرقام اللاعبين
  final List<RxString> selectedPlayerImages;
  final List<RxString> selectedPlayerNames;
  final List<RxString> selectedPlayerNumbers;

  // دالة لإفراغ القوائم عند الحاجة
  void clearSelectedPlayers() {
    for (var player in selectedPlayerImages) {
      player.value = '';
    }
    for (var player in selectedPlayerNames) {
      player.value = '';
    }
    for (var player in selectedPlayerNumbers) {
      player.value = '';
    }
  }

  // التهيئة: إنشاء قوائم لحفظ بيانات اللاعبين (11 لاعب)
  FourFourTwo({super.key})
      : selectedPlayerImages = List.generate(11, (index) => ''.obs),
        selectedPlayerNames = List.generate(11, (index) => ''.obs),
        selectedPlayerNumbers = List.generate(11, (index) => ''.obs);

  // عرض قائمة اللاعبين المتاحة للاختيار
  void _showPlayerList(BuildContext context, int position) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: 600,
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                Container(
                  padding: EdgeInsets.all(12),
                  color: Colors.yellow,
                  child: Text(
                    "Add Player",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                // قائمة اللاعبين
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "My Players",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: playerController.playersList.length,
                    itemBuilder: (context, index) {
                      var player = playerController.playersList[index];
                      return ListPlayer(
                        playerName: "${player['firstName'] ?? ""} ${player['lastName'] ?? ""}",
                        imagePlayer: player['image'] ?? '',
                        formation: player['position'],
                        onTap: () {
                          // التحقق من أن اللاعب مناسب للموقع (حارس مرمى)
                          if (position == 0 && player['position'] != 'Goalkeeper') {
                            Get.snackbar(
                              "Invalid Selection",
                              "Only a goalkeeper can be assigned to this position.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          } else {
                            bool isAdded = addMatchController.addPlayer(player['playerId']);
                            if (isAdded) {
                              selectedPlayerImages[position].value = player['image'] ?? '';
                              selectedPlayerNames[position].value = "${player['firstName']} ${player['lastName']}";
                              selectedPlayerNumbers[position].value = player['playerNumber'].toString();
                            }
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/ff.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الصف الأول (2 مدافعين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildPlayerWidget(context, 0),
                buildPlayerWidget(context, 1),
              ],
            ),
            // لاعب الوسط
            buildPlayerWidget(context, 2),
            SizedBox(height: 36),
            // الصف الثاني (2 لاعبي وسط)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPlayerWidget(context, 3),
                buildPlayerWidget(context, 4),
              ],
            ),
            SizedBox(height: 36),
            // الصف الثالث (مهاجم واحد)
            buildPlayerWidget(context, 5),
            SizedBox(height: 36),
            // الصف الرابع (4 مهاجمين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildPlayerWidget(context, 6),
                buildPlayerWidget(context, 7),
                buildPlayerWidget(context, 8),
                buildPlayerWidget(context, 9),
              ],
            ),
            SizedBox(height: 36),
            // لاعب مهاجم أخير
            buildPlayerWidget(context, 10),
          ],
        ),
      ),
    );
  }

  // مكون لبناء واجهة لاعب فردي
  Widget buildPlayerWidget(BuildContext context, int position) {
    return Obx(() {
      return GestureDetector(
        onTap: () => _showPlayerList(context, position),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: selectedPlayerImages[position].value.isEmpty
                  ? Colors.grey[400]
                  : Colors.transparent,
              backgroundImage: selectedPlayerImages[position].value.isNotEmpty
                  ? NetworkImage(selectedPlayerImages[position].value)
                  : null,
              radius: 30,
              child: selectedPlayerImages[position].value.isEmpty
                  ? Icon(
                Icons.add,
                color: Colors.white, // لون الأيقونة أبيض
              )
                  : null,
            ),
            SizedBox(height: 8),
            Text(
              selectedPlayerNames[position].value,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              selectedPlayerNumbers[position].value,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    });
  }
}
