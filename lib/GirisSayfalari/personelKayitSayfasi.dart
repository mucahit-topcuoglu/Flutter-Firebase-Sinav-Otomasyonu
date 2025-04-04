import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/GirisSayfalari/girisSayfalari.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Methodlar/drawer.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class PersonelKayitEkrani extends StatefulWidget {
  @override
  _PersonelKayitEkraniState createState() => _PersonelKayitEkraniState();
}

class _PersonelKayitEkraniState extends State<PersonelKayitEkrani> {
  final TextEditingController _isimSoyisimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> personelKayit() async {
    try {
      String isimSoyisim = _isimSoyisimController.text.trim();
      String email = _emailController.text.trim();
      String sifre = _sifreController.text.trim();

      if (isimSoyisim.isEmpty || email.isEmpty || sifre.isEmpty) {
        throw ValidationException('Lütfen tüm alanları doldurun!');
      }

      UserCredential kullaniciBilgisi =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      await _firestore
          .collection('personeller')
          .doc(kullaniciBilgisi.user?.uid)
          .set({
        'isimSoyisim': isimSoyisim,
        'email': email,
        'uid': kullaniciBilgisi.user?.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı!')),
      );

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => PersonelGirisEkrani()));
    } on ValidationException catch (e) {
      showErrorMessage(context, e.toString());
    } on AuthException catch (e) {
      showErrorMessage(context, e.toString());
    } on DatabaseException catch (e) {
      showErrorMessage(context, e.toString());
    } catch (e) {
      showErrorMessage(context, 'Beklenmeyen bir hata oluştu');
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod("Personel Kayıt", true),
      drawer: drawerMethod(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.work, size: 200, color: Sabitler.ANA_RENK),
            textFieldMethod(_isimSoyisimController, 'İsim Soyisim', false),
            const SizedBox(height: 10),
            textFieldMethod(_emailController, 'E-Posta', false),
            const SizedBox(height: 10),
            textFieldMethod(_sifreController, 'Şifre', true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: Sabitler.elevatedButtonStyle,
              onPressed: personelKayit,
              child: Text(
                'Kayıt Ol',
                style: Sabitler.metinStili,
              ),
            ),
            const SizedBox(height: 20),
            elevatedButtonMethod(
                context, 'Personel Girişi', PersonelGirisEkrani())
          ],
        ),
      ),
    );
  }
}
