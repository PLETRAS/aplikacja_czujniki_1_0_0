import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
// class Czujnik {
//   int id;
//   String nazwa;
//   int wilgotnosc;
//   String opis;
//   String jednostka;
//   Czujnik(this.id,this.nazwa, this.wilgotnosc,this.opis,this.jednostka);
// }

// class DaneProvider extends ChangeNotifier {
//   List<Czujnik> _dane = [];
//
//   List<Czujnik> get dane => _dane;
//
//   void updateDane(List<Czujnik> newDane) {
//     _dane = newDane;
//     notifyListeners();
//   }
// }
class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 2; // Unikalne ID dla adaptera Color

  @override
  Color read(BinaryReader reader) {
    int value = reader.read(); // Odczytaj wartość koloru jako liczbę całkowitą
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.write(obj.value); // Zapisz wartość koloru jako liczbę całkowitą
  }
}





Future<Color?> odczytajKolorZeSkrzynki(int ktoryKolor) async {
  final box = await Hive.openBox<Color>('colorsBox');

  final kolor = box.get(ktoryKolor);
  await box.close();

  return kolor;
}

void usunKolorZeSkrzynki() async {
  final box = await Hive.openBox<Color>('colorsBox');
  await box.delete(0);
  await box.close();
}
void zmniejszLiczbeKafelkow()async{
  int value = await loadSavedValue() ?? 0;
  saveValue(value-1);
}

Future<int?> loadSavedValue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? counter = prefs.getInt('counter');
  return(counter);
}
// Funkcja do zapisywania wartości
Future<void> saveValue(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('counter', value);
}

List<Czujnik> dane = [
  //Czujnik(1,"w223",'Czujnik wilgotności gleby', 25,"roslina wymaga Sdafgawfgfaxcawascawcacawwaca","%"),
  //Czujnik(2,"t263",'tempratura', 45,"temperatura na zewnatrz","℃"),
  // Czujnik(2,'Czuaxdsad gleby', 25,"roslina daw222dscawcacawwaca","%"),
  // Czujnik(2,'tempratura', 75,"temperatura na zewnatrz","℃"),
  // Czujnik(2,'Czusdawdawdości gleby', 90,"roswcawascawcacawwaca","%"),
  // Czujnik(2,'tempratura', 34,"temperatura na zewnatrz","℃"),
  // Czujnik(2,'Czujnik wilgotności gleby', 65,"roslina wymaerxwcacawwaca","%"),
  //Czujnik(0,2,'czujnik tempratury', 12,"temperasdwdaatrz","℃"),
];
class Czujnik  {
  @HiveField(0)
  int ktoreMiejsceWLiscie;
  @HiveField(1)
  String id;
  @HiveField(2)
  String nazwa;
  @HiveField(3)
  int wilgotnosc;
  @HiveField(4)
  String opis;
  @HiveField(5)
  String jednostka;
  Czujnik(this.ktoreMiejsceWLiscie,this.id,this.nazwa, this.wilgotnosc,this.opis,this.jednostka);
}
Future<Czujnik> odebranieDanych(int ktoryItem) async {
  final box = await Hive.openBox<Czujnik>('peopleBox');
  Czujnik czujnik = box.get(0) ?? Czujnik(ktoryItem,"0", '', 0, '', ''); // Zwróć pusty obiekt, jeśli nie ma danych

  print('Odczytany czujnik: ${czujnik.nazwa}, wilgotność: ${czujnik.wilgotnosc}%');

  await box.close(); // Nie zapomnij zamknąć skrzynki po operacji

  return czujnik;
}
//
class CzujnikAdapter extends TypeAdapter<Czujnik> {


  @override
  int get typeId => 1;


  @override
  Czujnik read(BinaryReader reader) {
    int ktoreMiejsceWLiscie = reader.read();
    String id = reader.read();
    String nazwa = reader.read();
    int wilgotnosc = reader.read();
    String opis = reader.read();
    String jednostka = reader.read();

    return Czujnik(ktoreMiejsceWLiscie, id, nazwa, wilgotnosc, opis, jednostka);
  }

