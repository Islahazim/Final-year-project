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
  final int ml;
  final String appointment;

  const PatientDetailsPage({
    super.key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNum,
    required this.email,
    required this.ml,
    required this.appointment,
  });

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  late int ml;
  late String appointment;

  @override
  void initState() {
    super.initState();
    ml = widget.ml;
    appointment = widget.appointment;
  }

  Future<bool> saveAppointmentDate(String patientId, String date) async {
    const apiUrl = 'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/save-appointment';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patientId": patientId,
          "appointmentDate": date,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Successfully saved
      } else {
        print("Error: ${response.body}");
        return false; // Failed to save
      }
    } catch (e) {
      print("Error saving appointment: $e");
      return false;
    }
  }

  Future<void> updateAppointmentDate(String date) async {
    bool success = await saveAppointmentDate(widget.patientID, date);
    if (success) {
      setState(() {
        appointment = date; // Update the state to reflect the new appointment
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment date saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save appointment date.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00274D),
        title: Text("Patient: ${widget.name}", style: GoogleFonts.monomaniacOne(color: Colors.white)),
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
            // Basic Info and Buttons
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${widget.name}", style: GoogleFonts.monomaniacOne(fontSize: 18)),
                        Text("Patient ID: ${widget.patientID}", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                        Text("Age: ${widget.age}", style: GoogleFonts.monomaniacOne(fontSize: 18)),
                        Text("Gender: ${widget.gender}", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                        Text("Phone Number: ${widget.phoneNum}", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                        Text("Email: ${widget.email}", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 55, // Match the height of the Select Appointment box
                        width: double.infinity, // Match the width of the Select Appointment box
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
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00274D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Start New Assessment',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.monomaniacOne(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF004D79),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                              const SizedBox(height: 5),
                              Text(
                                'Select Appointment',
                                style: GoogleFonts.monomaniacOne(color: Colors.white, fontSize: 14),
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
            // MAS Chart and Metrics
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 210,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: SfCartesianChart(
                      title: ChartTitle(
                        text: 'MAS Level Progress',
                        textStyle: GoogleFonts.monomaniacOne(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        title: const AxisTitle(text: 'Date', textStyle: TextStyle(fontSize: 16)),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        title: const AxisTitle(text: 'MAS Level', textStyle: TextStyle(fontSize: 16)),
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<ChartData, String>(
                          dataSource: [
                            ChartData('17 Dec 24', ml),
                            ChartData('17 Jan 25', ml),
                            ChartData('17 Feb 25', ml),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          color: Colors.pink,
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
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$ml', style: GoogleFonts.monomaniacOne(fontSize: 32)),
                            Text(
                              'Current\nMAS LEVEL',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.monomaniacOne(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00274D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(appointment, style: GoogleFonts.monomaniacOne(color: Colors.white, fontSize: 32)),
                            Text('Next Appointment', style: GoogleFonts.monomaniacOne(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Patient Assessment Box
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.black26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00274D),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Patient Assessment:",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.monomaniacOne(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Builder(
                        builder: (context) {
                          switch (ml) {
                            case 0:
                              return Text(
                                "Critical condition. Emergency intervention needed.",
                                style: GoogleFonts.monomaniacOne(fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              );
                            case 1:
                              return Text(
                                "Severe concerns detected. Immediate action required.",
                                style: GoogleFonts.monomaniacOne(fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              );
                            case 2:
                              return Text(
                                "Moderate issues present. Recommend scheduling a follow-up.",
                                style: GoogleFonts.monomaniacOne(fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              );
                            case 3:
                              return Text(
                                "Minor irregularities observed. Monitor progress closely.",
                                style: GoogleFonts.monomaniacOne(fontSize: 16, color: Colors.red),
                                textAlign: TextAlign.center,
                              );
                            case 4:
                              return Text(
                                "No issues detected. Patient is in excellent condition.",
                                style: GoogleFonts.monomaniacOne(fontSize: 16, color: Colors.red),
                                textAlign: TextAlign.center,
                              );
                            default:
                              return Text(
                                "Unknown case: Please check the input data.",
                                style: GoogleFonts.monomaniacOne(fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.center,
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
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
