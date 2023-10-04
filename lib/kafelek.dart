import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
//import 'data.dart' show Czujnik;
import 'data.dart';

class Kafelek extends StatelessWidget {
  Czujnik dane;
  var wartosc;
  var kolor;
  var kolor2;
  final void Function(int) callback;
  Kafelek(this.kolor2,this.kolor,this.wartosc, this.dane, {required this.callback});

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) {
          return DimmedOverlay(kolor,dane,
              callback: callback); // Twój ekran z przyciemnionym tłem
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ///VVV UWAGA TU TRZEBA ZMIENIC VVV
    //dane.wilgotnosc = wartosc;
    var screenSize = MediaQuery.of(context);
    double containerHeight;
    switch (dane.id[0]) {
      case "w":
        containerHeight = screenSize.size.width * 0.45;
        break;
      case "t":
        containerHeight = screenSize.size.width * 0.695;
        break;
      default:
        containerHeight = screenSize.size.width * 0.45;
        break;
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, screenSize.size.width * 0.02, 0, 0),
      child: InkWell(
        onTap: () => _showOverlay(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: kolor2,
            boxShadow: [
              BoxShadow(
                color: Colors.grey, // Kolor cienia
                offset: Offset(-2, -2), // Przesunięcie cienia w osi X i Y
                blurRadius: 4, // Rozmycie cienia
                spreadRadius: 1, // Rozprzestrzenianie cienia
              ),
            ],
          ),


          width: screenSize.size.width * 0.45,
          height: containerHeight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: dane.id[0]=="t"
            ?Container(child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dane.nazwa,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    wskaznikTemp(0.165, dane),
                    Text(
                      "${dane.wilgotnosc}${dane.jednostka}",
                      style: const TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ))
            :Container(child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dane.nazwa,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                wskaznik(0.165, dane),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

//OKNO
class DimmedOverlay extends StatefulWidget {
  Czujnik dane;
  final void Function(int) callback;
  var kolor;
  DimmedOverlay(this.kolor,this.dane, {required this.callback});

  @override
  State<DimmedOverlay> createState() => _DimmedOverlayState();
}

class _DimmedOverlayState extends State<DimmedOverlay> {
  late TextEditingController _controller;
  var edytujOpis = false;
  var opis;
  late void Function(int) _callback;
  void trybEdycji(Czujnik dane) {
    if (edytujOpis == true) {
      setState(() {
        dane.opis = _controller.text;
        zapiszDaneDoSkrzynki(dane, dane.ktoreMiejsceWLiscie);
        opis = _controller.text;
        _controller = TextEditingController(text: widget.dane.opis);
        edytujOpis = false;
      });
    } else {
      setState(() {
        edytujOpis = true;
      });
    }
  }

  void initState() {
    super.initState();
    _callback = widget.callback;
    _controller = TextEditingController(text: widget.dane.opis);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          // Przyciemnione tło
          Positioned.fill(
            child: Container(
                decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(17),
            )
                // Przyciemniony kolor
                ),
          ),
          // Zawartość ekranu
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: widget.kolor,
                borderRadius: BorderRadius.circular(17),
              ),
              width: MediaQuery.of(context).size.width *
                  0.85, // 90% szerokości ekranu
              height: MediaQuery.of(context).size.height *
                  0.85, // 90% wysokości ekranu

              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.025,
                    0,
                    MediaQuery.of(context).size.width * 0.025,
                    0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          0,
                          MediaQuery.of(context).size.height * 0.015,
                          0,
                          MediaQuery.of(context).size.height * 0.015),
                      child: Text(
                        widget.dane.nazwa,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, 0, 0, MediaQuery.of(context).size.height * 0.015),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///Nie wiem czemu musi byc widget. ????
                          widget.dane.id[0]=="t"
                          ?wskaznikTemp(0.2, widget.dane)
                          :wskaznik(0.2,widget.dane),

                          Container(
                            width: screenSize.size.width * 0.35,
                            height: screenSize.size.width * 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //
                                //   nazwa,
                                //   textAlign: TextAlign.end,
                                //   style: const TextStyle(
                                //     fontSize: 18.0,
                                //     color: Colors.black,
                                //     decoration: TextDecoration.none,
                                //   ),
                                // ),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Wartość: ",
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        Text(
                                          "Jednostka: ",
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end ,
                                      children: [
                                      Text(
                                        "${widget.dane.wilgotnosc}",
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      Text(
                                        widget.dane.jednostka,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],)
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context2) {
                                                ///TUTAJ TRZEBA TAKIE DLA IOSA
                                                return AlertDialog(
                                                  title: Text("Usuń urządzenie"),
                                                  content: Text("Czy na pewno chcesz usunąć urządzenie?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        int ostMiejsce = dane.length - 1;
                                                        zmniejszLiczbeKafelkow();
                                                        for (int i = widget.dane.ktoreMiejsceWLiscie; i < ostMiejsce; i++) {
                                                          dane[i + 1].ktoreMiejsceWLiscie = i;
                                                          zapiszDaneDoSkrzynki(dane[i + 1], i);
                                                        }
                                                        usunDaneZeSkrzynki(ostMiejsce);
                                                        _callback(widget.dane.ktoreMiejsceWLiscie);
                                                        Navigator.of(context2).pop();
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Tak"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {

                                                        Navigator.of(context2).pop();
                                                      },
                                                      child: Text("Nie"),
                                                    ),
                                                  ],
                                                  elevation: 24.0,
                                                );
                                              },

                                            );

                                          },
                                          child: Text("usuń urządzenie"),
                                        )),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.35,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            trybEdycji(widget.dane);
                                            zapiszDaneDoSkrzynki(
                                                widget.dane,
                                                widget.dane
                                                    .ktoreMiejsceWLiscie); // Wywołanie funkcji wewnątrz funkcji onPressed
                                          },
                                          child: Text("Edytuj opis"),
                                        )),
                                  ],
                                ),
                                // Text(
                                //     style: const TextStyle(
                                //       fontSize: 18.0,
                                //       color: Colors.black,
                                //       decoration: TextDecoration.none,
                                //     ),
                                //     "$jednostka"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (edytujOpis)
                            ? Material(
                                child: TextField(
                                  decoration: InputDecoration(
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.grey)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.purple)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1, color: Colors.pink)),
                                    //<-- SEE HERE
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                  maxLines: null,
                                  controller: _controller,
                                  // Wstaw tutaj odpowiednie właściwości dla TextField
                                ),
                              )
                            : Text(
                                _controller.text,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                        // Container(
                        //     width: double.maxFinite,
                        //     child: ElevatedButton(
                        //       onPressed: () {
                        //         trybEdycji(); // Wywołanie funkcji wewnątrz funkcji onPressed
                        //       },
                        //       child: Text("Edytuj opis"),
                        //     )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class wskaznik extends StatelessWidget {
  Czujnik dane;
  var rozmiarWskaznika;
  wskaznik(this.rozmiarWskaznika, this.dane);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return dane.wilgotnosc == -1
        ? CircularPercentIndicator(
            radius: screenSize.size.width * rozmiarWskaznika,
            lineWidth: 6.0,

            percent: 0, // Przykładowy postęp (od 0 do 1)
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LoadingAnimationWidget.discreteCircle(
                              color: const Color.fromRGBO(139, 130, 255, 1),
                              size: 50,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            circularStrokeCap: CircularStrokeCap.round,

            backgroundColor: Colors.grey,
            linearGradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            startAngle: 180,

            // Ustawiamy reverse na true
            rotateLinearGradient:
                true, // Dodatkowe ustawienie obrócenia gradientu// Dodatkowe ustawienie obrócenia gradientu,
          )
        : CircularPercentIndicator(
            radius: screenSize.size.width * rozmiarWskaznika,
            lineWidth: 5.0,

            percent: dane.wilgotnosc / 100, // Przykładowy postęp (od 0 do 1)
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_outlined),
                Text(
                  "${dane.wilgotnosc}${dane.jednostka}",
                  style: const TextStyle(
                      fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            circularStrokeCap: CircularStrokeCap.round,

            backgroundColor: Colors.grey,
            linearGradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            startAngle: 180,

            // Ustawiamy reverse na true
            rotateLinearGradient:
                true, // Dodatkowe ustawienie obrócenia gradientu// Dodatkowe ustawienie obrócenia gradientu,
          );
  }
}
class wskaznikTemp extends StatelessWidget {


  Czujnik dane;
  var rozmiarWskaznika;
  wskaznikTemp(this.rozmiarWskaznika, this.dane);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return dane.wilgotnosc == -1
        ? Container(
      height: screenSize.size.width * 0.5,
          child: SfLinearGauge(
      minimum: -50.0,
      maximum: 50.0,
      orientation: LinearGaugeOrientation.vertical,
      majorTickStyle: LinearTickStyle(length: 5),
          axisTrackStyle: LinearAxisTrackStyle(
              gradient:const LinearGradient(
                  colors: [Colors.blue, Colors.purple]),
              edgeStyle: LinearEdgeStyle.bothFlat,
              thickness: 15.0,
              borderColor: Colors.grey),
      valueToFactorCallback: (value) {
          return (dane.wilgotnosc - (50.0)) / (100); // Adjust the calculation based on your requirements
      },
    ),
        )
        : Container(
      height: screenSize.size.width * 0.6,
          child: SfLinearGauge(
      minimum: -50.0,
      maximum: 50.0,
      orientation: LinearGaugeOrientation.vertical,
      majorTickStyle: LinearTickStyle(length: 5),
      axisTrackStyle: LinearAxisTrackStyle(
            gradient:const LinearGradient(
                colors: [Colors.blue, Colors.purple]),
            edgeStyle: LinearEdgeStyle.bothFlat,
            thickness: 15.0,
            borderColor: Colors.grey),


        barPointers: [LinearBarPointer(value: dane.wilgotnosc-50 )]

    ),
        );
  }
}
