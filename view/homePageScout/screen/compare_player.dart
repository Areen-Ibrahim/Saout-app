import 'package:flutter/material.dart';
import 'package:saoutapp/controllers/controller_scout/welcome_controller/all_players_controller.dart';
import '../../../controllers/controller_coach/player_controller/add_player_controller.dart';
import '../../../core/color.dart';
import 'package:get/get.dart';

class ComparePlayer extends StatefulWidget {
  const ComparePlayer({super.key});

  @override
  State<ComparePlayer> createState() => _ComparePlayerState();
}

class _ComparePlayerState extends State<ComparePlayer> {
  final AllPlayersController allPlayerController = Get.find(); // استخدام GetX للعثور على المتحكم
  Map<String, dynamic>? player1; // للاعب الأول
  Map<String, dynamic>? player2; // للاعب الثاني
  List<Map<String, dynamic>> players = []; // للاعبين المحملين
  List<Map<String, dynamic>> filteredPlayers = []; // للاعبين بعد التصفية
  String searchQuery = ""; // نص البحث
  late String playerId;
  late String position; // نوع اللاعب
  final PlayerController playerController = Get.find();
  final AllPlayersController allPlayersController = Get.put(AllPlayersController());

  @override
  void initState() {
    super.initState();
    String? id = Get.arguments['playerId'];
    position = Get.arguments['position']; // استرجاع نوع اللاعب
    print("position $position");
    playerId = id;
    playerController.playerId.value = id;
    print('Player ID: $playerId');
    allPlayersController.getPlayerDetails(playerId).then((playerDetails) {
      setState(() {
        player1 = playerDetails;
      });
    });
    }

