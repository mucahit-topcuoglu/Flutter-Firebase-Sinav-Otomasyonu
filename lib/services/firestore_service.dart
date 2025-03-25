import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addQuestion(Map<String, dynamic> questionData) async {
    try {
      await _firestore.collection('questions').add(questionData);
    } on FirebaseException catch (e) {
      throw DatabaseException('Soru eklenirken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<List<Map<String, dynamic>>> getQuestions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('questions').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Sorular alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> validateQuestionData(Map<String, dynamic> data) async {
    if (data['metin'] == null || data['metin'].toString().isEmpty) {
      throw ValidationException('Soru metni boş olamaz');
    }
    if (data['secenekler'] == null || (data['secenekler'] as Map).isEmpty) {
      throw ValidationException('Soru seçenekleri boş olamaz');
    }
    if (data['dogruCevap'] == null || data['dogruCevap'].toString().isEmpty) {
      throw ValidationException('Doğru cevap belirtilmeli');
    }
  }
}
