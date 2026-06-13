import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetTeams extends GetxController{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getSchoolTeamPlayers() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('team')
        .where('teamType', isEqualTo: 'School Team') // شرط لتحديد نوع الفريق
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    return documents.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getNonSchoolTeamPlayers() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('team')
        .where('teamType', isNotEqualTo: 'School Team') // شرط لتحديد أن نوع الفريق ليس "School Team"
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    return documents.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}