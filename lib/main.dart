import 'package:flutter/material.dart';
import 'data.dart';

import 'komunikacjamqtt.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'kafelek.dart';
import 'DodajNowy.dart';
import 'package:flutter/services.dart';
import 'menuUstawien.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CzujnikAdapter());
  Hive.registerAdapter(ColorAdapter());
  int iloscKafelkow=  await loadSavedValue() ?? 0;
  // final czujnik = Czujnik(1,1, 'Czujnrxac2wdawdotności gleby', 53, "roslina wymaga Sdafgawfgfaxcawascawcacawwaca", "K");
  // zapiszDaneDoSkrzynki(czujnik,czujnik.ktoreMiejsceWLiscie);

  for(int i =0;i<iloscKafelkow;i++) {
    czujnikDoOdczytania = await odczytajDaneZeSkrzynki(i);
    dane.add(czujnikDoOdczytania!);

  }
  Color kolor= await odczytajKolorZeSkrzynki(0) ?? Colors.blue.shade700;
  Color kolor2= await odczytajKolorZeSkrzynki(1) ?? Colors.blue.shade100;
  Color kolor3= await odczytajKolorZeSkrzynki(2) ?? Colors.blue;
  runApp(MyApp(kolor,kolor2,kolor3));
}



class MyApp extends StatefulWidget {
  Color kolor;
  Color kolor2;
  Color kolor3;
  MyApp(this.kolor,this.kolor2,this.kolor3, {super.key});
  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {


  int _messageInt = -1;
  bool czyPolaczony = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,  // Tylko pionowo
    ]);
    super.initState();
    MQTTClientWrapper newclient = MQTTClientWrapper(kolorpolaczenia:kolorpolaczenia,odebranaWartosc:odebranaWartosc);
    newclient.prepareMqttClient();

  }
  void kolorpolaczenia(bool warunek){
    setState(() {
      czyPolaczony = warunek;
    });
  }
  void odebranaWartosc(String wartosc){
    setState(() {
      String id="";
      String wartoscCzujnika="";
      id=wartosc.substring(0,4);
      wartoscCzujnika=wartosc.substring(4);
      for(int i=0;i<dane.length;i++){
        if(dane[i].id==id){
          dane[i].wilgotnosc=int.parse(wartoscCzujnika);
          break;
        }
      }
    });
  }





  void callback(int index){
    setState(() {
      // Zaktualizuj listę `dane` po zmniejszeniu ilości obiektów
      dane.removeAt(index); // Przyjmuję, że usuwasz ostatni element
    });
  }
  void callback2(Czujnik czujnik){
    setState(() {
      // Zaktualizuj listę `dane` po zmniejszeniu ilości obiektów
      dane.add(czujnik); // Przyjmuję, że usuwasz ostatni element
    });
  }
  MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    Map<int, Color> swatch = <int, Color>{};
    final int primary = color.value;
    for (int index = 0; index < strengths.length; index++) {
      final int weight = strengths[index];
      final Color? blend = Color.lerp(Colors.white, color, weight / 100);
      swatch[weight] = blend!.withOpacity(1);
    }
    return MaterialColor(primary, swatch);
  }
  void zmianaMotywu(Color kolor, Color kolor2,Color kolor3){
    setState(() {
      widget.kolor=kolor;
      widget.kolor2=kolor2;
      widget.kolor3=kolor3;
    });
  }
  @override
  Widget build(BuildContext context) {
    //final daneProvider = Provider.of<DaneProvider>(context,listen: true);


    return MaterialApp(
        home: SafeArea(
            child: MaterialApp(
              theme: ThemeData(
                primarySwatch: createMaterialColor(widget.kolor),
                scaffoldBackgroundColor:widget.kolor2,
              ),
              home: Scaffold(
      appBar: AppBar(
        title: const Text("Twój botanik"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //for (int i = 0; i < dane.length; i+=2)
                        for (int i = 0; i < dane.length; i += 2)
                        Kafelek(widget.kolor3,widget.kolor2,_messageInt,dane[i],callback: callback),
                        if(dane.length%2==0)
                        DodajNowy(widget.kolor2,widget.kolor,widget.kolor3,callback2: callback2),
                        //ElevatedButton(onPressed: test, child: Text("Adadad"))
                      ],
                    ),
                    Column(
                      children: [
                        StanPolaczenia(widget.kolor3,czyPolaczony),
                        for (int i = 1; i < dane.length; i += 2)
                          Kafelek(widget.kolor3,widget.kolor2,_messageInt,dane[i],callback: callback),
                        //Kafelek(_messageInt, dane[0].nazwa),
                        if(dane.length%2==1)
                          DodajNowy(widget.kolor2,widget.kolor,widget.kolor3,callback2:callback2),
                      ],
                    ),
                  ],
                ),
              ),
          )
        ]),
      ),
                endDrawer: Menuprofilu(zmianaMotywu:zmianaMotywu,widget.kolor2),
    ),

            )));
  }
}

class StanPolaczenia extends StatelessWidget {
  bool polaczenie;
  var kolor;
  StanPolaczenia(this.kolor,this.polaczenie, {super.key});
  void _showOverlay2(BuildContext context) {
    ///Nie mozna kliknac panelu od polaczenia
    // Navigator.of(context).push(
    //   PageRouteBuilder(
    //     opaque: false,
    //     pageBuilder: (context, _, __) {
    //       return DimmedOverlay2(); // Twój ekran z przyciemnionym tłem
    //     },
    //   ),
    // );
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
            color: kolor,
            boxShadow: const [
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Icon(Icons.wifi),
                //     const Text("aktualna siec"),
                //   ],
                // ),
                polaczenie == true
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.connect_without_contact,
                                      color: Colors.green,),
                          Text("Połączony z serwerem"),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.connect_without_contact,
                          color: Colors.red,),
                          Text("Łączenie"),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}








  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


///TODO: dodac to jako haslo;
// class PasswordTextField extends StatefulWidget {
//   @override
//   _PasswordTextFieldState createState() => _PasswordTextFieldState();
// }
//
// class _PasswordTextFieldState extends State<PasswordTextField> {
//   bool _obscureText = true; // Początkowo hasło jest ukryte
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       obscureText: _obscureText, // Ukrywaj tekst jako hasło
//       decoration: InputDecoration(
//         labelText: 'Hasło',
//         suffixIcon: IconButton(
//           icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
//           onPressed: () {
//             setState(() {
//               _obscureText = !_obscureText; // Zmieniaj stan widoczności hasła
//             });
//           },
//         ),
//       ),
//     );
//   }
// }