  // دالة لعرض قائمة اختيار اللاعبين من أسفل الشاشة
  void _showPlayerSelectionBottomSheet(int playerNumber) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 450, // ضبط ارتفاع القائمة
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Player',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // تحديث نص البحث
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: allPlayerController.getAllPlayers(), // تحميل اللاعبين
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No players found.'));
                    }

                    players = snapshot.data!;

                    // تصفية اللاعبين بناءً على نص البحث والنوع
                    filteredPlayers = players.where((player) {
                      final playerName = "${player['firstName']} ${player['lastName']}".toLowerCase();
                      bool matchesSearch = playerName.contains(searchQuery.toLowerCase());

                      // فلترة اللاعبين بناءً على النوع الممرر
                      if (position == 'Goalkeeper') {
                        return matchesSearch && player['position'] == 'Goalkeeper';
                      } else {
                        return matchesSearch && player['position'] != 'Goalkeeper';
                      }
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredPlayers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              '${filteredPlayers[index]['firstName']} ${filteredPlayers[index]['lastName']}'),
                          subtitle: Text(
                              '${filteredPlayers[index]['teamName']}'),
                          onTap: () {
                            setState(() {
                              if (playerNumber == 1) {
                                player1 = filteredPlayers[index];
                              } else {
                                if (player1 != null &&
                                    player1!['position'] == 'Goalkeeper' &&
                                    filteredPlayers[index]['position'] != 'Goalkeeper') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Player 2 must be a goalkeeper!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  player2 = filteredPlayers[index];
                                }
                              }
                            });
                            Navigator.of(context).pop(); // إغلاق القائمة بعد اختيار اللاعب
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


@override
  Widget build(BuildContext context) {
    // حساب العمر والطول والوزن لأغراض المقارنة
    final player1Age = player1 != null ? int.tryParse(
        player1!['age'].toString()) ?? 0 : 0;
    final player2Age = player2 != null ? int.tryParse(
        player2!['age'].toString()) ?? 0 : 0;

    final player1Height = player1 != null ? double.tryParse(
        player1!['height'].toString()) ?? 0 : 0;
    final player2Height = player2 != null ? double.tryParse(
        player2!['height'].toString()) ?? 0 : 0;

    final player1Weight = player1 != null ? double.tryParse(
        player1!['weight'].toString()) ?? 0 : 0;
    final player2Weight = player2 != null ? double.tryParse(
        player2!['weight'].toString()) ?? 0 : 0;

    // إضافة متغيرات أخرى مثل الأهداف والمساعدات وما إلى ذلك
    final player1Goals = player1 != null ? int.tryParse(
        player1!['goals'].toString()) ?? 0 : 0;
    final player2Goals = player2 != null ? int.tryParse(
        player2!['goals'].toString()) ?? 0 : 0;

    final player1Assists = player1 != null ? int.tryParse(
        player1!['assists'].toString()) ?? 0 : 0;
    final player2Assists = player2 != null ? int.tryParse(
        player2!['assists'].toString()) ?? 0 : 0;

    final player1ShotsOnTarget = player1 != null ? int.tryParse(
        player1!['shotsOnTarget'].toString()) ?? 0 : 0;
    final player2ShotsOnTarget = player2 != null ? int.tryParse(
        player2!['shotsOnTarget'].toString()) ?? 0 : 0;

    final player1Tackles = player1 != null ? int.tryParse(
        player1!['tackles'].toString()) ?? 0 : 0;
    final player2Tackles = player2 != null ? int.tryParse(
        player2!['tackles'].toString()) ?? 0 : 0;

    final player1PassAccuracy = player1 != null ? double.tryParse(
        player1!['passAccuracy'].toString()) ?? 0 : 0;
    final player2PassAccuracy = player2 != null ? double.tryParse(
        player2!['passAccuracy'].toString()) ?? 0 : 0;

    final player1DribblesCompleted = player1 != null ? int.tryParse(
        player1!['dribblesCompleted'].toString()) ?? 0 : 0;
    final player2DribblesCompleted = player2 != null ? int.tryParse(
        player2!['dribblesCompleted'].toString()) ?? 0 : 0;

    final player1YellowCards = player1 != null ? int.tryParse(
        player1!['yellowCards'].toString()) ?? 0 : 0;
    final player2YellowCards = player2 != null ? int.tryParse(
        player2!['yellowCards'].toString()) ?? 0 : 0;

    final player1RedCards = player1 != null ? int.tryParse(
        player1!['redCards'].toString()) ?? 0 : 0;
    final player2RedCards = player2 != null ? int.tryParse(
        player2!['redCards'].toString()) ?? 0 : 0;

    final player1FoulGoals = player1 != null ? int.tryParse(
        player1!['FoulGoals'].toString()) ?? 0 : 0;
    final player2FoulGoals = player2 != null ? int.tryParse(
        player2!['FoulGoals'].toString()) ?? 0 : 0;

    final player1PenaltyGoals = player1 != null ? int.tryParse(
        player1!['PenaltyGoals'].toString()) ?? 0 : 0;
    final player2PenaltyGoals = player2 != null ? int.tryParse(
        player2!['PenaltyGoals'].toString()) ?? 0 : 0;

    // goalKeeper

    final player1cleanSheets = player1 != null ? int.tryParse(
        player1!['cleanSheets'].toString()) ?? 0 : 0;
    final player2cleanSheets = player2 != null ? int.tryParse(
        player2!['cleanSheets'].toString()) ?? 0 : 0;

    final player1saves = player1 != null ? int.tryParse(
        player1!['saves'].toString()) ?? 0 : 0;
    final player2saves = player2 != null ? int.tryParse(
        player2!['saves'].toString()) ?? 0 : 0;

    final player1penaltiesSaved = player1 != null ? int.tryParse(
        player1!['penaltiesSaved'].toString()) ?? 0 : 0;
    final player2penaltiesSaved = player2 != null ? int.tryParse(
        player2!['penaltiesSaved'].toString()) ?? 0 : 0;

    final player1ownGoals = player1 != null ? int.tryParse(
        player1!['ownGoals'].toString()) ?? 0 : 0;
    final player2ownGoals = player2 != null ? int.tryParse(
        player2!['ownGoals'].toString()) ?? 0 : 0;

    final player1goalsConceded = player1 != null ? int.tryParse(
        player1!['ownGoals'].toString()) ?? 0 : 0;
    final player2goalsConceded = player2 != null ? int.tryParse(
        player2!['ownGoals'].toString()) ?? 0 : 0;



    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Player VS Player",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _showPlayerSelectionBottomSheet(1),
                    // اختيار اللاعب الأول
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: player1 != null && player1!['image'] != null
                                ? NetworkImage(player1!['image'])
                                : AssetImage('image/avatar.png'),
                            radius: 40,
                          ),
                          SizedBox(height: 17),
                          Text(
                            player1 != null
                                ? "${player1!['firstName']} ${player1!['lastName']}"
                                : "Player 1",
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                          // Text(
                          //   player1 != null
                          //       ? player1!['teamName']
                          //       : "Player Team",
                          //   style: TextStyle(color: Colors.white, fontSize: 18),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPlayerSelectionBottomSheet(2),
                    // اختيار اللاعب الثاني
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: player2 != null && player2!['image'] != null
                                ? NetworkImage(player2!['image'])
                                : AssetImage('image/avatar.png'),
                            radius: 40,
                          ),
                          SizedBox(height: 17),
                          Text(
                            player2 != null
                                ? "${player2!['firstName']} ${player2!['lastName']}"
                                : "Player 2",
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                          // Text(
                          //   player2 != null
                          //       ? player2!['teamName']
                          //       : "Player Team",
                          //   style: TextStyle(color: Colors.white, fontSize: 18),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              RowComAgeHeightWeight(
                player1Age: player1Age,
                player2Age: player2Age,
                player1Height: player1Height,
                player2Height: player2Height,
                player1Weight: player1Weight,
                player2Weight: player2Weight,),

              SizedBox(height: 17),

              if (player1 != null && player1!['position'] == 'Goalkeeper')
                RowComGaolKeeper(
                  player1cleanSheets: player1cleanSheets,
                  player2cleanSheets: player2cleanSheets,
                  player1saves: player1saves,
                  player2saves: player2saves,
                  player1penaltiesSaved: player1penaltiesSaved,
                  player2penaltiesSaved: player2penaltiesSaved,
                  player1ownGoals: player1ownGoals,
                  player2ownGoals: player2ownGoals,
                  player1goalsConceded: player1goalsConceded,
                  player2goalsConceded: player2goalsConceded,
                )
              else
                RowComPlayersNoGaolKeeper(
                  player1Goals: player1Goals,
                  player2Goals: player2Goals,
                  player1Assists: player1Assists,
                  player2Assists: player2Assists,
                  player1ShotsOnTarget: player1ShotsOnTarget,
                  player2ShotsOnTarget: player2ShotsOnTarget,
                  player1Tackles: player1Tackles,
                  player2Tackles: player2Tackles,
                  player1PassAccuracy: player1PassAccuracy,
                  player2PassAccuracy: player2PassAccuracy,
                  player1DribblesCompleted: player1DribblesCompleted,
                  player2DribblesCompleted: player2DribblesCompleted,
                  player1YellowCards: player1YellowCards,
                  player2YellowCards: player2YellowCards,
                  player1RedCards: player1RedCards,
                  player2RedCards: player2RedCards,
                  player1FoulGoals: player1FoulGoals,
                  player2FoulGoals: player2FoulGoals,
                  player1PenaltyGoals: player1PenaltyGoals,
                  player2PenaltyGoals: player2PenaltyGoals,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RowComAgeHeightWeight extends StatelessWidget {
  final int player1Age;
  final int player2Age;

  final num player1Height;
  final num player2Height;

  final num player1Weight;
  final num player2Weight;

  const RowComAgeHeightWeight({super.key,
    required this.player1Age,    required this.player2Age,
    required this.player1Height, required this.player2Height,
    required this.player1Weight, required this.player2Weight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          StyleRowInt(player1: player1Age, player2: player2Age, comp: 'Age',),
          SizedBox(height: 8),
          StyleRowNum(player1: player1Height, player2: player2Height, comp: 'Height (cm)',),
          SizedBox(height: 8),
          StyleRowNum(player1: player1Weight, player2: player2Weight, comp: 'Weight (kg)',),
        ],
      ),
    );
  }
}

