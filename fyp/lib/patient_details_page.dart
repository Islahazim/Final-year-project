import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  const PatientDetailsPage({super.key, required this.patientId});

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  Map<String, dynamic>? patientDetails;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    final response = await http.get(Uri.parse('http://<ec2-instance-ip>:3000/patients/${widget.patientId}'));
    if (response.statusCode == 200) {
      setState(() {
        patientDetails = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load patient details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (patientDetails == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(patientDetails!['name']),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient ID: ${patientDetails!['patientId']}", style: const TextStyle(fontSize: 16)),
            Text("Age: ${patientDetails!['age']}", style: const TextStyle(fontSize: 16)),
            Text("Address: ${patientDetails!['address']}", style: const TextStyle(fontSize: 16)),
            Text("Phone: ${patientDetails!['phone']}", style: const TextStyle(fontSize: 16)),
            Text("Email: ${patientDetails!['email']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            if (patientDetails!['assessments'] != null) ...[
              const Text("Assessments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...patientDetails!['assessments'].map<Widget>((assessment) {
                return ListTile(
                  title: Text("MAS Level: ${assessment['masLevel']}"),
                  subtitle: Text("Date: ${assessment['date']}"),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
