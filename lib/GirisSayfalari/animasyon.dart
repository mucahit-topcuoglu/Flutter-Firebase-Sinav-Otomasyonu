import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sinavv/GirisSayfalari/girisSayfalari.dart';

class AnimasyonEkrani extends StatefulWidget {
  const AnimasyonEkrani({super.key});

  @override
  State<AnimasyonEkrani> createState() => _AnimasyonEkraniState();
}

class _AnimasyonEkraniState extends State<AnimasyonEkrani> {
  @override
  void initState() {
    super.initState();
    zamanlayici();
  }

  void zamanlayici() {
    Duration beklemeSuresi = const Duration(seconds: 3);
    Timer(beklemeSuresi, anaSayfayaGit);
  }

  void anaSayfayaGit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OgrenciGirisEkrani(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Lottie.asset(
            "assets/animasyon.json",
          ),
        ),
      ),
    );
  }
}
