import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class Sabitler {
  static const ANA_RENK = Colors.indigo;

  static final TextStyle baslikStili = GoogleFonts.quicksand(
      fontSize: 24, fontWeight: FontWeight.w900, color: ANA_RENK);

  static final TextStyle metinStili = GoogleFonts.quicksand(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);

  static final TextStyle araBaslik = GoogleFonts.quicksand(
      fontSize: 20, fontWeight: FontWeight.w600, color: ANA_RENK);

  static final TextStyle yaziStili = GoogleFonts.quicksand(
      fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white);

  static final TextStyle dogruCevap = GoogleFonts.quicksand(
      fontSize: 20, fontWeight: FontWeight.w600, color: Colors.green.shade200);

  static final IconThemeData appbarIcon =
      IconThemeData(color: Sabitler.ANA_RENK);

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
  static final BoxShadow golgeStili = BoxShadow(
    color: Colors.grey.withOpacity(0.3),
    spreadRadius: 3,
    blurRadius: 5,
    offset: Offset(0, 3),
  );

  static var baslik;
}

TextField textFieldMethod(
    TextEditingController controller, String yazi, bool gizli) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: yazi,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      hintText: yazi,
    ),
    obscureText: gizli,
  );
}

ElevatedButton elevatedButtonMethod(
    BuildContext context, String yazi, Widget sayfa) {
  return ElevatedButton(
    style: Sabitler.elevatedButtonStyle,
    onPressed: () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => sayfa));
    },
    child: Text(
      yazi,
      style: Sabitler.metinStili,
    ), // Buton metni
  );
}
