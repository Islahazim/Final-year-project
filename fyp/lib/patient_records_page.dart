import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_patient_screen.dart';

class PatientRecordsPage extends StatefulWidget {
  const PatientRecordsPage({super.key});

  @override
  _PatientRecordsPageState createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  List<Map<String, dynamic>> patientRecords = []; // Placeholder for patient records
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientRecords(); // Fetch data on page load
  }

  Future<void> _fetchPatientRecords() async {
    const apiUrl = 'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/patients'; // Replace with backend IP/domain

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          patientRecords = List<Map<String, dynamic>>.from(data.map((item) {
            return {
              'name': item['name'] ?? 'Unknown',
              'age': item['age'] ?? 'N/A',
              'id': item['_id'] ?? 'N/A',
            };
          }));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load patient records');
      }
    } catch (error) {
      print('Error fetching patient records: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Records"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : patientRecords.isEmpty
          ? const Center(child: Text("No patient records found.")) // Show empty message
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: patientRecords.length,
        itemBuilder: (context, index) {
          final patient = patientRecords[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(patient['name'] ?? 'Unknown'),
              subtitle: Text("ID: ${patient['id']} • Age: ${patient['age']}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Add navigation to detailed view if needed
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          ).then((_) {
            _fetchPatientRecords(); // Refresh the list after adding a patient
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
