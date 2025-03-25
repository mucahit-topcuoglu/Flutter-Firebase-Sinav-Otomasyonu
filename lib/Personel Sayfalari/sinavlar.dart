import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/Personel%20Sayfalari/sinavDetay.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class SinavlarEkrani extends StatelessWidget {
  final String kullaniciId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SinavlarEkrani({required this.kullaniciId});

  Future<List<Map<String, dynamic>>> sinavlariGetir() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sinavlar')
          .where('ogretmenId', isEqualTo: kullaniciId)
          .get();

      if (snapshot.docs.isEmpty) {
        throw DatabaseException('Hiç sınav bulunamadı');
      }

      return snapshot.docs
          .map((doc) => {'id': doc.id, 'data': doc.data()})
          .toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Sınavlar alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> sinaviSil(String sinavId) async {
    try {
      await _firestore.collection('sinavlar').doc(sinavId).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException('Sınav silinirken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> sinavSilmeIslemi(BuildContext context, String sinavId) async {
    try {
      bool onay = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sınav Sil"),
          content: const Text("Bu sınavı silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sil"),
            ),
          ],
        ),
      );

      if (onay == true) {
        await sinaviSil(sinavId);
        showErrorMessage(context, 'Sınav başarıyla silindi.');
        (context as Element).markNeedsBuild();
      }
    } on DatabaseException catch (e) {
      showErrorMessage(context, e.toString());
    } catch (e) {
      showErrorMessage(context, 'Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod("Sınavlar", false),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: sinavlariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Hiç sınav oluşturulmamış."));
          }

          List<Map<String, dynamic>> sinavlar = snapshot.data!;
          return ListView.builder(
            itemCount: sinavlar.length,
            itemBuilder: (context, index) {
              var sinav = sinavlar[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SinavDetayEkrani(
                          sinavId: sinav['id'],
                          kullaniciId: kullaniciId,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.assignment,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sinav['data']['sinavAdi'] ?? 'Sınav Adı',
                                  style: Sabitler.baslikStili),
                              const SizedBox(height: 5),
                              Text(sinav['data']['dersKodu'] ?? 'Ders Kodu',
                                  style: Sabitler.araBaslik),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await sinavSilmeIslemi(context, sinav['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: bottomBarPersonelMethod(context, 4, kullaniciId),
    );
  }
}