  @override
  void write(BinaryWriter writer, Czujnik obj) {
    writer.write(obj.ktoreMiejsceWLiscie);
    writer.write(obj.id);
    writer.write(obj.nazwa);
    writer.write(obj.wilgotnosc);
    writer.write(obj.opis);
    writer.write(obj.jednostka);
  }
}


Future<Czujnik?> odczytajDaneZeSkrzynki(int ktoryItem) async {
  // Otwórz skrzynkę Hive
  final box = await Hive.openBox<Czujnik>('peopleBox');

  // Odczytaj obiekt klasy Czujnik z indeksem 0
  final czujnik = box.get(ktoryItem);

  // Możesz teraz korzystać z odczytanych danych z czujnika
  print('Odczytany czujnik: ${czujnik?.nazwa}, wilgotność: ${czujnik?.wilgotnosc}%');

  // Zamknij skrzynkę Hive
  await box.close();

  return czujnik;
}

late Czujnik? czujnikDoOdczytania;
Future<void> zapiszDaneDoSkrzynki(Czujnik nowyCzujnik, int ktoryItem) async {
  final box = await Hive.openBox<Czujnik>('peopleBox');

  await box.put(ktoryItem, nowyCzujnik);

  await box.close();
}
void usunDaneZeSkrzynki(int ktoryItem) async {
  final box = await Hive.openBox<Czujnik>('peopleBox');
  await box.delete(ktoryItem);
  await box.close();
}
void usunCalBox() async {
  await Hive.deleteBoxFromDisk('peopleBox');
}
//
//
//
//
// Future<void> zapiszDane() async {
//   final peopleBox = await Hive.openBox<Czujnik>('peopleBox');
//
//   // Użyj metody put(), aby zapisać obiekt do skrzynki
//   final czujnik=Czujnik(1,'Czujnik wilgotności gleby', 25,"roslina wymaga Sdafgawfgfaxcawascawcacawwaca","%");
//   await peopleBox.put(0, czujnik);
//
//
//
//   await peopleBox.close();
// }
//
// // Future<void> zapisDanych(ktoryItem) async {
// //   final person = ktoryItem('Alice', 25);
// //   peopleBox.put('key', person);
// // }
// Future<void> odczytajWszystkieDane() async {
//   final box = await Hive.openBox<Czujnik>('peopleBox');
//   final czujnik = Czujnik(1, 'Nazwa czujnika', 50, 'Opis czujnika', '%');
//   await box.put(0, czujnik);
//
//   await box.close(); // Nie zapomnij zamknąć skrzynki po operacji
// }
// // final int wilgotnosc = 50;
// // final box = await Hive.openBox<int>('czujnikiBox');
// //  // Przykładowa wartość int
// // await box.put('liczbaCzujnikow', wilgotnosc); // Zapisz int do Hiv
// // await box.close();
// // final wilgotnosc = box.get('wilgotnosc', defaultValue: 0); // Pobierz int z Hive
// //
// // await box.put('wilgotnosc', 75); // Zmiana wartości int w Hive
//
//
// class CzujnikAdapter extends TypeAdapter<Czujnik> {
//
//
//   @override
//   int get typeId => 1;
//
//
//   @override
//   Czujnik read(BinaryReader reader) {
//     int id = reader.read();
//     String nazwa = reader.read();
//     int wilgotnosc = reader.read();
//     String opis = reader.read();
//     String jednostka = reader.read();
//
//     return Czujnik(id, nazwa, wilgotnosc, opis, jednostka);
//   }
//
//   @override
//   void write(BinaryWriter writer, Czujnik obj) {
//     writer.write(obj.id);
//     writer.write(obj.nazwa);
//     writer.write(obj.wilgotnosc);
//     writer.write(obj.opis);
//     writer.write(obj.jednostka);
//   }
// }

// Funkcja do odczytywania zapisanej wartości
