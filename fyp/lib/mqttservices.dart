import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();

  factory MQTTService() {
    return _instance;
  }

  MQTTService._internal();

  final client = MqttServerClient.withPort(
    '1dd4053fd4a4443b9810ba948789a0f8.s1.eu.hivemq.cloud',
    'flutter_client_3',
    8883,
  );

  Function(String)? onMotionStatusReceived;
  Function(String)? onConnectionStatusChanged;

  Future<void> connectToMQTT(String username, String password) async {
    client.secure = true;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;

    try {
      print("Attempting to connect...");
      await client.connect(username, password);
      print("Connection successful");

      if (client.connectionStatus?.state == mqtt.MqttConnectionState.connected) {
        onConnectionStatusChanged?.call("Connected");
        print("Client connected: ${client.connectionStatus?.state}");

        client.subscribe('esp32/pub', mqtt.MqttQos.atLeastOnce);

        client.updates!.listen((List<mqtt.MqttReceivedMessage> messages) {
          final mqtt.MqttPublishMessage message =
          messages[0].payload as mqtt.MqttPublishMessage;
          final String payload = mqtt.MqttPublishPayload.bytesToStringAsString(
              message.payload.message);

          if (onMotionStatusReceived != null) {
            onMotionStatusReceived!(payload);
          }
        });
      } else {
        print('Connection failed: ${client.connectionStatus?.state}');
        onConnectionStatusChanged?.call("Failed to connect");
      }
    } catch (e) {
      print('Error connecting: $e');
      onConnectionStatusChanged?.call("Failed to connect");
      client.disconnect();
    }
  }

  void _onDisconnected() {
    print("Disconnected from MQTT Broker");
    onConnectionStatusChanged?.call("Disconnected");
  }

  void _onConnected() {
    print("Successfully connected to MQTT Broker");
  }

  void sendMessage(String topic, String message) {
    if (client.connectionStatus?.state == mqtt.MqttConnectionState.connected) {
      final mqtt.MqttClientPayloadBuilder builder =
      mqtt.MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, mqtt.MqttQos.atLeastOnce, builder.payload!);
    } else {
      print("Cannot send message. Client not connected.");
    }
  }
}
