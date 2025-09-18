import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _studentsCollection = FirebaseFirestore.instance.collection('Students');

  Future<void> addStudent({
    required String id,
    required String name,
    required int age,
    required double grade,
    required String gender,
  }) async {
    await _studentsCollection.add({
  'id': id,
  'name': name,
  'age': age,
  'grade': grade,
  'gender': gender,
});
print('✅ Student added to Firestore');
  } 
}
