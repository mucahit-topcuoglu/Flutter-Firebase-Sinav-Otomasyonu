# Sınav Yönetim Sistemi

Bu proje, öğretmenlerin sınav oluşturup yönetebileceği ve öğrencilerin bu sınavlara katılabileceği bir Flutter uygulamasıdır. Firebase Authentication ve Cloud Firestore kullanılarak geliştirilmiştir.

## Özellikler

### Öğretmen Paneli
- Soru bankası oluşturma ve yönetme
- Sınav oluşturma
- Öğrenci notlarını görüntüleme
- Sınavlara soru ekleme/çıkarma
- Ders kodlarına göre soru filtreleme

### Öğrenci Paneli
- Sınavlara katılma
- Anlık sınav puanı görüntüleme
- Geçmiş sınav sonuçlarını görüntüleme
- Zamanlı sınav sistemi

## Ekran Görüntüleri

# Ekran Görüntüleri

## Giriş Ekranları
<p float="left">
  <img src="screenshots/ogrenci_giris.png" width="200" alt="Öğrenci Giriş"/>
  <img src="screenshots/personel_giris.png" width="200" alt="Öğretmen Giriş"/>
</p>

## Öğretmen Paneli
<p float="left">
  <img src="screenshots/personel_ana.png" width="200" alt="Öğretmen Ana Sayfa"/>
  <img src="screenshots/soru_ekle.png" width="200" alt="Soru Ekleme"/>
  <img src="screenshots/sorular.png" width="200" alt="Sınav Oluşturma"/>
  <img src="screenshots/notlar.png" width="200" alt="Sınav Oluşturma"/>
</p>

## Öğrenci Paneli
<p float="left">
  <img src="screenshots/ogrenci_ana.png" width="200" alt="Öğrenci Ana Sayfa"/>
  <img src="screenshots/sinav_ekran.png" width="200" alt="Sonuçlar"/>
</p>

## Teknolojiler

- Flutter
- Firebase Authentication
- Cloud Firestore
- Google Fonts

## Kurulum

1. Projeyi klonlayın
```bash
git clone https://github.com/mucahit-topcuoglu/Flutter-Firebase-Sinav-Otomasyonu.git

2. Bağımlılıkları yükleyin
```bash
flutter pub get
```

3. Firebase yapılandırmasını gerçekleştirin
- Firebase Console'dan yeni bir proje oluşturun
- Flutter uygulamanız için Firebase yapılandırma dosyalarını indirin
- `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını projenize ekleyin

4. Uygulamayı çalıştırın
```bash
flutter run
```

## Katkıda Bulunma

1. Bu depoyu fork edin
2. Yeni bir özellik dalı oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Dalınıza push yapın (`git push origin feature/AmazingFeature`)
5. Bir Pull Request oluşturun



## İletişim

mmucahittopcuoglu@gmail.com

Proje Linki: https://github.com/mucahit-topcuoglu/Flutter-Firebase-Sinav-Otomasyonu
