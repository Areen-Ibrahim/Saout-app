import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  String? matchID;
  String matchLocation;
  Timestamp matchDate;
  String matchFormation;
  List<String> playersWhoScored;
  String teamID;
  List<String> playerIDs;
  String coachID;
  int myResult;
  int opponentResult;
  String opponentTeamName;
  int winningMatchesCount;
  double latitude;
  double longitude;
  List<String> assisters;
  List<Map<String, dynamic>> goalsList; // قائمة الأهداف

  Match({
    this.matchID,
    required this.matchLocation,
    required this.matchDate,
    required this.matchFormation,
    required this.playersWhoScored,
    required this.teamID,
    required this.playerIDs,
    required this.coachID,
    required this.myResult,
    required this.opponentResult,
    required this.opponentTeamName,
    required this.winningMatchesCount,
    required this.latitude,
    required this.longitude,
    required this.assisters,
    required this.goalsList, // إضافة الحقل الجديد في الـ constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'matchID': matchID,
      'matchLocation': matchLocation,
      'matchDate': matchDate,
      'matchFormation': matchFormation,
      'playersWhoScored': playersWhoScored,
      'teamID': teamID,
      'playerIDs': playerIDs,
      'coachID': coachID,
      'myResult': myResult,
      'opponentResult': opponentResult,
      'opponentTeamName': opponentTeamName,
      'winningMatchesCount': winningMatchesCount,
      'latitude': latitude,
      'longitude': longitude,
      'assisters': assisters,
      'goalsList': goalsList, // إضافة الحقل الجديد هنا أيضًا
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      matchID: map['matchID'],
      matchLocation: map['matchLocation'],
      matchDate: map['matchDate'] ?? Timestamp.now(),
      matchFormation: map['matchFormation'],
      playersWhoScored: List<String>.from(map['playersWhoScored']),
      teamID: map['teamID'],
      playerIDs: List<String>.from(map['playerIDs']),
      coachID: map['coachID'],
      myResult: map['myResult'] ?? 0,
      opponentResult: map['opponentResult'] ?? 0,
      opponentTeamName: map['opponentTeamName'],
      winningMatchesCount: map['winningMatchesCount'] ?? 0,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      assisters: List<String>.from(map['assisters']),
      goalsList: List<Map<String, dynamic>>.from(map['goalsList']?.map((goal) => {
        'minute': goal['minute'] ?? 1,
        'playerId': goal['playerId'] ?? '',
      }) ?? []), // تحويل قائمة الأهداف في fromMap
    );
  }
}
