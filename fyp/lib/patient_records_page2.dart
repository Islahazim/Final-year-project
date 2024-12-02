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
  List<Map<String, dynamic>> filteredRecords = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedGender = 'All';

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
          filteredRecords = List.from(patientRecords);
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

  void _filterRecords() {
    setState(() {
      filteredRecords = patientRecords.where((record) {
        final matchesQuery = record['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()) ||
            record['id'].toString().contains(searchQuery);
        final matchesGender = selectedGender == 'All' ||
            record['gender'].toString().toLowerCase() == selectedGender.toLowerCase();
        return matchesQuery && matchesGender;
      }).toList();
    });
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
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        _filterRecords();
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search by name or ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Bar
                  DropdownButton<String>(
                    value: selectedGender,
                    items: ['All', 'Male', 'Female']
                        .map(
                          (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                        _filterRecords();
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    underline: Container(),
                  ),
                ],
              ),
            ),
            // Patient Records List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredRecords.isEmpty
                  ? const Center(child: Text("No patient records found."))
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredRecords.length,
                itemBuilder: (context, index) {
                  final patient = filteredRecords[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        patient['name'] ?? 'Unknown',
                        style: GoogleFonts.monomaniacOne(color: Colors.black),
                      ),
                      subtitle: Text(
                          "ID: ${patient['id']} • Age: ${patient['age']} • Gender: ${patient['gender']}"),
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
          ],
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
