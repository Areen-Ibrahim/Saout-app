import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../../controllers/controller_coach/match_controller/add_match_controller.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../widget/formations/list_player.dart';

class FourThreeThree extends StatelessWidget {
  final PlayerController playerController = Get.put(PlayerController());
  final AddMatchController addMatchController = Get.put(AddMatchController());

  // قائمة لتخزين صور اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerImages;

  // قائمة لتخزين أسماء اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerNames;

  // قائمة لتخزين أرقام اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerNumbers;

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

  FourThreeThree({super.key})
      : selectedPlayerImages = List.generate(11, (index) => ''.obs),
        selectedPlayerNames = List.generate(11, (index) => ''.obs),
        selectedPlayerNumbers = List.generate(11, (index) => ''.obs);

  // دالة تعرض قائمة اللاعبين
  void _showPlayerList(BuildContext context, int position) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: 600,
            color: Colors.black87,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                  ),
                  child: Text(
                    "Add Player",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "My Players",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 300,
                    child: ListView.builder(
                      itemCount: playerController.playersList.length,
                      itemBuilder: (context, index) {
                        var player = playerController.playersList[index];
                        return ListPlayer(
                          playerName: "${player['firstName'] ?? ""} ${player['lastName'] ?? ""}",
                          imagePlayer: player['image'] ?? '',
                          formation: player['position'],
                          onTap: () {
                            // التحقق من أن الموضع هو حارس مرمى (position == 0) وأن اللاعب هو حارس مرمى
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
                                selectedPlayerNumbers[position].value = player['playerNumber'].toString() ?? '';
                              }
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
                )
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
        padding: EdgeInsets.only(top: 20, bottom: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("image/ff.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الصف الأول (حارس مرمى)
            _buildPlayerSlot(context, 0),
            SizedBox(height: 36),

            // الصف الثاني (2 مدافعين)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPlayerSlot(context, 1),
                  _buildPlayerSlot(context, 2),
                ],
              ),
            ),
            SizedBox(height: 36),

            // الصف الثالث (2 لاعبي وسط)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerSlot(context, 3),
                _buildPlayerSlot(context, 4),
              ],
            ),
            SizedBox(height: 36),

            // الصف الرابع (مهاجم واحد)
            _buildPlayerSlot(context, 5),
            SizedBox(height: 36),

            // الصف الخامس (4 مهاجمين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerSlot(context, 6),
                _buildPlayerSlot(context, 7),
                _buildPlayerSlot(context, 8),
                _buildPlayerSlot(context, 9),
              ],
            ),
            SizedBox(height: 36),

            // الصف الأخير (مهاجم واحد)
            _buildPlayerSlot(context, 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSlot(BuildContext context, int position) {
    return Obx(() {
      return GestureDetector(
        onTap: () => _showPlayerList(context, position),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: selectedPlayerImages[position].value.isEmpty
                  ? Colors.grey[400] // لون الخلفية فضي عند عدم وجود صورة
                  : Colors.transparent, // لا توجد خلفية عندما توجد صورة
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
            SizedBox(height: 8), // مسافة بين الصورة والنص
            if (selectedPlayerNames[position].value.isNotEmpty) ...[
              Text(
                selectedPlayerNames[position].value, // عرض اسم اللاعب
                style: TextStyle(color: Colors.white),
              ),
              Text(
                selectedPlayerNumbers[position].value, // عرض رقم اللاعب
                style: TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      );
    });
  }
}
