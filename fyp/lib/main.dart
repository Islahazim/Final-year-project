import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'mqttservices.dart'; // Import your MQTTService here

void main() {
  runApp(const QSATApp());
}

class QSATApp extends StatefulWidget {
  const QSATApp({super.key});

  @override
  State<QSATApp> createState() => _QSATAppState();
}

class _QSATAppState extends State<QSATApp> {
  final MQTTService mqttService = MQTTService();

  @override
  void initState() {
    super.initState();
    _initializeMQTT();
  }

  void _initializeMQTT() async {
    mqttService.onConnectionStatusChanged = (status) {
      print('MQTT Connection Status: $status');
    };

    mqttService.onMotionStatusReceived = (message) {
      print('MQTT Message Received: $message');
      // Optionally handle messages here or update state/UI
    };

    try {
      // Replace with your MQTT credentials
      await mqttService.connectToMQTT('Islahuddin', 'Bactidol');
    } catch (e) {
      print('Error initializing MQTT: $e');
    }
  }

  @override
  void dispose() {
    mqttService.client.disconnect(); // Disconnect MQTT client when app is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
      routes: {
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
