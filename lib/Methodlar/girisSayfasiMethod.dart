import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sinavv/SınıfveSabitler/sabitler.dart';

// Giriş ekranı için yardımcı widget
Widget GirisEkrani(
  BuildContext context,
  String baslik,
  Widget kayitSayfasi,
  String kayitYazisi,
  IconData ikon, {
  required bool personelMi,
  required Function(User kullanici) girisBasarili,
}) {
  final TextEditingController emailKontrol = TextEditingController();
  final TextEditingController sifreKontrol = TextEditingController();

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 200, color: Sabitler.ANA_RENK), // İkon rengi mavi
            const SizedBox(height: 30),
            Text(
              baslik,
              style: Sabitler.baslikStili,
            ),
            const SizedBox(height: 30),
            textFieldMethod(emailKontrol, 'E-Mail', false),

            const SizedBox(height: 20),
            textFieldMethod(sifreKontrol, 'Şifre', true),

            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential kullaniciBilgi =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailKontrol.text.trim(),
                      password: sifreKontrol.text.trim(),
                    );

                    // Firestore'dan kullanıcı bilgisi kontrolü
                    final kullaniciBelgesi = await FirebaseFirestore.instance
                        .collection(personelMi ? 'personeller' : 'ogrenciler')
                        .doc(kullaniciBilgi.user!.uid)
                        .get();

                    if (kullaniciBelgesi.exists) {
                      // Giriş başarılı
                      girisBasarili(kullaniciBilgi.user!);
                    } else {
                      // Yanlış kullanıcı tipi
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bu giriş ekranını kullanamazsınız.'),
                        ),
                      );
                    }
                  } catch (e) {
                    // Hata mesajı
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Giriş başarısız. $e'  )),
                    );
                  }
                },
                style: Sabitler.elevatedButtonStyle,
                child: Text(
                  'Giriş Yap',
                  style: Sabitler.metinStili,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: elevatedButtonMethod(context, kayitYazisi, kayitSayfasi),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget sayfaOlusturucu(Widget sayfa, String kullaniciId) {
  if (sayfa is SayfaOlusturucuArayuzu) {
    return (sayfa as SayfaOlusturucuArayuzu).kimlikIleOlustur(kullaniciId);
  }
  return sayfa;
}

abstract class SayfaOlusturucuArayuzu {
  Widget kimlikIleOlustur(String kullaniciId);
}
