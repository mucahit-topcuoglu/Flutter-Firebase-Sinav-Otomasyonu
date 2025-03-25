import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/SoruDuzenlemeSayfasi.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/SınıfveSabitler/sabitler.dart';

class SorularSayfasi extends StatefulWidget {
  final String kullaniciId;

  SorularSayfasi({required this.kullaniciId});

  @override
  _SorularSayfasiState createState() => _SorularSayfasiState();
}

class _SorularSayfasiState extends State<SorularSayfasi> {
  final FirebaseFirestore _veritabani = FirebaseFirestore.instance;

  // Soruları veritabanından al
  Future<List<Map<String, dynamic>>> sorulariGetir() async {
    QuerySnapshot snapshot = await _veritabani
        .collection('questions')
        .where('ogretmenId', isEqualTo: widget.kullaniciId)
        .get();

    return snapshot.docs
        .map(
            (doc) => {'id': doc.id, 'data': doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Düzenleme sayfasına git
  void duzenlemeSayfasinaGit(
      BuildContext context, String id, Map<String, dynamic> soruVerisi) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SoruDuzenleSayfasi(soruId: id, soruVerisi: soruVerisi),
      ),
    );

    // Düzenleme sonrası sayfayı yenile
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarMethod('Sorular', true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: sorulariGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Kayıtlı soru bulunamadı."));
          }

          List<Map<String, dynamic>> sorular = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: sorular.length,
            itemBuilder: (context, index) {
              var soru = sorular[index]['data'];
              var id = sorular[index]['id'];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}. ${soru['metin']}',
                          style: Sabitler.araBaslik),
                      const SizedBox(height: 10),
                      for (var secenek in soru['secenekler'].entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text('${secenek.key}) ${secenek.value}',
                              style: Sabitler.metinStili),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Doğru Cevap: ${soru['dogruCevap']}',
                              style: Sabitler.dogruCevap),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await _veritabani
                                      .collection('questions')
                                      .doc(id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Soru başarıyla silindi.')));
                                  // Silme sonrası sayfayı yenile
                                  setState(() {});
                                },
                                icon: const Icon(Icons.delete,
                                    color: Color.fromARGB(255, 255, 17, 0)),
                              ),
                              IconButton(
                                onPressed: () {
                                  duzenlemeSayfasinaGit(context, id, soru);
                                },
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                              ),
                            ],
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
      bottomNavigationBar:
          bottomBarPersonelMethod(context, 2, widget.kullaniciId),
    );
  }
}
