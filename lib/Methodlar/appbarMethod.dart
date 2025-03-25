import 'package:flutter/material.dart';
import 'package:sinavv/S%C4%B1n%C4%B1fveSabitler/sabitler.dart';

AppBar appbarMethod(String Baslik, bool aktif) {
  return AppBar(
      centerTitle: true,
      title: Text(
        Baslik,
        style: Sabitler.baslikStili,
      ),
      automaticallyImplyLeading: aktif,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: Sabitler.appbarIcon);
}

AppBar appBarAnaSayfa(
  BuildContext context,
  Widget sayfa,
) {
  return AppBar(
    centerTitle: true,
    title: Text(
      'Ana Sayfa',
      style: Sabitler.baslikStili,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: true,
    actions: [
      IconButton(
        icon: const Icon(
          Icons.exit_to_app,
          color: Sabitler.ANA_RENK,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => sayfa,
            ),
          );
        },
      ),
    ],
  );
}
