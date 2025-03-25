import 'package:flutter/material.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/Personel%20Sayfalari/bottomBarPersonelMethodu.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';
import 'package:sinavv/services/firestore_service.dart'; // Firestore servisi için.
import 'package:sinavv/SınıfveSabitler/hatalar.dart';

class SoruEklemeSayfasi extends StatefulWidget {
  final String ogretmenId;

  const SoruEklemeSayfasi({super.key, required this.ogretmenId});

  @override
  State<SoruEklemeSayfasi> createState() => _SoruEklemeSayfasiState();
}

class _SoruEklemeSayfasiState extends State<SoruEklemeSayfasi> {
  String? secilenCevap;

  // TextField controller'ları
  final TextEditingController soruMetniController = TextEditingController();
  final TextEditingController aSikkiController = TextEditingController();
  final TextEditingController bSikkiController = TextEditingController();
  final TextEditingController cSikkiController = TextEditingController();
  final TextEditingController dSikkiController = TextEditingController();
  final TextEditingController eSikkiController = TextEditingController();
  final TextEditingController dersKoduController = TextEditingController();
  final TextEditingController dersAdiController = TextEditingController();

  // Firestore servisi
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    List<String> siklar = ['A', 'B', 'C', 'D', 'E'];

    return Scaffold(
      appBar: appbarMethod('Soru Ekle', true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                'Soru Detayları',
                style: Sabitler.araBaslik,
              ),
              const SizedBox(height: 20),
              textFieldMethod(dersKoduController, 'Ders Kodu', false),
              const SizedBox(height: 10),
              textFieldMethod(dersAdiController, 'Ders Adı', false),
              const SizedBox(height: 20),
              Text(
                'Soru Metni',
                style: Sabitler.araBaslik,
              ),
              const SizedBox(height: 10),
              textFieldMethod(soruMetniController, 'Soru Metni', false),
              const SizedBox(height: 20),
              Text(
                'Şıklar',
                style: Sabitler.araBaslik,
              ),
              const SizedBox(height: 10),
              textFieldMethod(aSikkiController, 'A Şıkkı', false),
              const SizedBox(height: 10),
              textFieldMethod(bSikkiController, 'B Şıkkı', false),
              const SizedBox(height: 10),
              textFieldMethod(cSikkiController, 'C Şıkkı', false),
              const SizedBox(height: 10),
              textFieldMethod(dSikkiController, 'D Şıkkı', false),
              const SizedBox(height: 10),
              textFieldMethod(eSikkiController, 'E Şıkkı', false),
              const SizedBox(height: 20),
              Text(
                'Doğru Cevap',
                style: Sabitler.araBaslik,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                items: siklar.map((String deger) {
                  return DropdownMenuItem(
                    value: deger,
                    child: Text(deger),
                  );
                }).toList(),
                onChanged: (value) {
                  secilenCevap = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await soruKaydet(context);
                  },
                  child: Text(
                    'Kaydet',
                    style: Sabitler.metinStili,
                  ),
                  style: Sabitler.elevatedButtonStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          bottomBarPersonelMethod(context, 1, widget.ogretmenId),
    );
  }

  Future<void> soruKaydet(BuildContext context) async {
    try {
      if (soruMetniController.text.isEmpty ||
          aSikkiController.text.isEmpty ||
          bSikkiController.text.isEmpty ||
          cSikkiController.text.isEmpty ||
          dSikkiController.text.isEmpty ||
          eSikkiController.text.isEmpty ||
          dersKoduController.text.isEmpty ||
          dersAdiController.text.isEmpty) {
        throw ValidationException('Lütfen tüm alanları doldurun!');
      }

      await firestoreService.validateQuestionData({
        'metin': soruMetniController.text,
        'secenekler': {
          'A': aSikkiController.text,
          'B': bSikkiController.text,
          'C': cSikkiController.text,
          'D': dSikkiController.text,
          'E': eSikkiController.text,
        },
        'dogruCevap': secilenCevap,
      });

      await firestoreService.addQuestion({
        'dersKodu': dersKoduController.text,
        'dersAdi': dersAdiController.text,
        'metin': soruMetniController.text,
        'secenekler': {
          'A': aSikkiController.text,
          'B': bSikkiController.text,
          'C': cSikkiController.text,
          'D': dSikkiController.text,
          'E': eSikkiController.text,
        },
        'dogruCevap': secilenCevap,
        'ogretmenId': widget.ogretmenId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soru başarıyla kaydedildi!')),
      );

      // Alanları temizle
      temizleAlanlar();
    } on ValidationException catch (e) {
      showErrorMessage(context, e.toString());
    } on DatabaseException catch (e) {
      showErrorMessage(context, e.toString());
    } catch (e) {
      showErrorMessage(context, 'Soru kaydedilirken bir hata oluştu');
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void temizleAlanlar() {
    soruMetniController.clear();
    aSikkiController.clear();
    bSikkiController.clear();
    cSikkiController.clear();
    dSikkiController.clear();
    eSikkiController.clear();
    dersKoduController.clear();
    dersAdiController.clear();
  }
}
