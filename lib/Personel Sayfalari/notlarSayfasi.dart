import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

class OgrenciNotlariEkrani extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String kullaniciId;

  OgrenciNotlariEkrani({required this.kullaniciId});

  Future<List<Map<String, dynamic>>> ogrenciNotlariniGetir() async {
    QuerySnapshot snapshot = await _firestore.collection('ogrenciler').get();

    List<Map<String, dynamic>> filtrelenmisOgrenciler = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> ogrenciVerisi = doc.data() as Map<String, dynamic>;

      if (ogrenciVerisi.containsKey('puanlar') &&
          ogrenciVerisi['puanlar'] is List<dynamic>) {
        List<dynamic> puanlar = ogrenciVerisi['puanlar'];
        List<Map<String, dynamic>> hocaFiltreliPuanlar = puanlar
            .where((puan) => puan['ogretmenId'] == kullaniciId)
            .map((puan) => {
                  'sinavAdi': puan['sinavAdi'],
                  'puan': puan['puan'],
                  'dersKodu': puan['dersKodu'],
                })
            .toList();

        if (hocaFiltreliPuanlar.isNotEmpty) {
          filtrelenmisOgrenciler.add({
            'isimSoyisim': ogrenciVerisi['isimSoyisim'] ?? 'Ad Belirtilmemiş',
            'numara': ogrenciVerisi['numara'] ?? 'Numara Belirtilmemiş',
            'puanlar': hocaFiltreliPuanlar,
          });
        }
      }
    }

    return filtrelenmisOgrenciler;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod('Öğrenci Notları', true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ogrenciNotlariniGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child:
                    Text("Bu öğretmen için kayıtlı öğrenci notu bulunamadı."));
          }

          List<Map<String, dynamic>> ogrenciler = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: ogrenciler.length,
            itemBuilder: (context, index) {
              var ogrenci = ogrenciler[index];
              return Card(
                elevation: 8,
                shadowColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Sabitler.ANA_RENK,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ogrenci['isimSoyisim'],
                                  style: Sabitler.metinStili),
                              const SizedBox(height: 5),
                              Text(
                                'Numara: ${ogrenci['numara']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (var puan in ogrenci['puanlar'])
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${puan['sinavAdi']}',
                                    style: Sabitler.metinStili),
                                Text(
                                  'Ders Kodu: ${puan['dersKodu']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (puan['puan'] * 5).toString(),
                                style: Sabitler.metinStili,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: bottomBarPersonelMethod(context, 3, kullaniciId),
    );
  }
}
