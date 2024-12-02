import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  // API URLs
  static const String _startAssessmentUrl =
      "http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/start-assessment";
  static const String _updateAssessmentUrl =
      "http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/update-assessment";

  Future<void> _startAssessment(BuildContext context) async {
    setState(() {
      _isProcessing = true;
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing) const CircularProgressIndicator(),
                if (!_isProcessing) ...[
                  ElevatedButton(
                    onPressed: () => _startAssessment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      minimumSize: const Size(double.infinity, 60), // Full width, fixed height
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
                      minimumSize: const Size(double.infinity, 60), // Full width, fixed height
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
