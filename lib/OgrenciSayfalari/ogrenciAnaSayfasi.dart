import 'package:flutter/material.dart';
import 'package:sinavv/GirisSayfalari/animasyon.dart';
import 'package:sinavv/OgrenciSayfalari/sinavSayfasi.dart';
import 'package:sinavv/OgrenciSayfalari/sonuc.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OgrenciAnaEkran extends StatelessWidget {
  final String kullaniciId; // Giriş yapan öğrencinin ID'si
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OgrenciAnaEkran({required this.kullaniciId}); // Constructor ile ID alınıyor.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Öğrenci Ana Sayfa",
          style: Sabitler.baslikStili,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AnimasyonEkrani()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            menuButon(
              context,
              SinavEkrani(
                  kullaniciId: kullaniciId), // Sınav Sayfasına ID gönderiliyor
              'Sınava Başla',
              Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            menuButon(
              context,
              SinavSonuclariEkrani(
                  kullaniciId:
                      kullaniciId), // Notlarım Sayfasına ID gönderiliyor
              'Notlarım',
              Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget menuButon(
      BuildContext context, Widget sayfa, String yazi, Color renk) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => sayfa),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: renk,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [Sabitler.golgeStili],
        ),
        child: Text(
          yazi,
          textAlign: TextAlign.center,
          style: Sabitler.yaziStili,
        ),
      ),
    );
  }
}
