import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_patient_screen.dart';
import 'patient_details.dart'; // Import the PatientDetailsPage
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String doctorName; // Pass doctor's name
  final String doctorID;   // Pass doctor's ID

  const ProfilePage({
    super.key,
    required this.doctorName,
    required this.doctorID,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
              'ml': item['MasLevel'] ?? 'N/A',
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
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: const Color(0xFF00274D), // Dark blue background
        appBar: AppBar(
          backgroundColor: const Color(0xFF00274D), // Match the background color
          title: Text("| QSAT Connect |", style: GoogleFonts.monomaniacOne(color: Colors.white)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Doctor Profile Section with Background Image
            Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.5, // Adjust the opacity value (0.0 to 1.0)
                    child: Image.asset(
                      "assets/QSAT.jpg", // Replace with your background image path
                      fit: BoxFit.cover, // Cover the entire section
                    ),
                  ),
                ),
                // Foreground content
                Container(
                  padding: const EdgeInsets.all(45.0), // Adjust padding
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/doctor.png"), // Doctor's profile image
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctorName, // Use passed doctorName
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${widget.doctorID}     |     Therapist", // Use passed doctorID
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            // TabBar Section
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF004D79), // Background color matching your design
                borderRadius: BorderRadius.circular(20), // Rounded edges
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), // Add some margin
              child: TabBar(
                labelColor: Colors.white, // Active tab text color
                unselectedLabelColor: Colors.grey, // Inactive tab text color
                indicator: BoxDecoration(
                  color: Colors.blueGrey, // Active tab background color
                  borderRadius: BorderRadius.circular(20), // Rounded indicator
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: "Patient"), // Adjusted to match "Patient" in your example
                  Tab(text: "Appointment"), // Adjusted to match "Appointment" in your example
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Patient List Tab
                  Column(
                    children: [
                      // Search and Filter Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Search Bar
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // White background for search bar
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    searchQuery = value;
                                    _filterRecords();
                                  },
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                                    hintText: "Search by name or ID",
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Filter Dropdown
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // White background for filter dropdown
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: DropdownButton<String>(
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
                                underline: Container(),
                                dropdownColor: Colors.white,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add Patient Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPatientScreen(),
                              ),
                            ).then((_) {
                              _fetchPatientRecords(); // Refresh the list after adding a patient
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size.fromHeight(50), // Button height
                          ),
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Add Patient",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
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
                  // Appointment Tab
                  const Center(
                    child: Text(
                      "Appointments Coming Soon",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
