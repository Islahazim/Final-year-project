import 'dart:convert';
import 'package:flutter/material.dart';
import 'start_assessment2.dart'; // Import the updated StartAssessmentPage
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class PatientDetailsPage extends StatefulWidget {
  final String patientID;
  final String name;
  final int age;
  final String gender;
  final String phoneNum;
  final String email;
  final String appointment;

  const PatientDetailsPage({
    super.key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNum,
    required this.email,
    required this.appointment,
  });

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late String appointment;
  List<ChartData> masLevelData = [];
  int currentMasLevel = 0;

  @override
  void initState() {
    super.initState();
    appointment = widget.appointment;
    fetchMasLevels();
  }

  Future<void> fetchMasLevels() async {
    const String apiUrl =
        'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/get-maslevels';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"patientId": widget.patientID}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          masLevelData = data
              .map((entry) => ChartData(entry['date'], entry['level']))
              .toList();
          if (masLevelData.isNotEmpty) {
            currentMasLevel = masLevelData.last.y;
          }
        });
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error fetching MAS levels: $e");
    }
  }

  Future<void> updateAppointmentDate(String date) async {
    const String apiUrl =
        'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/save-appointment';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"patientId": widget.patientID, "appointmentDate": date}),
      );

      if (response.statusCode == 200) {
        setState(() {
          appointment = date;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment date saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save appointment date.')),
        );
      }
    } catch (e) {
      print("Error saving appointment: $e");
    }
  }

  String getPatientAssessment() {
    switch (currentMasLevel) {
      case 0:
        return "No increased tone";
      case 1:
        return "Slight increase in tone, with a catch and minimal resistance";
      case 2:
        return "More marked increase in tone, but the limb can be flexed easily";
      case 3:
        return "Considerable increase in tone, making passive movement difficult";
      case 4:
        return "Limb is rigid in flexion or extension";
      default:
        return "Unknown condition. Please review the input data.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00274D),
        title: Text("Patient: ${widget.name}",
            style: GoogleFonts.monomaniacOne(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Patient Info and Set Appointment
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${widget.name}",
                            style: GoogleFonts.monomaniacOne(fontSize: 18)),
                        Text("Patient ID: ${widget.patientID}",
                            style: GoogleFonts.monomaniacOne(fontSize: 16)),
                        Text("Age: ${widget.age}",
                            style: GoogleFonts.monomaniacOne(fontSize: 18)),
                        Text("Gender: ${widget.gender}",
                            style: GoogleFonts.monomaniacOne(fontSize: 16)),
                        Text("Phone Number: ${widget.phoneNum}",
                            style: GoogleFonts.monomaniacOne(fontSize: 16)),
                        Text("Email: ${widget.email}",
                            style: GoogleFonts.monomaniacOne(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Start New Assessment Button inside Container
                      Container(
                        height: 65, // Adjust height as needed
                        width: double.infinity, // Adjust width as needed
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StartAssessmentPage(
                                  patientId: widget.patientID,
                                  patientName: widget.name,
                                ),
                              ),
                            ).then((_) {
                              fetchMasLevels(); // Refresh the list after returning from PatientDetailsPage
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00274D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Start New Assessment',
                            style: GoogleFonts.monomaniacOne(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Set Appointment Container
                      GestureDetector(
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (selectedDate != null) {
                            String formattedDate =
                                "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                            await updateAppointmentDate(formattedDate);
                          }
                        },
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF004D79),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white, size: 40),
                              const SizedBox(height: 5),
                              Text(
                                "Set Appointment",
                                style: GoogleFonts.monomaniacOne(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // MAS Chart and Boxes
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 210,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SfCartesianChart(
                      title: ChartTitle(text: 'MAS Level Progress'),
                      primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Date')),
                      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Level')),
                      series: <CartesianSeries>[
                        LineSeries<ChartData, String>(
                          dataSource: masLevelData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004D79),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text("Next Appointment: $appointment",
                              style: GoogleFonts.monomaniacOne(
                                  fontSize: 24, color: Colors.white)),
                        ),
                      ),
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text("Current MAS Level: $currentMasLevel",
                              style: GoogleFonts.monomaniacOne(fontSize: 24)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
              child: Column(
                children: [
                  // Label Box
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00274D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Patient Assessment",
                        style: GoogleFonts.monomaniacOne(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Inner Content Box
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        getPatientAssessment(),
                        style: GoogleFonts.monomaniacOne(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

class ChartData {
  final String x;
  final int y;
  ChartData(this.x, this.y);
}
