class GoalsModel {
  String? goalId;
  final String playerId;
  final String matchId;
  final int goal_time;

  GoalsModel({
    this.goalId,
    required this.playerId,
    required this.matchId,
    required this.goal_time,
  });

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'playerId': playerId,
      'matchId': matchId,
      'goal': goal_time,
    };
  }

  factory GoalsModel.fromMap(Map<String, dynamic> map) {
    return GoalsModel(
      goalId: map['goalId'],
      playerId: map['playerId'],
      matchId: map['matchId'],
      goal_time: map['goal_time'] ?? 0,
    );
  }
  // GoalsModel copyWith({String? goalId, String? playerId, String? matchId, String? goal}) {
  //   return GoalsModel(
  //     goalId: goalId ?? this.goalId,
  //     playerId: playerId ?? this.playerId,
  //     matchId: matchId ?? this.matchId,
  //     goal_time: goal ?? this.goal_time,
  //   );
  // }
}