class RowComPlayersNoGaolKeeper extends StatelessWidget {
  final int player1Goals;
  final int player2Goals;

  final int player1Assists;
  final int player2Assists;

  final int player1ShotsOnTarget;
  final int player2ShotsOnTarget;

  final int player1Tackles;
  final int player2Tackles;

  final num player1PassAccuracy;
  final num player2PassAccuracy;

  final int player1DribblesCompleted;
  final int player2DribblesCompleted;

  final int player1YellowCards;
  final int player2YellowCards;

  final int player1RedCards;
  final int player2RedCards;

  final int player1FoulGoals;
  final int player2FoulGoals;

  final int player1PenaltyGoals;
  final int player2PenaltyGoals;

  const RowComPlayersNoGaolKeeper({super.key,
    required this.player1Goals,             required this.player2Goals,
    required this.player1Assists,           required this.player2Assists,
    required this.player1ShotsOnTarget,     required this.player2ShotsOnTarget,
    required this.player1Tackles,           required this.player2Tackles,
    required this.player1PassAccuracy,      required this.player2PassAccuracy,
    required this.player1DribblesCompleted, required this.player2DribblesCompleted,
    required this.player1YellowCards,       required this.player2YellowCards,
    required this.player1RedCards,          required this.player2RedCards,
    required this.player1FoulGoals,         required this.player2FoulGoals,
    required this.player1PenaltyGoals,      required this.player2PenaltyGoals});

