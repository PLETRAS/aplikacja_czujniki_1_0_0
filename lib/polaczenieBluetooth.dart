import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_settings/app_settings.dart';
import 'data.dart';
import 'package:network_info_plus/network_info_plus.dart';

class BluetoothApp extends StatefulWidget {
  var callback2;
  var kolor2;

  BluetoothApp(this.kolor2,{required this.callback2});
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp>
    with WidgetsBindingObserver {
  BluetoothConnection? connection;
  late void Function(Czujnik) _callback2;

  // var wartosc;

  var editMode = true;

  late TextEditingController _SSID;
  late TextEditingController _PASS;

  ///POZNIEJ TRZEBA USUNAC
  var SSID = "";
  var PASS = "";
  var TOPIC = 'test_topic2';
  var edytujZatwierdz = "zatwierdź";
  bool bluetoothEnabled = false;
  var warunek1 = false;
  var warunek2 = false;
  var warunek3 = false;
  var warunek4 = false;
  var warunek5 = false;
  var potwierdzenie1 = false;
  var potwierdzenie2 = false;
  var potwierdzenie3 = false;
  var potwierdzenie4 = false;
  var potwierdzenie5 = false;
  int ktoraproba = 0;

  void initState() {
    super.initState();
    _callback2 = widget.callback2;
    WidgetsBinding.instance!.addObserver(this);
    openBluetoothSettings();
    pobierzSparowaneUrzadzenia();
    pobierzSsid();
  }

  @override
  void pobierzSsid() async {
    final info = NetworkInfo();
    final wifiName = await info.getWifiName();
    print("SSID $wifiName");

    setState(() {
      _SSID = TextEditingController(
          text: wifiName?.substring(1, wifiName.length - 1) ?? "");
      _PASS = TextEditingController();
    });
  }

  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void openBluetoothSettings() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnable();
      print("Użytkownik wrócił z ustawień Bluetooth");
      // Wykonaj operacje po tym, jak użytkownik wróci z ustawień Bluetooth
    } catch (e) {
      print("Błąd podczas otwierania ustawień Bluetooth: $e");
    }
  }

  List<BluetoothDevice> sparowaneUrzadzenia = [];

  Future<void> pobierzSparowaneUrzadzenia() async {
    try {
      sparowaneUrzadzenia =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      for (int i = 0; i < sparowaneUrzadzenia.length; i++) {
        if (sparowaneUrzadzenia[i].name == "ESP32") {
          setState(() {
            warunek1 = true;
            pobierzSsid();
          });

          break;
        } else {
          setState(() {
            warunek1 = false;
          });
        }
      }
    } catch (e) {
      print('Błąd podczas pobierania sparowanych urządzeń: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      await pobierzSparowaneUrzadzenia();

      // Tutaj możesz sprawdzić stan Bluetooth i zaktualizować widok
      // np. poprzez wywołanie metody do aktualizacji stanu w zależności od stanu Bluetooth
    }
  }

  void saveButton() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    BuildContext? dialogContext = null;
    setState(() {
      SSID = _SSID.text;
      PASS = _PASS.text;
      editMode = !editMode;
      if (editMode) {
        edytujZatwierdz = "zatwierdź";

        warunek3 = false;
      } else {
        edytujZatwierdz = "edytuj";

        warunek3 = true;
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection newConnection =
          await BluetoothConnection.toAddress(device.address);
      Fluttertoast.showToast(msg: 'Połączony z ${device.name}');
      setState(() {
        connection = newConnection;
        warunek2 = true;

      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error connecting to ${device.name}');
    }
  }

  void _sendMessage(String message, String co) async {
    try {
      if (connection != null && connection!.isConnected) {
        connection!.output.add(const Utf8Encoder().convert(message));
        await connection!.output.allSent;
        //Fluttertoast.showToast(msg: 'Przesyłam: $co');
        setState(() {
          warunek4 = true;
        });
      } else {
        //Fluttertoast.showToast(msg: 'No active connection');
      }
    } catch (e) {
      //Fluttertoast.showToast(msg: 'Error sending message');
    }
  }

  void zleDane() {
    setState(() {
      warunek4 = false;
      warunek3 = false;
      editMode = !editMode;
      Fluttertoast.showToast(msg: "Podałeś złe dane spróbuj ponownie");
    });
  }

  void _getMessage() async {
    Timer(Duration(milliseconds: 1500), () {
      ktoraproba += 1;
      if (ktoraproba < 3) {
        polaczenie();
      }
    });
    int iloscKafelkow = await loadSavedValue() ?? 0;
    connection?.input?.listen((data) {
      print('Data incoming: ${ascii.decode(data)}');
      String wiadomosc = ascii.decode(data);
      if (wiadomosc == "!") {
        print("złe dane");
        zleDane();
      } else {
        String typ;
        String nazwa = "";
        String jednostka = "";
        String id = wiadomosc.substring(3, 7);
        typ = ascii.decode(data)[7];
        if (id[0] == "w") {
          nazwa = 'czujnik wilgotnosci';
          jednostka = "%";
        }
        if (id[0] == "t") {
          nazwa = 'czujnik tempratury';
          jednostka = "℃";
        }
        String potwierdzenie = wiadomosc.substring(0, 3);

        if (potwierdzenie == "111") {
          saveValue(iloscKafelkow + 1);
          Czujnik czujnik =
              Czujnik(iloscKafelkow, id, nazwa, -1, "", jednostka);

          if (warunek5 == false) {
            _callback2(czujnik);
            setState(() {
              zapiszDaneDoSkrzynki(czujnik, czujnik.ktoreMiejsceWLiscie);
              warunek5 = true;
              Navigator.pop(context);
            });
          }
        }
        // if (ascii.decode(data).contains('!')) {
        //   connection?.finish(); // Zamykanie połączenia
        //   print('Rozłączanie przez lokalnego hosta');
      }
    });
    // }, onDone: () {
    //   print('Rozłączono na żądanie zdalnego hosta');
    // });
  }

  Future<bool> _potwierdzenie(String klucz, String klucz2) async {
    Completer<bool> completer = Completer<bool>();

    Timer(Duration(milliseconds: 500), () {
      completer.complete(false); // Zwracaj false po 0.5 sekundy
    });

    connection?.input?.listen((data) {
      print('Data incoming: ${ascii.decode(data)}');
      if (klucz == ascii.decode(data)) {
        completer.complete(true); // Jeśli klucz się zgadza, zwróć true
      }
      if (klucz2 == ascii.decode(data)) {
        completer.complete(true); // Jeśli klucz się zgadza, zwróć true
        Fluttertoast.showToast(msg: 'Nie można się połączyć do wifi spróbuj ponownie');

        ///W tej funkcji trzeba cos zrobic
        potwierdzenie3 = true;
      }
    });

    return completer.future;
  }

  void polaczenie() async {
    potwierdzenie1 = false;
    potwierdzenie2 = false;
    potwierdzenie3 = false;
    potwierdzenie4 = false;
    potwierdzenie5 = false;
    //while (!potwierdzenie1) {

    _sendMessage("\"$SSID", "SSID");
    await Future.delayed(Duration(milliseconds: 200));
    _sendMessage("\'" + PASS, "Hasło");
    await Future.delayed(Duration(milliseconds: 200));
    _sendMessage("`" + TOPIC, "Topic");
    _getMessage();
    //await Future.delayed(Duration(seconds: 1));
    print("HALO");

    //}

    // while (!potwierdzenie2) {
    //   _sendMessage("#", "TESTWIFI");
    //   potwierdzenie2=await _potwierdzenie("POŁACZENIEUDANE",'!');
    // }

  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Połącz urządzenie'),
      ),
      body: Center(
        child: Container(
          width: screenSize.size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: screenSize.size.width * 0.37,
                    child: ElevatedButton(
                      onPressed: () async {
                        AppSettings.openBluetoothSettings();
                        await FlutterBluetoothSerial.instance.requestEnable();
                      },
                      child: const Text('Ustawienia Bluetooth'),
                    ),
                  ),
                  Container(
                    width: screenSize.size.width * 0.37,
                    child: Visibility(
                      visible: warunek1,
                      child: ElevatedButton(
                        onPressed: () async {
                          List<BluetoothDevice> devices =
                              await FlutterBluetoothSerial.instance
                                  .getBondedDevices();
                          if (devices.isEmpty) {
                            Fluttertoast.showToast(
                                msg: 'brak zapisanych urządzeń');
                          } else {
                            _showDeviceDialog(devices);
                          }
                        },
                        child: const Text('Połącz urządzenie'),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: warunek2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: TextField(
                        decoration:  InputDecoration(
                          labelText: "Nazwa sieci",
                          disabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey)),
                           enabledBorder: OutlineInputBorder(
                               borderSide:
                                   BorderSide(width: 1, color: widget.kolor2 ?? Colors.grey)),
                           focusedBorder: OutlineInputBorder(
                               borderSide:
                                   BorderSide(width: 1, color: widget.kolor2 ?? Colors.grey)),
                        ),
                        controller: _SSID,
                        // onSubmitted: (String value) {
                        //   nameButton();
                        // },
                        enabled: editMode,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(0 , 10, 0, 5),
                      child: TextField(
                        decoration:  InputDecoration(
                          labelText: "Hasło",
                          disabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: widget.kolor2 ?? Colors.blue )),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: widget.kolor2 ?? Colors.green)),
                        ),
                        controller: _PASS,

                        // onSubmitted: (String value) {
                        //   nameButton();
                        // },
                        enabled: editMode,
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: warunek2,
                child: Container(
                    width: double.maxFinite,
                    child: ElevatedButton(
                        onPressed: () {
                          saveButton();
                        },
                        child: Text(edytujZatwierdz))),
              ),
              Visibility(
                visible: warunek2,
                child: Container(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: !editMode && warunek1 && warunek2
                        ? () async {
                            polaczenie();
                            await Future.delayed(Duration(milliseconds: 2000));
                            polaczenie();
                          }
                        : null,
                    child: const Text('Prześlij dane'),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("\nInstrukcja"),
                  Text(
                    "1.Przejdź do ustawień BLUETOOTH i połącz wybrane urządzenie.(ma zostać zapisane w ustawieniach lecz nie połączone)\n",
                    style:
                        warunek1 ? const TextStyle(color: Colors.green) : null,
                  ),
                  Text(
                    "2.Połącz się z urządzeniem w aplikacji.\n",
                    style:
                        warunek2 ? const TextStyle(color: Colors.green) : null,
                  ),
                  Text(
                    "3.Wpisz odpowiednie dane w pola tekstowe, nazwa sieci (SSID) i hasło i zatwierdź dane.\n",
                    style:
                        warunek3 ? const TextStyle(color: Colors.green) : null,
                  ),
                  Text(
                    "4.Po wprowadzeniu wszystkich danych, kliknij przycisk \"Prześlij dane\" aby przesłać wprowadzone dane.\n",
                    style:
                        warunek4 ? const TextStyle(color: Colors.green) : null,
                  ),
                  Text(
                    "5.Poczekaj na potwierdzenie.",
                    style:
                        warunek5 ? const TextStyle(color: Colors.green) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeviceDialog(List<BluetoothDevice> devices) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a device'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: devices.map((device) {
                return ListTile(
                  title: Text(device.name ?? 'Unknown'),
                  subtitle: Text(device.address),
                  onTap: () {
                    Navigator.pop(context);
                    _connectToDevice(device);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
