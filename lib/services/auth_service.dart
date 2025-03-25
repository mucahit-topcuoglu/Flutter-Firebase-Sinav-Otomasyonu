import 'package:firebase_auth/firebase_auth.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('Kullanıcı bulunamadı');
        case 'wrong-password':
          throw AuthException('Hatalı şifre');
        case 'invalid-email':
          throw AuthException('Geçersiz email formatı');
        default:
          throw AuthException('Giriş işlemi başarısız: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Çıkış yapılırken hata oluştu');
    }
  }
}
