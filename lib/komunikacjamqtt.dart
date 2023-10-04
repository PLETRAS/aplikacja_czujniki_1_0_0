import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';
enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttSubscriptionState {
  IDLE,
  SUBSCRIBED
}
class MQTTClientWrapper {
  var kolorpolaczenia;
  var odebranaWartosc;
  MQTTClientWrapper({this.kolorpolaczenia,this.odebranaWartosc});
  late MqttServerClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  // using async tasks, so the connection won't hinder the code flow
  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();

    //_subscribeToTopic('test_topic2');
    //_subscribeToTopic('Dart/Mqtt_client/testtopic');
    //_publishMessage('Hello');
  }

  // waiting for the connection, if an error occurs, print it and disconnect
  Future<void> _connectClient() async {

    bool polaczenie=false;
    while (!polaczenie) {
      try {
        print('client connecting....');
        connectionState = MqttCurrentConnectionState.CONNECTING;
        await client.connect('pazdzioch1', 'heQ32L.Ktr');
        await Future.delayed(Duration(milliseconds: 50));
      } on Exception catch (e) {
        print('client exception - $e');
        connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
        ///NIE WIEM CZEMU TU TEGO NIE MOZE BYC
        //client.disconnect();

      }

      // when connected, print a confirmation, else print an error
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        connectionState = MqttCurrentConnectionState.CONNECTED;
        polaczenie=true;
        print('client connected');
        _subscribeToTopic('test_topic2');
      } else {
        print(
            'ERROR client connection failed - disconnecting, status is ${client
                .connectionStatus}');
        connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
        ///NIE WIEM CZEMU TU TEGO NIE MOZE BYC
        //client.disconnect();
        await Future.delayed(Duration(seconds: 5));
      }
    }
  }
  void _setupMqttClient() {
    client = MqttServerClient.withPort('07ca4726ce1d472b9735c56b3f71daa9.s1.eu.hivemq.cloud', 'app_clienear532267561', 8883);
    // the next 2 lines are necessary to connect with tls, which is used by HiveMQ Cloud
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.exactlyOnce);

    // print the message when it is received
    // client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    //   //final MqttPublishMessage recMess = c[0].payload;
    //   //var message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    //
    //   print('YOU GOT A NEW MESSAGE:');
    //   print(message);
    // });
    client.updates?.listen(_onMessageReceived);
  }
  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> event) {
    for (MqttReceivedMessage<MqttMessage> message in event) {
      final String topic = message.topic;
      final MqttPublishMessage mqttMessage =
          message.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
          mqttMessage.payload.message!);
      if (topic == 'test_topic2') {
        // Wiadomość z tematu 'test_topic'

        odebranaWartosc(payload);
      }
    }
  }
  // void _publishMessage(String message) {
  //   final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
  //   builder.addString(message);
  //
  //   print('Publishing message "$message" to topic ${'Dart/Mqtt_client/testtopic'}');
  //   client.publishMessage('Dart/Mqtt_client/testtopic', MqttQos.exactlyOnce, builder.payload);
  // }

  // callbacks for different events
  void _onSubscribed(String topic) {

    print('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    kolorpolaczenia(false);
    _connectClient();
    print('OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    kolorpolaczenia(true);
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print('OnConnected client callback - Client connection was sucessful');
  }

}