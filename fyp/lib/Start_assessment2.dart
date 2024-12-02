import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class StartAssessmentPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const StartAssessmentPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  _StartAssessmentPageState createState() => _StartAssessmentPageState();
}

class _StartAssessmentPageState extends State<StartAssessmentPage> {
  bool _isProcessing = false;
  bool _isGraphActive = false;

  // MQTT Client
  late MqttServerClient client;

  // Graph Data
  List<FlSpot> xData = [];
  List<FlSpot> yData = [];
  List<FlSpot> zData = [];
  double time = 0.0;

  // API URLs
  static const String _startAssessmentUrl =
      "http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/start-assessment";
  static const String _updateAssessmentUrl =
      "http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/update-assessment";

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    client = MqttServerClient('broker.hivemq.com', '');
    client.logging(on: false);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    print('Connected to MQTT broker');
    client.subscribe('your/topic', MqttQos.atLeastOnce);
    client.updates?.listen(_onMessage);
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? event) {
    if (!_isGraphActive) return; // Do not update if graph is inactive

    final recMessage = event![0].payload as MqttPublishMessage;
    final payload =
    MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    final data = payload.split(','); // Assume data format is "x,y,z"

    if (data.length == 3) {
      setState(() {
        time += 1; // Increment time for graph x-axis
        xData.add(FlSpot(time, double.tryParse(data[0]) ?? 0));
        yData.add(FlSpot(time, double.tryParse(data[1]) ?? 0));
        zData.add(FlSpot(time, double.tryParse(data[2]) ?? 0));

        // Keep only the latest 50 points for performance
        if (xData.length > 50) xData.removeAt(0);
        if (yData.length > 50) yData.removeAt(0);
        if (zData.length > 50) zData.removeAt(0);
      });
    }
  }

  Future<void> _startAssessment(BuildContext context) async {
    setState(() {
      _isProcessing = true;
      _isGraphActive = true; // Activate graph when assessment starts
    });

    try {
      final response = await http.post(
        Uri.parse(_startAssessmentUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"patientId": widget.patientId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Assessment started successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? "Failed to start assessment.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _updateAssessment(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_updateAssessmentUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"patientId": widget.patientId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Assessment updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? "Failed to update assessment.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Start Assessment",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA7FFEB), // Light cyan
              Color(0xFF1DE9B6), // Teal
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Graph
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 50,
                  minY: -50,
                  maxY: 50,
                  lineBarsData: [
                    LineChartBarData(
                      spots: xData,
                      isCurved: true,
                      color: Colors.red, // Use a single color
                    ),
                    // Repeat for yData and zData
                    LineChartBarData(
                      spots: yData,
                      isCurved: true,
                      color: Colors.green,
                    ),
                    LineChartBarData(
                      spots: zData,
                      isCurved: true,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            // Buttons
            _isProcessing
                ? const CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton(
                  onPressed: () => _startAssessment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Start Assessment",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _updateAssessment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Update",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
