import 'package:aplikacja_z_czujnikamiv2/data.dart';
import 'package:flutter/material.dart';

import 'polaczenieBluetooth.dart';

class DodajNowy extends StatelessWidget {
  var callback2;
  var kolor;
  var kolor2;
  var kolor3;
  DodajNowy(this.kolor,this.kolor2,this.kolor3,{required this.callback2});

  //bool polaczenie;
  //DodajNowy(this.polaczenie);
  void _showOverlay2(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) {
          return DimmedOverlay3(kolor2,callback2: callback2); // Twój ekran z przyciemnionym tłem
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return InkWell(
        onTap: () => _showOverlay2(context),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, screenSize.size.width * 0.02, 0, 0),
          child: Container(
            width: screenSize.size.width * 0.45,
            height: screenSize.size.width * 0.43 / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: kolor3,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Kolor cienia
                  offset: Offset(-2, -2), // Przesunięcie cienia w osi X i Y
                  blurRadius: 4, // Rozmycie cienia
                  spreadRadius: 1, // Rozprzestrzenianie cienia
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.add,
                size: 50,
              ),
            ),
          ),
        ));
  }
}

class DimmedOverlay3 extends StatelessWidget {
  void Function(Czujnik) callback2;
  var kolor2;

  DimmedOverlay3(this.kolor2,  {required this.callback2});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);

    //print(wifiName);
    return GestureDetector(
      onTap: () {},
      child: Material(
        child: Stack(
          children: [
            // Przyciemnione tło
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pop(); // Zamknij karty po kliknięciu na przyciemnione tło
                },
                child: Container(
                    decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(17),
                )
                    // Przyciemniony kolor
                    ),
              ),
            ), // Zawartość ekranu
            Center(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: BluetoothApp(kolor2,callback2:callback2)),
            ),
          ],
        ),
      ),
    );
  }
}


