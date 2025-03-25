import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/OgrenciSayfalari/ogrenciAnaSayfasi.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

class SinavSonuclariEkrani extends StatelessWidget {
  final String kullaniciId;

  SinavSonuclariEkrani({required this.kullaniciId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod('Notlarım', false),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('ogrenciler') // Öğrencilerin bulunduğu koleksiyon
            .doc(kullaniciId) // Kullanıcı ID'sine göre belge
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Notlar yüklenemedi!',
                style: Sabitler.baslikStili,
              ),
            );
          }

          // Firestore'dan gelen veriler
          final kullaniciVerisi = snapshot.data!.data() as Map<String, dynamic>;
          final notlar = kullaniciVerisi['puanlar'] as List<dynamic>? ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: notlar.length,
            itemBuilder: (context, index) {
              final not = notlar[index];
              int puan = not['puan'] * 5; // Puan 5 ile çarpılarak hesaplanıyor
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    'Sınav: ${not['sinavAdi']}',
                    style: Sabitler.metinStili,
                  ),
                  subtitle: Text(
                    'Not: $puan',
                    style: Sabitler.dogruCevap,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OgrenciAnaEkran(kullaniciId: kullaniciId),
              ),
            );
          },
          child: Text(
            'Ana Sayfaya Dön',
            style: Sabitler.metinStili,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: Sabitler.metinStili,
          ),
        ),
      ),
    );
  }
}
