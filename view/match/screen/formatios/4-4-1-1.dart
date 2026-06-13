import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../../controllers/controller_coach/match_controller/add_match_controller.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../core/color.dart';
import '../../widget/formations/list_player.dart';

class FourFourOneOne extends StatelessWidget {
  final PlayerController playerController = Get.put(PlayerController());
  final AddMatchController addMatchController = Get.put(AddMatchController());


  // قائمة لتخزين صور اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerImages;

  // قائمة لتخزين أسماء اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerNames;

  // قائمة لتخزين أرقام اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerNumbers;

  FourFourOneOne({super.key})
      : selectedPlayerImages = List.generate(11, (index) => ''.obs),
        selectedPlayerNames = List.generate(11, (index) => ''.obs),
        selectedPlayerNumbers = List.generate(11, (index) => ''.obs);

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
                  child: Text(
                    "Add Player",
                    style: TextStyle(
                      color: ColorApp.richLavender,
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
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللاعب في الصف الأول (حارس المرمى)
            _buildPlayerSlot(context, 0),
            SizedBox(height: 36),
            // الصف الثاني (4 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildPlayerSlot(context, index + 1)),
            ),
            SizedBox(height: 36),
            // الصف الثالث (4 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildPlayerSlot(context, index + 5)),
            ),
            SizedBox(height: 36),
            // الصف الرابع (مهاجمان)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) => _buildPlayerSlot(context, index + 9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSlot(BuildContext context, int position) {
    return Obx(() {
      return GestureDetector(
        onTap: () => _showPlayerList(context, position),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              selectedPlayerImages[position].value.isNotEmpty
                  ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(selectedPlayerImages[position].value),
              )
                  : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey, // لون الخلفية للأيقونة
                ),
                child: Center(
                  child: Icon(
                    Icons.add, // رمز الإضافة
                    size: 30,
                    color: Colors.white, // لون الرمز
                  ),
                ),
              ),
              if (selectedPlayerNames[position].value.isNotEmpty) ...[
                Text(
                  selectedPlayerNames[position].value,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  selectedPlayerNumbers[position].value,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
