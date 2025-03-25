import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/Personel%20Sayfalari/s%C4%B1navaSoruEkleme.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class SinavDetayEkrani extends StatefulWidget {
  final String sinavId;
  final String kullaniciId;

  SinavDetayEkrani({required this.sinavId, required this.kullaniciId});

  @override
  _SinavDetayEkraniState createState() => _SinavDetayEkraniState();
}

class _SinavDetayEkraniState extends State<SinavDetayEkrani> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> sinavBilgileriniGetir() async {
    try {
      final doc =
          await _firestore.collection('sinavlar').doc(widget.sinavId).get();

      if (!doc.exists) {
        throw DatabaseException('Sınav bulunamadı');
      }

      return doc.data() ?? {};
    } on FirebaseException catch (e) {
      throw DatabaseException('Sınav bilgileri alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<List<Map<String, dynamic>>> sinavSorulariniGetir() async {
    try {
      final querySnapshot = await _firestore
          .collection('sinavlar')
          .doc(widget.sinavId)
          .collection('questions')
          .get();

      final soruIdleri =
          querySnapshot.docs.map((doc) => doc['soruId'] as String).toList();

      if (soruIdleri.isEmpty) {
        return [];
      }

      final questionSnapshot = await _firestore
          .collection('questions')
          .where(FieldPath.documentId, whereIn: soruIdleri)
          .get();

      return questionSnapshot.docs
          .map((doc) => {'id': doc.id, 'data': doc.data()})
          .toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Sınav soruları alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> sinavaSoruEkle(String soruId) async {
    try {
      await _firestore
          .collection('sinavlar')
          .doc(widget.sinavId)
          .collection('questions')
          .doc(soruId)
          .set({'soruId': soruId});
      setState(() {});
    } on FirebaseException catch (e) {
      throw DatabaseException('Soru eklenirken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> sinavdanSoruSil(String soruId) async {
    try {
      await _firestore
          .collection('sinavlar')
          .doc(widget.sinavId)
          .collection('questions')
          .doc(soruId)
          .delete();
      setState(() {});
    } on FirebaseException catch (e) {
      throw DatabaseException('Soru silinirken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
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
      appBar: appbarMethod("Sınav Detayları", true),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: sinavBilgileriniGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Sınav bilgisi bulunamadı.'));
          }

          final sinavBilgi = snapshot.data!;
          final sinavAdi = sinavBilgi['sinavAdi'] ?? 'Bilinmeyen Sınav';
          final dersKodu = sinavBilgi['dersKodu'] ?? 'Bilinmeyen Ders';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sınav Adı: $sinavAdi', style: Sabitler.baslikStili),
                const SizedBox(height: 10),
                Text('Ders Kodu: $dersKodu', style: Sabitler.metinStili),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: sinavSorulariniGetir(),
                    builder: (context, soruSnapshot) {
                      if (soruSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!soruSnapshot.hasData || soruSnapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('Bu sınav için soru bulunamadı.'));
                      }

                      final sorular = soruSnapshot.data!;

                      return ListView.builder(
                        itemCount: sorular.length,
                        itemBuilder: (context, index) {
                          final soru = sorular[index]['data'];
                          final soruId = sorular[index]['id'];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(soru['metin'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  ...soru['secenekler']?.entries.map<Widget>(
                                          (entry) => Text(
                                              '${entry.key}) ${entry.value}')) ??
                                      [],
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  sinavdanSoruSil(soruId);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Sabitler.elevatedButtonStyle,
                    onPressed: () async {
                      final yeniSoruId = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SoruSecimEkrani(
                            sinavId: widget.sinavId,
                            kullaniciId: widget.kullaniciId,
                            dersKodu: dersKodu,
                          ),
                        ),
                      );
                      if (yeniSoruId != null) {
                        sinavaSoruEkle(yeniSoruId);
                      }
                    },
                    child: Text(
                      "Soru Ekle",
                      style: Sabitler.metinStili,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          bottomBarPersonelMethod(context, 4, widget.kullaniciId),
    );
  }
}
