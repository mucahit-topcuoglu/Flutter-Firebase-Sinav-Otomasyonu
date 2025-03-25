import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/SınıfveSabitler/sabitler.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class SoruSecimEkrani extends StatefulWidget {
  final String sinavId;
  final String kullaniciId;
  final String dersKodu;

  SoruSecimEkrani({
    required this.sinavId,
    required this.kullaniciId,
    required this.dersKodu,
  });

  @override
  _SoruSecimEkraniState createState() => _SoruSecimEkraniState();
}

class _SoruSecimEkraniState extends State<SoruSecimEkrani> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> secilenSorular = [];
  List<Map<String, dynamic>> eklenmisSorular = [];

  @override
  void initState() {
    super.initState();
    eklenmisSorulariGetir();
  }

  Future<List<Map<String, dynamic>>> sorulariGetir() async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('ogretmenId', isEqualTo: widget.kullaniciId)
          .where('dersKodu', isEqualTo: widget.dersKodu)
          .get();

      if (snapshot.docs.isEmpty) {
        throw DatabaseException('Bu ders için soru bulunamadı');
      }

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'metin': doc['metin'],
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Sorular alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> eklenmisSorulariGetir() async {
    try {
      final snapshot = await _firestore
          .collection('sinavlar')
          .doc(widget.sinavId)
          .collection('questions')
          .get();

      setState(() {
        eklenmisSorular = snapshot.docs
            .map((doc) => {'id': doc['soruId'] as String})
            .toList();
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Eklenmiş sorular alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<void> sorulariSinavaEkle() async {
    try {
      if (secilenSorular.isEmpty) {
        throw ValidationException('Lütfen en az bir soru seçin');
      }

      final sinavRef = _firestore.collection('sinavlar').doc(widget.sinavId);

      for (String soruId in secilenSorular) {
        await sinavRef.collection('questions').doc(soruId).set({
          'soruId': soruId,
        });
      }

      showSuccessMessage('Sorular başarıyla eklendi!');
      setState(() {
        secilenSorular.clear();
      });

      await eklenmisSorulariGetir();
    } on ValidationException catch (e) {
      showErrorMessage(e.toString());
    } on DatabaseException catch (e) {
      showErrorMessage(e.toString());
    } catch (e) {
      showErrorMessage('Beklenmeyen bir hata oluştu');
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod("Soru Ekle", true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: sorulariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu: ${snapshot.error}',
                style: Sabitler.metinStili,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Uygun soru bulunamadı.',
                style: Sabitler.metinStili,
              ),
            );
          }

          final sorular = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: sorular.length,
                  itemBuilder: (context, index) {
                    final soru = sorular[index];
                    final eklenmisMi =
                        eklenmisSorular.any((q) => q['id'] == soru['id']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          soru['metin'],
                          style: Sabitler.metinStili,
                        ),
                        value:
                            secilenSorular.contains(soru['id']) || eklenmisMi,
                        onChanged: eklenmisMi
                            ? null
                            : (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    secilenSorular.add(soru['id']);
                                  } else {
                                    secilenSorular.remove(soru['id']);
                                  }
                                });
                              },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Sabitler.elevatedButtonStyle,
                    onPressed:
                        secilenSorular.isEmpty ? null : sorulariSinavaEkle,
                    child: Text(
                      'Soruları Ekle',
                      style: Sabitler.metinStili,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          bottomBarPersonelMethod(context, 4, widget.kullaniciId),
    );
  }
}
