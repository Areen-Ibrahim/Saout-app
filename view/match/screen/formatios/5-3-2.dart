import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/controller_coach/match_controller/add_match_controller.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../widget/formations/list_player.dart';

class FiveThreeTwo extends StatelessWidget {
  final PlayerController playerController = Get.put(PlayerController());
  final AddMatchController addMatchController = Get.put(AddMatchController());

  // قائمة لتخزين صور اللاعبين المحددين لكل موضع
  final List<RxString> selectedPlayerImages;

  // قائمة لتخزين أسماء اللاعبين
  final List<RxString> selectedPlayerNames;

  // قائمة لتخزين أرقام اللاعبين
  final List<RxString> selectedPlayerNumbers;

  // قائمة لتخزين معرفات اللاعبين لتجنب التكرار
  final List<String> selectedPlayerIds;
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
  // عدد اللاعبين
  final int numberOfPlayers = 11;

  FiveThreeTwo({super.key})
      : selectedPlayerImages = List.generate(11, (index) => ''.obs),
        selectedPlayerNames = List.generate(11, (index) => ''.obs),
        selectedPlayerNumbers = List.generate(11, (index) => ''.obs),
        selectedPlayerIds = List.generate(11, (index) => '');

  // دالة لإظهار قائمة اللاعبين
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
            // الصف الأول (2 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(2, (index) {
                return Obx(() {
                  return GestureDetector(
                    onTap: () => _showPlayerList(context, index),
                    child: Column(
                      children: [
                        selectedPlayerImages[index].value.isNotEmpty
                            ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(selectedPlayerImages[index].value),
                        )
                            : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          selectedPlayerNames[index].value,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          selectedPlayerNumbers[index].value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                });
              }),
            ),
            SizedBox(height: 36),

            // الصف الثاني (3 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(3, (index) {
                return Obx(() {
                  return GestureDetector(
                    onTap: () => _showPlayerList(context, index + 2),
                    child: Column(
                      children: [
                        selectedPlayerImages[index + 2].value.isNotEmpty
                            ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(selectedPlayerImages[index + 2].value),
                        )
                            : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          selectedPlayerNames[index + 2].value,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          selectedPlayerNumbers[index + 2].value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                });
              }),
            ),
            SizedBox(height: 36),

            // الصف الثالث (2 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(2, (index) {
                return Obx(() {
                  return GestureDetector(
                    onTap: () => _showPlayerList(context, index + 5),
                    child: Column(
                      children: [
                        selectedPlayerImages[index + 5].value.isNotEmpty
                            ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(selectedPlayerImages[index + 5].value),
                        )
                            : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          selectedPlayerNames[index + 5].value,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          selectedPlayerNumbers[index + 5].value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                });
              }),
            ),
            SizedBox(height: 36),

            // الصف الرابع (3 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(3, (index) {
                return Obx(() {
                  return GestureDetector(
                    onTap: () => _showPlayerList(context, index + 7),
                    child: Column(
                      children: [
                        selectedPlayerImages[index + 7].value.isNotEmpty
                            ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(selectedPlayerImages[index + 7].value),
                        )
                            : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          selectedPlayerNames[index + 7].value,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          selectedPlayerNumbers[index + 7].value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                });
              }),
            ),
            SizedBox(height: 36),

            // اللاعب الأخير (1)
            Obx(() {
              return GestureDetector(
                onTap: () => _showPlayerList(context, 10),
                child: Column(
                  children: [
                    selectedPlayerImages[10].value.isNotEmpty
                        ? CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(selectedPlayerImages[10].value),
                    )
                        : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      selectedPlayerNames[10].value,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      selectedPlayerNumbers[10].value,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
