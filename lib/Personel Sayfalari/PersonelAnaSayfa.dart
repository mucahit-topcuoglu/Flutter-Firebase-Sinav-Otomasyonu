import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/Personel%20Sayfalari/sinavOlusturmaSayfasi.dart';
import 'package:sinavv/Personel%20Sayfalari/sinavlar.dart';
import 'package:sinavv/Personel%20Sayfalari/soruEklemeSayfasi.dart';
import 'package:sinavv/Personel%20Sayfalari/sorularSayfasi.dart';
import 'package:sinavv/Personel%20Sayfalari/notlarSayfasi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sinavv/GirisSayfalari/animasyon.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

class PersonelAnaEkran extends StatelessWidget {
  final String kullaniciId;

  PersonelAnaEkran({required this.kullaniciId});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> ogretmenBilgisiGetir(String kullaniciId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('personeller')
        .doc(kullaniciId)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      return snapshot.data()!;
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Personel Ana Sayfa",
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: ogretmenBilgisiGetir(kullaniciId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Bilgiler yüklenemedi.",
                style: TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
            );
          }

          final ogretmenBilgi = snapshot.data!;
          final String ogretmenAdi =
              ogretmenBilgi['isimSoyisim'] ?? 'Bilinmeyen';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                    radius: 50,
                    backgroundColor: Sabitler.ANA_RENK,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    )),
                const SizedBox(height: 20),
                Text(
                  'Hoş geldiniz, $ogretmenAdi',
                  style: Sabitler.araBaslik.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Sabitler.ANA_RENK,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    menuButonuOlustur(
                      context,
                      'Soru Ekle',
                      Colors.blue,
                      Icons.add_circle,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SoruEklemeSayfasi(ogretmenId: kullaniciId),
                        ),
                      ),
                    ),
                    menuButonuOlustur(
                      context,
                      'Soruları Listele',
                      Colors.green,
                      Icons.list,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SorularSayfasi(kullaniciId: kullaniciId),
                        ),
                      ),
                    ),
                    menuButonuOlustur(
                      context,
                      'Öğrenci Notları',
                      Colors.orange,
                      Icons.score,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OgrenciNotlariEkrani(kullaniciId: kullaniciId),
                        ),
                      ),
                    ),
                    menuButonuOlustur(
                      context,
                      'Sınav Oluştur',
                      Colors.purple,
                      Icons.edit,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SinavOlusturmaEkrani(kullaniciId: kullaniciId),
                        ),
                      ),
                    ),
                    menuButonuOlustur(
                      context,
                      "Sınavlarım",
                      Colors.teal,
                      Icons.assignment,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SinavlarEkrani(kullaniciId: kullaniciId),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: bottomBarPersonelMethod(context, 0, kullaniciId),
    );
  }

  Widget menuButonuOlustur(BuildContext context, String etiket, Color renk,
      IconData ikon, VoidCallback tiklama) {
    return GestureDetector(
      onTap: tiklama,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk, width: 2),
          boxShadow: [
            BoxShadow(
              color: renk.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(3, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 50, color: renk),
            const SizedBox(height: 15),
            Text(
              etiket,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: renk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
