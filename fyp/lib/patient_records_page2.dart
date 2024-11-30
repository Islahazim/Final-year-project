import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_patient_screen.dart';
import 'patient_details.dart'; // Import the PatientDetailsPage
import 'package:google_fonts/google_fonts.dart';

class PatientRecordsPage extends StatefulWidget {
  const PatientRecordsPage({super.key});

  @override
  _PatientRecordsPageState createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  List<Map<String, dynamic>> patientRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientRecords();
  }

  Future<void> _fetchPatientRecords() async {
    const apiUrl = 'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/patients';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          patientRecords = List<Map<String, dynamic>>.from(data.map((item) {
            return {
              'name': item['name'] ?? 'Unknown',
              'age': item['age'] ?? 'N/A',
              'id': item['patientId'] ?? 'N/A',
              'gender': item['gender'] ?? 'N/A',
              'phoneNum': item['phoneNumber'] ?? 'N/A',
              'email': item['email'] ?? 'N/A',
              'ml': item['Mas Level'] ?? 'N/A',
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
        backgroundColor: Colors.white10,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // 0% - white
              Color(0xFF82FFE8), // 100% - light green
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : patientRecords.isEmpty
            ? const Center(child: Text("No patient records found."))
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: patientRecords.length,
          itemBuilder: (context, index) {
            final patient = patientRecords[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(patient['name'] ?? 'Unknown', style: GoogleFonts.monomaniacOne(color: Colors.black)),
                subtitle: Text("ID: ${patient['id']} • Age: ${patient['age']} • Gender: ${patient['gender']}"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to PatientDetailsPage with patient details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailsPage(
                        patientID: patient['id'],
                        name: patient['name'],
                        age: patient['age'],
                        gender: patient['gender'],
                        phoneNum: patient['phoneNum'],
                        email: patient['email'],
                        ml: patient['ml'],

                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
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
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