  @override
  Widget build(BuildContext context) {
    return   Container(
        decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StyleRowInt(player1: player1Goals, player2: player2Goals, comp: 'Goals',),

            SizedBox(height: 10),
            StyleRowInt(player1: player1Assists, player2: player2Assists, comp: 'Assists',),

            SizedBox(height: 10),
            StyleRowInt(player1: player1ShotsOnTarget, player2: player2ShotsOnTarget, comp: 'Shots On Target',),


            SizedBox(height: 10),
            StyleRowInt(player1: player1Tackles, player2: player2Tackles, comp: 'Tackles',),


            SizedBox(height: 10),
            StyleRowNum(player1: player1PassAccuracy, player2: player2PassAccuracy, comp: 'Pass Accuracy',),


            SizedBox(height: 10),
            StyleRowInt(player1: player1DribblesCompleted, player2: player2DribblesCompleted, comp: 'Dribbles Completed',),
            SizedBox(height: 10),
            StyleRowInCards(player1: player1YellowCards, player2: player2YellowCards, comp: 'Yellow Cards',),

            SizedBox(height: 10),
            StyleRowInCards(player1: player1RedCards, player2: player2RedCards, comp: 'Red Cards',),

            SizedBox(height: 10),
            StyleRowInt(player1: player1FoulGoals, player2: player2FoulGoals, comp: 'Foul Goals',),

            SizedBox(height: 10),
            StyleRowInt(player1: player1PenaltyGoals, player2: player2PenaltyGoals, comp: 'Penalty Goals',),

          ],
        )
    );
  }
}

class RowComGaolKeeper extends StatelessWidget {
  final int player1cleanSheets;
  final int player2cleanSheets;

  final int player1saves;
  final int player2saves;

  final int player1penaltiesSaved;
  final int player2penaltiesSaved;

  final int player1ownGoals;
  final int player2ownGoals;

  final int player1goalsConceded;
  final int player2goalsConceded;
  const RowComGaolKeeper({super.key,
    required this.player1cleanSheets, required this.player2cleanSheets,
    required this.player1saves, required this.player2saves,
    required this.player1penaltiesSaved, required this.player2penaltiesSaved,
    required this.player1ownGoals, required this.player2ownGoals,
    required this.player1goalsConceded, required this.player2goalsConceded});

  @override
  Widget build(BuildContext context) {
    return  Container(
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StyleRowInt(player1: player1cleanSheets, player2: player2cleanSheets, comp: 'cleanSheets',),

            SizedBox(height: 10),
            StyleRowInt(player1: player1saves, player2: player2saves, comp: 'saves',),

            SizedBox(height: 10),
            StyleRowInt(player1: player1penaltiesSaved, player2: player2penaltiesSaved, comp: 'penaltiesSaved',),


            SizedBox(height: 10),
            StyleRowInt(player1: player1ownGoals, player2: player2ownGoals, comp: 'ownGoals',),


            SizedBox(height: 10),
            StyleRowNum(player1: player1goalsConceded, player2: player2goalsConceded, comp: 'goalsConceded',),

          ],
        )
    );
  }
}


class StyleRowInt extends StatelessWidget {
  final int player1;
  final int player2;
  final String comp;
  const StyleRowInt({super.key, required this.player1, required this.player2, required this.comp});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          player1.toString(),
          style: TextStyle(
            color: player1 > player2 ? Colors.green : Colors.white,
            fontSize:  17,
            fontWeight: player1 > player2 ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
        Text(comp, style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
        Text(
          player2.toString(),
          style: TextStyle(
            color: player2 > player1 ? Colors.green : Colors.white,
            fontSize:  17,
            fontWeight: player2 > player1 ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class StyleRowInCards extends StatelessWidget {
  final int player1;
  final int player2;
  final String comp;
  const StyleRowInCards({super.key, required this.player1, required this.player2, required this.comp});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          player1.toString(),
          style: TextStyle(
            color: player1 < player2 ? Colors.green : Colors.white,
            fontSize:  17,
            fontWeight: player1 < player2 ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
        Text(comp, style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
        Text(
          player2.toString(),
          style: TextStyle(
            color: player2 < player1 ? Colors.green : Colors.white,
            fontSize:  17,
            fontWeight: player2 < player1 ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
class StyleRowNum extends StatelessWidget {
  final num player1;
  final num player2;
  final String comp;

  const StyleRowNum({
    super.key,
    required this.player1,
    required this.player2,
    required this.comp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          player1.toStringAsFixed(1), // عرض الرقم بدقة رقم واحد بعد الفاصلة
          style: TextStyle(
            color: player1 > player2 ? Colors.green : Colors.white,
            fontSize: 17,
            fontWeight: player1 > player2 ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
        Text(
          comp,
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
        ),
        Text(
          player2.toStringAsFixed(1), // عرض الرقم بدقة رقم واحد بعد الفاصلة
          style: TextStyle(
            color: player2 > player1 ? Colors.green : Colors.white,
            fontSize: 17,
            fontWeight: player2 > player1 ? FontWeight.w700 : FontWeight.w300,
          ),
        ),
      ],
    );
  }
}



