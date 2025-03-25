import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/Methodlar/appbarMethod.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

// ignore: must_be_immutable
class SoruDuzenleSayfasi extends StatelessWidget {
  final String soruId;
  final Map<String, dynamic> soruVerisi;

  SoruDuzenleSayfasi({required this.soruId, required this.soruVerisi});

  final TextEditingController soruMetniController = TextEditingController();
  final TextEditingController aSikkiController = TextEditingController();
  final TextEditingController bSikkiController = TextEditingController();
  final TextEditingController cSikkiController = TextEditingController();
  final TextEditingController dSikkiController = TextEditingController();
  final TextEditingController eSikkiController = TextEditingController();
  String? secilenDogruCevap;

  @override
  Widget build(BuildContext context) {
    soruMetniController.text = soruVerisi['metin'];
    aSikkiController.text = soruVerisi['secenekler']['A'];
    bSikkiController.text = soruVerisi['secenekler']['B'];
    cSikkiController.text = soruVerisi['secenekler']['C'];
    dSikkiController.text = soruVerisi['secenekler']['D'];
    eSikkiController.text = soruVerisi['secenekler']['E'];
    secilenDogruCevap = soruVerisi['dogruCevap'];

    return Scaffold(
      appBar: appbarMethod('Soru Düzenleme', true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              textFieldMetodu(soruMetniController, 'Soru Metni'),
              const SizedBox(height: 10),
              textFieldMetodu(aSikkiController, 'A Şıkkı'),
              const SizedBox(height: 10),
              textFieldMetodu(bSikkiController, 'B Şıkkı'),
              const SizedBox(height: 10),
              textFieldMetodu(cSikkiController, 'C Şıkkı'),
              const SizedBox(height: 10),
              textFieldMetodu(dSikkiController, 'D Şıkkı'),
              const SizedBox(height: 10),
              textFieldMetodu(eSikkiController, 'E Şıkkı'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: secilenDogruCevap,
                items: ['A', 'B', 'C', 'D', 'E'].map((deger) {
                  return DropdownMenuItem<String>(
                    value: deger,
                    child: Text(deger),
                  );
                }).toList(),
                onChanged: (deger) {
                  secilenDogruCevap = deger;
                },
                decoration: const InputDecoration(
                  labelText: 'Doğru Cevap',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: Sabitler.elevatedButtonStyle,
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('questions')
                        .doc(soruId)
                        .update({
                      'metin': soruMetniController.text,
                      'secenekler': {
                        'A': aSikkiController.text,
                        'B': bSikkiController.text,
                        'C': cSikkiController.text,
                        'D': dSikkiController.text,
                        'E': eSikkiController.text,
                      },
                      'dogruCevap': secilenDogruCevap,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Soru başarıyla güncellendi.')));
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Güncelle',
                    style: Sabitler.metinStili,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField textFieldMetodu(
      TextEditingController controller, String etiketMetni) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: etiketMetni),
    );
  }
}
