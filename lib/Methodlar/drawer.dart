import 'package:flutter/material.dart';
import 'package:sinavv/GirisSayfalari/girisSayfalari.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

Drawer drawerMethod(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.white,
    child: ListView(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Sabitler.ANA_RENK),
          child: Column(
            children: [
              const Icon(Icons.person, size: 60, color: Colors.white),
              Text(
                "Giriş seçenekleri",
                style: Sabitler.yaziStili,
              ),
            ],
          ),
        ),
        listTileMethod(
            context, Icons.school, 'Öğrenci Girişi', OgrenciGirisEkrani()),
        listTileMethod(
            context, Icons.work, 'Personel Girişi', PersonelGirisEkrani()),
      ],
    ),
  );
}

ListTile listTileMethod(
    BuildContext context, IconData ikon, String yazi, Widget sayfa) {
  return ListTile(
    leading: Icon(ikon),
    title: Text(
      yazi,
      style: Sabitler.metinStili,
    ),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => sayfa));
    },
  );
}
