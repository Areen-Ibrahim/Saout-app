
class TeamModel {
  String? teamId; // إضافة معرف الفريق
  String? coachId;
  String teamName;
  String location;
  String description;
  String teamType;
  String image;
  double latitude;
  double longitude;
  double averageAgeOfPlayers;
  int    numberOfWins;
  List<String> playersId;

  TeamModel({
    this.teamId,
    required this.coachId,
    required this.teamName,
    required this.location,
    required this.description,
    required this.teamType,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.averageAgeOfPlayers,
    required this.numberOfWins,
    required this.playersId,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamID': teamId,
      'coachId': coachId,
      'teamName': teamName,
      'location': location,
      'description': description,
      'teamType': teamType,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'averageAgeOfPlayers': averageAgeOfPlayers,
      'numberOfWins': numberOfWins,
      'playersId' : playersId,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      teamId: map['teamID'], // استرجاع معرف الفريق
      coachId: map['coachId'] as String?, // استخدام as للتحويل
      teamName: map['teamName'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      teamType: map['teamType'] as String,
      image: map['image'] as String,
      latitude: (map['latitude'] as num).toDouble(), // تحويل num إلى double
      longitude: (map['longitude'] as num).toDouble(),
      averageAgeOfPlayers:  (map['averageAgeOfPlayers'] as num).toDouble(),
      numberOfWins: map['numberOfWins'] ?? 0,
      playersId: List<String>.from(map['playersId']),


    );
  }
}
