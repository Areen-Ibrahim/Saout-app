import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  String requestId;
  String scoutId;
  String coachId;
  String teamId;
  String requestStatus;
  Timestamp createdAt;
  Timestamp updatedAt;

  RequestModel({
    required this.requestId,
    required this.scoutId,
    required this.coachId,
    required this.teamId,
    required this.requestStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // تحويل الـ Model إلى خريطة لكتابتها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'requestId' : requestId,
      'scoutId': scoutId,
      'coachId': coachId,
      'teamId': teamId,
      'requestStatus': requestStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // تحويل البيانات من Firestore إلى الـ Model
  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map['requestId'],
      scoutId: map['scoutId'],
      coachId: map['coachId'],
      teamId: map['teamId'],
      requestStatus: map['requestStatus'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  // أو يمكننا أيضاً استخدام هذه الطريقة بناءً على البيانات الخاصة بـ Firestore:
  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      requestId: data['requestId'],
      scoutId: data['scoutId'],
      coachId: data['coachId'],
      teamId: data['teamId'],
      requestStatus: data['requestStatus'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }
}
