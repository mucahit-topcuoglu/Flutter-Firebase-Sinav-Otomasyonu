import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class SinavOlusturmaEkrani extends StatefulWidget {
  final String kullaniciId;

  SinavOlusturmaEkrani({required this.kullaniciId});

  @override
  _SinavOlusturmaEkraniState createState() => _SinavOlusturmaEkraniState();
}

class _SinavOlusturmaEkraniState extends State<SinavOlusturmaEkrani> {
  final TextEditingController sinavAdiController = TextEditingController();
  String? secilenDersKodu;
  List<String> secilenSorular = [];

  Future<List<String>> dersKodlariniGetir() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('ogretmenId', isEqualTo: widget.kullaniciId)
          .get();

      if (snapshot.docs.isEmpty) {
        throw DatabaseException('Hiç ders kodu bulunamadı');
      }

      final dersKodlari = snapshot.docs
          .map((doc) => doc['dersKodu'] as String)
          .toSet()
          .toList();

      return dersKodlari;
    } on FirebaseException catch (e) {
      throw DatabaseException('Ders kodları alınırken hata: ${e.message}');
    } catch (e) {
      throw DatabaseException('Beklenmeyen bir hata oluştu');
    }
  }

  Future<List<Map<String, dynamic>>> sorulariGetir(String dersKodu) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('dersKodu', isEqualTo: dersKodu)
        .where('ogretmenId', isEqualTo: widget.kullaniciId)
        .get();

    return snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'metin': doc['metin'],
              'secenekler': doc['secenekler'],
            })
        .toList();
  }

  Future<void> sinaviFirestoreaEkle(String sinavAdi, String dersKodu) async {
    try {
      if (sinavAdi.isEmpty || dersKodu.isEmpty || secilenSorular.isEmpty) {
        throw ValidationException(
            'Lütfen tüm alanları doldurun ve soruları seçin!');
      }

      DocumentReference sinavRef =
          await FirebaseFirestore.instance.collection('sinavlar').add({
        "sinavAdi": sinavAdi,
        "dersKodu": dersKodu,
        "ogretmenId": widget.kullaniciId,
      });

      for (String soruId in secilenSorular) {
        await sinavRef.collection('questions').doc(soruId).set({
          "soruId": soruId,
        });
      }

      showSuccessMessage(context, "Sınav başarıyla eklendi!");
    } on ValidationException catch (e) {
      showErrorMessage(context, e.toString());
    } on DatabaseException catch (e) {
      showErrorMessage(context, e.toString());
    } catch (e) {
      showErrorMessage(context, 'Beklenmeyen bir hata oluştu');
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Sınav Oluştur",
        style: Sabitler.baslikStili,
      )),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: sinavAdiController,
              decoration: const InputDecoration(labelText: 'Sınav Adı'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: dersKodlariniGetir(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Ders kodları bulunamadı!');
                }

                return DropdownButtonFormField<String>(
                  value: secilenDersKodu,
                  decoration: const InputDecoration(labelText: 'Ders Kodu'),
                  items: snapshot.data!.map((dersKodu) {
                    return DropdownMenuItem<String>(
                      value: dersKodu,
                      child: Text(dersKodu),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      secilenDersKodu = value;
                      secilenSorular.clear();
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            secilenDersKodu != null
                ? FutureBuilder<List<Map<String, dynamic>>>(
                    future: sorulariGetir(secilenDersKodu!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Bu ders için soru bulunamadı.");
                      }

                      final sorular = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: sorular.length,
                          itemBuilder: (context, index) {
                            var soru = sorular[index];
                            return CheckboxListTile(
                              title: Text(soru['metin']),
                              value: secilenSorular.contains(soru['id']),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    secilenSorular.add(soru['id']);
                                  } else {
                                    secilenSorular.remove(soru['id']);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      );
                    },
                  )
                : const Text('Lütfen önce bir ders kodu seçin.'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: Sabitler.elevatedButtonStyle,
              onPressed: () {
                if (sinavAdiController.text.isNotEmpty &&
                    secilenDersKodu != null &&
                    secilenSorular.isNotEmpty) {
                  sinaviFirestoreaEkle(
                      sinavAdiController.text, secilenDersKodu!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Lütfen tüm alanları doldurun ve soruları seçin!")),
                  );
                }
              },
              child: Text(
                "Sınavı Oluştur",
                style: Sabitler.metinStili,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
