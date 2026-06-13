import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saoutapp/controllers/controller_coach/match_controller/update_match.dart';
import 'package:saoutapp/core/color.dart';
import '../../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../widget/formations/list_player.dart';

class FourThreeThreeUpdate extends StatefulWidget {
  final PlayerController playerController = Get.put(PlayerController());
  final String matchId; // إضافة المعرف هنا

  final List<String> selectedPlayerImages;
  final List<String> selectedPlayerNames;
  final List<String> selectedPlayerNumbers;

  FourThreeThreeUpdate({
    super.key,
    required this.selectedPlayerImages,
    required this.selectedPlayerNames,
    required this.selectedPlayerNumbers,
    required this.matchId,
  });

  @override
  _FourThreeThreeUpdateState createState() => _FourThreeThreeUpdateState();
}

class _FourThreeThreeUpdateState extends State<FourThreeThreeUpdate> {
  final UpdateMatchController updateMatchController = Get.put(UpdateMatchController());

  @override
  void initState() {
    super.initState();
    // جلب بيانات المباراة عند بدء الصفحة
    updateMatchController.fetchMatchData(widget.matchId).then((data) {
      // تحديث التشكيلة بناءً على البيانات المسترجعة
      List<Map<String, dynamic>> playerDetails = data['playerDetails'];
      for (int i = 0; i < playerDetails.length; i++) {
        if (i < widget.selectedPlayerImages.length) {
          // تعيين بيانات اللاعب
          widget.selectedPlayerImages[i] = playerDetails[i]['image'] ?? '';
          widget.selectedPlayerNames[i] = "${playerDetails[i]['firstName'] ?? ''} ${playerDetails[i]['lastName'] ?? ''}";
          widget.selectedPlayerNumbers[i] = playerDetails[i]['playerNumber'].toString() ?? '';
        }
      }
      setState(() {}); // تحديث واجهة المستخدم بعد جلب البيانات
    });
  }

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
                    "Select Player",
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
                  child: Obx(() {
                    if (widget.playerController.playersList.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: widget.playerController.playersList.length,
                      itemBuilder: (context, index) {
                        var player = widget.playerController.playersList[index];
                        return ListPlayer(
                          playerName: "${player['firstName'] ?? ""} ${player['lastName'] ?? ""}",
                          imagePlayer: player['image'] ?? '',
                          formation: player['position'],
                          onTap: () {
                            String playerId = player['playerId'];
                            // إضافة اللاعب المختار إلى الفريق
                            if (!widget.selectedPlayerImages.contains(player['image'])) {
                              widget.selectedPlayerImages[position] = player['image'] ?? '';
                              widget.selectedPlayerNames[position] = "${player['firstName']} ${player['lastName']}";
                              widget.selectedPlayerNumbers[position] = player['playerNumber'].toString() ?? '';

                              // تحديث قائمة المعرفات في UpdateMatchController
                              updateMatchController.addPlayer(playerId);
                              Navigator.pop(context); // أغلق القائمة بعد الاختيار
                              setState(() {});
                            }
                          },
                        );
                      },
                    );
                  }),
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
            _buildPlayerSlot(context, 0), // حارس المرمى
            SizedBox(height: 36),
            // الصف الثاني (لاعب واحد)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlayerSlot(context, 1),
              ],
            ),
            SizedBox(height: 36),
            // الصف الثالث (3 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => _buildPlayerSlot(context, index + 2)),
            ),
            SizedBox(height: 36),
            // الصف الرابع (2 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(2, (index) => _buildPlayerSlot(context, index + 5)),
            ),
            SizedBox(height: 36),
            // الصف الخامس (4 لاعبين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildPlayerSlot(context, index + 7)),
            ),
            SizedBox(height: 36),
            // الصف السادس (لاعب واحد)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPlayerSlot(context, 11),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSlot(BuildContext context, int position) {
    return GestureDetector(
      onTap: () => _showPlayerList(context, position),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                widget.selectedPlayerImages[position].isNotEmpty
                    ? CircleAvatar(
                  radius: 23,
                  backgroundImage: NetworkImage(widget.selectedPlayerImages[position]),
                )
                    : Container(
                  width: 46,
                  height: 46,
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
              ],
            ),
            if (widget.selectedPlayerNames[position].isNotEmpty) ...[
              Text(
                widget.selectedPlayerNames[position],
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                widget.selectedPlayerNumbers[position],
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
