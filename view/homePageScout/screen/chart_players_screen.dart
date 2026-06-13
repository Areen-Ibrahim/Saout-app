import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/color.dart';
import '../../homePage/widget/text_title_add_player.dart';

class ChartPlayersScreen extends StatefulWidget {
  const ChartPlayersScreen({super.key});

  @override
  State<ChartPlayersScreen> createState() => _ChartPlayersState();
}

class _ChartPlayersState extends State<ChartPlayersScreen> {
  late String teamId;
  late String selectedGKMetric;
  late String selectedPlayerMetric;

  final List<String> goalkeeperMetrics = [
    'cleanSheets', 'saves', 'penaltiesSaved', 'goalsConceded'
  ];

  final List<String> playerMetrics = [
    'goals', 'assists', 'shotsOnTarget', 'tackles', 'interceptions',
    'passAccuracy', 'dribblesCompleted', 'yellowCards', 'redCards',
    'foulGoals', 'penaltyGoals'
  ];

  @override
  void initState() {
    super.initState();
    teamId = Get.arguments['teamId']; // الحصول على معرف الفريق
    selectedGKMetric = goalkeeperMetrics.first; // اختيار القيمة الافتراضية لحراس المرمى
    selectedPlayerMetric = playerMetrics.first; // اختيار القيمة الافتراضية للاعبين العاديين
  }

  Future<List<dynamic>> fetchPlayersData() async {
    try {
      // جلب بيانات الفريق من قاعدة البيانات
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance
          .collection('team').doc(teamId).get();

      if (teamSnapshot.exists) {
        // الحصول على قائمة معرفات اللاعبين
        List<dynamic> playerIds = teamSnapshot['playersId'] ?? [];

        // جلب معلومات اللاعبين من جدول players باستخدام المعرفات
        QuerySnapshot playersSnapshot = await FirebaseFirestore.instance
            .collection('players')
            .where(FieldPath.documentId, whereIn: playerIds)
            .get();

        // تحويل معلومات اللاعبين إلى قائمة
        return playersSnapshot.docs.map((doc) {
          Map<String, dynamic> playerData = doc.data() as Map<String, dynamic>;
          return {
            'playerId': doc.id,
            'firstName': playerData['firstName'] ?? 'لا يوجد اسم',
            'lastName': playerData['lastName'] ?? 'لا يوجد لقب',
            'age': playerData['age'] ?? 0,
            'position': playerData['position'] ?? 'لا يوجد مركز',
            // جميع الإحصائيات المطلوبة
            'goals': playerData['goals'] ?? 0,
            'assists': playerData['assists'] ?? 0,
            'shotsOnTarget': playerData['shotsOnTarget'] ?? 0,
            'tackles': playerData['tackles'] ?? 0,
            'interceptions': playerData['interceptions'] ?? 0,
            'passAccuracy': (playerData['passAccuracy'] ?? 0.0).toInt(),
            'dribblesCompleted': playerData['dribblesCompleted'] ?? 0,
            'yellowCards': playerData['yellowCards'] ?? 0,
            'redCards': playerData['redCards'] ?? 0,
            'foulGoals': playerData['foulGoals'] ?? 0,
            'penaltyGoals': playerData['penaltyGoals'] ?? 0,
            // إضافة الحقول الجديدة
            'cleanSheets': playerData['cleanSheets'] ?? 0,
            'saves': playerData['saves'] ?? 0,
            'penaltiesSaved': playerData['penaltiesSaved'] ?? 0,
            'ownGoals': playerData['ownGoals'] ?? 0,
            'goalsConceded': playerData['goalsConceded'] ?? 0,
          };
        }).toList();
      } else {
        print('No team found for teamId: $teamId');
        return []; // إذا لم يتم العثور على الفريق
      }
    } catch (e) {
      print('Error fetching players data: $e');
      return []; // إعادة قائمة فارغة في حالة حدوث خطأ
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.background,
      appBar: AppBar(
        title: TextTitleAddPlayer(text: 'Player Performance Comparison',),
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(color: Colors.white, size: 20),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<dynamic>>(
          future: fetchPlayersData(), // جلب بيانات اللاعبين
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No player data available.'));
            }

            final playersData = snapshot.data!;
            // تصفية حراس المرمى وباقي اللاعبين
            final goalkeepers = playersData.where((player) => player['position'] == 'Goalkeeper').toList();
            final nonGoalkeepers = playersData.where((player) => player['position'] != 'Goalkeeper').toList();

            // احصل على أعلى قيمة للإحصائية المحددة لحراس المرمى
            final maxGKMetricValue = goalkeepers.isNotEmpty
                ? goalkeepers.map((player) => player[selectedGKMetric] as int).reduce((a, b) => a > b ? a : b).toDouble()
                : 0.0;

            // احصل على أعلى قيمة للإحصائية المحددة لباقي اللاعبين
            final maxPlayerMetricValue = nonGoalkeepers.isNotEmpty
                ? nonGoalkeepers.map((player) => player[selectedPlayerMetric] as int).reduce((a, b) => a > b ? a : b).toDouble()
                : 0.0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance of Goalkeepers',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.white, // لون الخلفية
                      borderRadius: BorderRadius.circular(8), // الزوايا المدورة
                      border: Border.all(color: Colors.blueAccent), // حدود زرقاء
                    ),
                    child: DropdownButton<String>(
                      value: selectedGKMetric,
                      items: goalkeeperMetrics.map((String metric) {
                        return DropdownMenuItem<String>(
                          value: metric,
                          child: Text(
                            metric,
                            style: TextStyle(color: Colors.black), // اللون الأسود للقيم في القائمة
                          ),
                        );
                      }).toList(),
                      style: TextStyle(color: Colors.white), // جعل النص المختار أبيض
                      dropdownColor: Colors.blueAccent,
                      onChanged: (newValue) {
                        setState(() {
                          selectedGKMetric = newValue!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250, // تحديد ارتفاع الرسم البياني
                    child: buildBarChart(goalkeepers, maxGKMetricValue, selectedGKMetric),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Performance of Other Players',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.white, // لون الخلفية
                      borderRadius: BorderRadius.circular(8), // الزوايا المدورة
                      border: Border.all(color: Colors.blueAccent), // حدود زرقاء
                    ),
                    child: DropdownButton<String>(
                      value: selectedPlayerMetric,
                      items: playerMetrics.map((String metric) {
                        return DropdownMenuItem<String>(
                          value: metric,
                          child: Text(metric, style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      style: TextStyle(color: Colors.white), // جعل النص المختار أبيض
                      dropdownColor: Colors.blueAccent,
                      onChanged: (newValue) {
                        setState(() {
                          selectedPlayerMetric = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250, // تحديد ارتفاع الرسم البياني
                    child: buildBarChart(nonGoalkeepers, maxPlayerMetricValue, selectedPlayerMetric),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildBarChart(List<dynamic> players, double maxMetricValue, String selectedMetric) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxMetricValue,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final player = players[group.x.toInt()];
                  return BarTooltipItem(
                    '${player['firstName']}\n${player[selectedMetric]}',
                    TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < players.length) {
                      final player = players[index];
                      return Text(
                        player['firstName'],
                        style: TextStyle(color: Colors.white),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: player[selectedMetric] is int
                        ? player[selectedMetric].toDouble()
                        : (player[selectedMetric] as double),
                    color: Colors.blueAccent,
                    width: 20,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
