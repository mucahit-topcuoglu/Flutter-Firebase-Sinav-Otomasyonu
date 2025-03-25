import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/OgrenciSayfalari/sonuc.dart';
import 'dart:async';
import 'package:sinavv/SınıfveSabitler/sabitler.dart';
import 'package:sinavv/SınıfveSabitler/siniflar.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

// ignore: must_be_immutable
class SinavEkrani extends StatefulWidget {
  String kullaniciId;

  SinavEkrani({required this.kullaniciId});

  @override
  _SinavEkraniState createState() => _SinavEkraniState();
}

class _SinavEkraniState extends State<SinavEkrani> {
  String? secilenSinavId;
  String? sinavAdi;
  String? ogretmenId;
  String? dersKodu;
  List<Sorular> sorular = [];
  int seciliIndex = 0;
  String secilenCevap = '';
  int dogruSayisi = 0;
  late Timer _timer;
  int _kalanSure = 300;

  Future<bool> ogrenciSinavaKatildiMi(
      String kullaniciId, String sinavId) async {
    final ogrenciSnapshot = await FirebaseFirestore.instance
        .collection('ogrenciler')
        .doc(kullaniciId)
        .get();

    if (ogrenciSnapshot.exists) {
      List<dynamic> puanlar = ogrenciSnapshot.data()?['puanlar'] ?? [];
      return puanlar.any((puan) => puan['sinavId'] == sinavId);
    }

    return false;
  }

  Future<void> sorulariGetir(String sinavId) async {
    try {
      final soruSnap = await FirebaseFirestore.instance
          .collection('sinavlar')
          .doc(sinavId)
          .collection('questions')
          .get();

      if (soruSnap.docs.isEmpty) {
        throw DatabaseException('Bu sınav için soru bulunamadı');
      }

      List<String> soruIdleri =
          soruSnap.docs.map((doc) => doc['soruId'] as String).toList();

      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where(FieldPath.documentId, whereIn: soruIdleri)
          .get();

      setState(() {
        sorular = questionsSnapshot.docs
            .map((doc) => Sorular(
                  doc['metin'],
                  Map<String, String>.from(doc['secenekler']),
                  doc['dogruCevap'],
                ))
            .toList();

        sorular.shuffle();
      });

      zamanlayiciBaslat();
    } on DatabaseException catch (e) {
      showErrorMessage(context, e.toString());
    } catch (e) {
      showErrorMessage(context, 'Sorular yüklenirken bir hata oluştu');
    }
  }

  void zamanlayiciBaslat() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_kalanSure > 0) {
          _kalanSure--;
        } else {
          _timer.cancel();
          puanHesapla();
          firestoreaPuanKaydet(dogruSayisi);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SinavSonuclariEkrani(kullaniciId: widget.kullaniciId),
            ),
          );
        }
      });
    });
  }

  Future<void> firestoreaPuanKaydet(int puan) async {
    try {
      final ogrenciRef = FirebaseFirestore.instance
          .collection('ogrenciler')
          .doc(widget.kullaniciId);

      final ogrenciSnapshot = await ogrenciRef.get();

      if (!ogrenciSnapshot.exists) {
        throw DatabaseException('Öğrenci bilgisi bulunamadı');
      }

      List<dynamic> puanlar = ogrenciSnapshot.data()?['puanlar'] ?? [];
      puanlar.add({
        'sinavId': secilenSinavId,
        'sinavAdi': sinavAdi ?? 'Sinav Adı',
        'puan': puan,
        'ogretmenId': ogretmenId ?? 'Bilinmiyor',
        'dersKodu': dersKodu ?? 'Bilinmiyor',
      });

      await ogrenciRef.update({'puanlar': puanlar});
    } on DatabaseException catch (e) {
      showErrorMessage(context, e.toString());
    } catch (e) {
      showErrorMessage(context, 'Puan kaydedilirken bir hata oluştu');
    }
  }

  void puanHesapla() {
    print("Doğru Sayısı: $dogruSayisi");
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod('Sınav Ekranı', true),
      body: secilenSinavId == null ? sinavSecimEkrani() : soruEkrani(),
    );
  }

  Widget sinavSecimEkrani() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lütfen bir sınav seçin:', style: Sabitler.baslikStili),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('sinavlar').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('Sınav bulunamadı!', style: Sabitler.baslikStili);
              }

              final sinavlar = snapshot.data!.docs;

              return DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Sınav Seçiniz'),
                value: secilenSinavId,
                items: sinavlar.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(doc['sinavAdi']),
                  );
                }).toList(),
                onChanged: (value) async {
                  final zatenKatildi =
                      await ogrenciSinavaKatildiMi(widget.kullaniciId, value!);

                  if (zatenKatildi) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Bu sınava zaten katıldınız. Başka bir sınav seçiniz.')),
                    );
                  } else {
                    setState(() {
                      secilenSinavId = value;
                      sinavAdi = sinavlar
                          .firstWhere((doc) => doc.id == value)['sinavAdi'];
                      ogretmenId = sinavlar
                          .firstWhere((doc) => doc.id == value)['ogretmenId'];
                      dersKodu = sinavlar
                          .firstWhere((doc) => doc.id == value)['dersKodu'];
                    });
                    await sorulariGetir(secilenSinavId!);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget soruEkrani() {
    if (sorular.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final soru = sorular[seciliIndex];
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${seciliIndex + 1}. Soru', style: Sabitler.baslikStili),
          const SizedBox(height: 20),
          Text(soru.soru, style: Sabitler.araBaslik),
          const SizedBox(height: 20),
          for (var secenekKey in soru.secenekler.keys)
            GestureDetector(
              onTap: () {
                setState(() {
                  secilenCevap = secenekKey;
                  if (soru.dogruCevap == secilenCevap) {
                    dogruSayisi++;
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: secilenCevap == secenekKey
                      ? Sabitler.ANA_RENK
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [Sabitler.golgeStili],
                ),
                child: Text(
                  soru.secenekler[secenekKey] ?? '',
                  style: Sabitler.metinStili,
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (seciliIndex < sorular.length - 1) {
                    seciliIndex++;
                    secilenCevap = '';
                  } else {
                    puanHesapla();
                    firestoreaPuanKaydet(dogruSayisi);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinavSonuclariEkrani(
                            kullaniciId: widget.kullaniciId),
                      ),
                    );
                  }
                });
              },
              child: Text(
                seciliIndex == sorular.length - 1
                    ? 'Sınavı Tamamla'
                    : 'Sonraki Soru',
                style: Sabitler.metinStili,
              ),
              style: Sabitler.elevatedButtonStyle,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kalan Süre: ${(_kalanSure ~/ 60).toString().padLeft(2, '0')}:${(_kalanSure % 60).toString().padLeft(2, '0')}',
            style: Sabitler.metinStili,
          ),
        ],
      ),
    );
  }
}
