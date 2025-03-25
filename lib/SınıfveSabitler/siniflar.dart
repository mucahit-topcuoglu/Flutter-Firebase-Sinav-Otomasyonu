class Ogrenci {
  String? isim;
  String? numara;
  int? puan;
  Ogrenci(this.isim, this.numara, this.puan);
}

class Sorular {
  String soru;
  Map<String, String> secenekler;
  String dogruCevap;

  Sorular(
    this.soru,
    this.secenekler,
    this.dogruCevap,
  );
}

class Not {
  static int dogru = 0;
}
