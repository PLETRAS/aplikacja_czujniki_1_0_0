import 'package:flutter/material.dart';
import 'listaKolorow.dart';
class Menuprofilu extends StatelessWidget {
  var kolor;
  var zmianaMotywu;
  Menuprofilu(this.kolor,{this.zmianaMotywu});
  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: Container(
        color: kolor,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('O aplikacji'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Ustwaienia(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.workspace_premium),
              title: Text('Motyw'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Motyw(zmianaMotywu:zmianaMotywu),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
class Ustwaienia extends StatefulWidget {
  const Ustwaienia({Key? key}) : super(key: key);

  @override
  State<Ustwaienia> createState() => _UstwaieniaState();
}

class _UstwaieniaState extends State<Ustwaienia> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return SafeArea(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  "O aplikacji",
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.green,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Wersja 1.0.0"),
                    Text("kontakt: piotrek.piekarz1221@gmail.com "),


                  ],),
                )
              )
          ),
        )
    );
  }
}


class Motyw extends StatefulWidget {
  var zmianaMotywu;
  Motyw({this.zmianaMotywu});
  @override
  _MotywState createState() => _MotywState();
}

class _MotywState extends State<Motyw> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return SafeArea(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Wybierz motyw",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.green,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(children:[
              for(int i= 0;i<listaKolorow.length;i++)
               Container(

            color: (listaKolorow2[i]),
            width: double.maxFinite,

               child: Container(
                 margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                   Text("motyw ${nazwyKolorow[i]}"),
                   Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(17),
                         color: listaKolorow3[i],
                       ),

                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text("kolor kafelka"),
                   )),

                   ElevatedButton(
                       onPressed: () {
                         widget.zmianaMotywu(listaKolorow[i],listaKolorow2[i],listaKolorow3[i]);
                         zapiszKolorDoSkrzynki(listaKolorow[i],listaKolorow2[i],listaKolorow3[i]).then((_) {
                           // Tutaj możesz umieścić kod, który ma zostać wykonany po zapisaniu koloru
                         });
                       },
                     child: Text("Ustaw mowtyw"),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: listaKolorow[i],)
                   )
                 ],),
               ),)



        ]),
          )
      ),
      )
    );
  }
}

