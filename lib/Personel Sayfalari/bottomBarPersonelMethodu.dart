import 'package:flutter/material.dart';
import 'package:sinavv/Personel%20Sayfalari/PersonelAnaSayfa.dart';
import 'package:sinavv/Personel%20Sayfalari/notlarSayfasi.dart';
import 'package:sinavv/Personel%20Sayfalari/sinavlar.dart';
import 'package:sinavv/Personel%20Sayfalari/soruEklemeSayfasi.dart';
import 'package:sinavv/Personel%20Sayfalari/sorularSayfasi.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

BottomNavigationBar bottomBarPersonelMethod(
    BuildContext context, int aktifSayfaIndex, String kullaniciId) {
  final List<Widget> sayfalar = [
    PersonelAnaEkran(kullaniciId: kullaniciId),
    SoruEklemeSayfasi(ogretmenId: kullaniciId),
    SorularSayfasi(kullaniciId: kullaniciId),
    OgrenciNotlariEkrani(kullaniciId: kullaniciId),
    SinavlarEkrani(kullaniciId: kullaniciId),
  ];

  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: aktifSayfaIndex,
    selectedItemColor: Sabitler.ANA_RENK,
    onTap: (index) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => sayfalar[index]),
      );
    },
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Ana Sayfa',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_circle),
        label: 'Soru Ekle',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'Sorular',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.score),
        label: 'Notlar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: 'Sınavlar',
      ),
    ],
  );
}
