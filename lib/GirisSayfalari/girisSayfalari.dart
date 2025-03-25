import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sinavv/GirisSayfalari/personelKayitSayfasi.dart';
import 'package:sinavv/GirisSayfalari/ogrenciKayitSayfasi.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Methodlar/drawer.dart';
import 'package:sinavv/Methodlar/girisSayfasiMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/PersonelAnaSayfa.dart';
import 'package:sinavv/OgrenciSayfalari/ogrenciAnaSayfasi.dart';

class PersonelGirisEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod('Personel Girişi', true),
      drawer: drawerMethod(context),
      body: GirisEkrani(
        context,
        'Personel Girişi',
        PersonelKayitEkrani(),
        'Personel Kayıt Ekranı',
        Icons.work,
        personelMi: true, // Giriş türü personel olarak ayarlandı
        girisBasarili: (User kullanici) {
          // Giriş başarılı olduğunda yapılacaklar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PersonelAnaEkran(
                kullaniciId: kullanici.uid, // Sadece kullanıcı ID'si gönderiliyor
              ),
            ),
          );
        },
      ),
    );
  }
}

class OgrenciGirisEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod('Öğrenci Girişi', true),
      drawer: drawerMethod(context),
      body: GirisEkrani(
        context,
        'Öğrenci Girişi',
        OgrenciKayitEkrani(),
        'Öğrenci Kayıt Ekranı',
        Icons.school,
        personelMi: false, // Giriş türü öğrenci olarak ayarlandı
        girisBasarili: (User kullanici) {
          // Giriş başarılı olduğunda yapılacaklar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OgrenciAnaEkran(
                kullaniciId: kullanici.uid, // Sadece kullanıcı ID'si gönderiliyor
              ),
            ),
          );
        },
      ),
    );
  }
}

