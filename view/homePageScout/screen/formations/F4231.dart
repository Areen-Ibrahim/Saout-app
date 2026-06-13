import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/controller_coach/match_controller/add_match_controller.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../../core/color.dart';

class FourTwoThreeOneScout extends StatelessWidget {
  final PlayerController playerController = Get.put(PlayerController());
  final AddMatchController addMatchController = Get.put(AddMatchController());

  final List<String> selectedPlayerImages;
  final List<String> selectedPlayerNames;
  final List<String> selectedPlayerNumbers;
  final Map<String, List<Map<String, dynamic>>> playerGoals;
  final List<String> assistProviders;

  FourTwoThreeOneScout({
    super.key,
    required this.selectedPlayerImages,
    required this.selectedPlayerNames,
    required this.selectedPlayerNumbers,
    required this.playerGoals,
    required this.assistProviders,

  });

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
            // حارس المرمى (1 لاعب)
            _buildPlayerSlot(0),
            SizedBox(height: 36),
            // الصف الثاني (3 لاعبين - الوسط الهجومي)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => _buildPlayerSlot(index + 1)),
            ),
            SizedBox(height: 36),
            // الصف الثالث (2 لاعبين - الوسط الدفاعي)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) => _buildPlayerSlot(index + 4)),
            ),
            SizedBox(height: 36),
            // الصف الرابع (4 لاعبين - الدفاع)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildPlayerSlot(index + 6)),
            ),
            SizedBox(height: 36),
            // الصف الخامس (1 لاعب - الهجوم)
            _buildPlayerSlot(10),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSlot(int position) {
    String playerId = selectedPlayerNumbers[position];  // نأخذ معرف اللاعب من التشكيلة

    // تحقق إذا كان هناك أهداف لهذا اللاعب في playerGoals
    bool hasGoals = playerGoals.containsKey(playerId) && playerGoals[playerId]!.isNotEmpty;

    // تحقق إذا كان هناك تمريرات لهذا اللاعب في assistProviders
    bool hasAssists = assistProviders.contains(playerId);

    return Column(
      children: [
        Stack(
          children: [
            selectedPlayerImages[position].isNotEmpty
                ? CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(selectedPlayerImages[position]),
            )
                : Container(
              margin: EdgeInsets.symmetric(vertical: 9),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
            // إضافة الأيقونات إذا سجل اللاعب هدفًا أو قدم تمريرة
            if (hasGoals) ...[
              Positioned(
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_soccer, // أيقونة كرة القدم
                    color: ColorApp.background,
                    size: 18,
                  ),
                ),
              ),
            ],
            if (hasAssists) ...[
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_horiz, // أيقونة التمرير
                    color: ColorApp.background,
                    size: 18,
                  ),
                ),
              ),
            ]
          ],
        ),
        SizedBox(height: 14),
        if (selectedPlayerNames[position].isNotEmpty) ...[
          Text(
            selectedPlayerNames[position],
            style: TextStyle(color: Colors.white),
          ),
          // Text(
          //   selectedPlayerNumbers[position],
          //   style: TextStyle(color: Colors.white),
          // ),
        ],
      ],
    );
  }

}
