class Player {
  final String? playerId;
  final String coachId;
  final String teamId;
  final String firstName;
  final String lastName;
  final int playerNumber;
  final double height;
  final double weight;
  final String position;
  final String image;
  final List<Map<String, String>> videos;
  final int goals;
  final int assists;
  final int shotsOnTarget;
  final int tackles;
  final int interceptions;
  final double passAccuracy;
  final int dribblesCompleted;
  final int yellowCards;
  final int redCards;
  final int foulGoals;
  final int penaltyGoals;
  final int age;
  final String city;
  final int cleanSheets;
  final int saves;
  final int penaltiesSaved;
  final int ownGoals;
  final int goalsConceded;
  final List<Map<String, dynamic>> achievements;

  Player({
    this.playerId,
    required this.coachId,
    required this.teamId,
    required this.firstName,
    required this.lastName,
    required this.playerNumber,
    required this.height,
    required this.weight,
    required this.position,
    required this.image,
    required this.videos,
    required this.goals,
    required this.assists,
    required this.shotsOnTarget,
    required this.tackles,
    required this.interceptions,
    required this.passAccuracy,
    required this.dribblesCompleted,
    required this.yellowCards,
    required this.redCards,
    required this.foulGoals,
    required this.penaltyGoals,
    required this.age,
    required this.city,
    required this.cleanSheets,
    required this.saves,
    required this.penaltiesSaved,
    required this.ownGoals,
    required this.goalsConceded,
    this.achievements = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'coachId': coachId,
      'teamId': teamId,
      'firstName': firstName,
      'lastName': lastName,
      'playerNumber': playerNumber,
      'height': height,
      'weight': weight,
      'position': position,
      'image': image,
      'videos': videos,
      'goals': goals,
      'assists': assists,
      'shotsOnTarget': shotsOnTarget,
      'tackles': tackles,
      'interceptions': interceptions,
      'passAccuracy': passAccuracy,
      'dribblesCompleted': dribblesCompleted,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'foulGoals': foulGoals,
      'penaltyGoals': penaltyGoals,
      'age': age,
      'city': city,
      'cleanSheets': cleanSheets,
      'saves': saves,
      'penaltiesSaved': penaltiesSaved,
      'ownGoals': ownGoals,
      'goalsConceded': goalsConceded,
      'achievements': achievements,
    };
  }
}
