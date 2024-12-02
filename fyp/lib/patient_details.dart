import 'package:flutter/material.dart';
import 'start_assessment2.dart'; // Import the updated StartAssessmentPage
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientID;
  final String name;
  final int age;
  final String gender;
  final String phoneNum;
  final String email;
  final int ml;

  const PatientDetailsPage({
    super.key,
    required this.patientID,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNum,
    required this.email,
    required this.ml,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey, // Background color (beige shade)
      appBar: AppBar(
        backgroundColor: const Color(0xFF00274D), // App bar background
        title: Text("Patient: $name", style: GoogleFonts.monomaniacOne(color: Colors.white)),
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
            // Patient Basic Information
            SizedBox(
              width: double.infinity,
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
                    Text("Name: $name", style: GoogleFonts.monomaniacOne(fontSize: 18)),
                    const SizedBox(height: 5),
                    Text("Patient ID: $patientID", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text("Age: $age", style: GoogleFonts.monomaniacOne(fontSize: 18)),
                    const SizedBox(height: 5),
                    Text("Gender: $gender", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text("Phone Number: $phoneNum", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                    const SizedBox(height: 5),
                    Text("Email: $email", style: GoogleFonts.monomaniacOne(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Graph Section
            SizedBox(
              width: double.infinity,
              child: Container(
                height: 210,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black26),
                ),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries<dynamic, dynamic>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: [
                        ChartData('17 Dec 24', ml),
                        ChartData('17 Jan 25', ml),
                        ChartData('17 Feb 25', ml),
                      ],
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      color: Colors.pink,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // MAS Level and Next Appointment Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$ml', style: GoogleFonts.monomaniacOne(fontSize: 32)),
                        Text('Current\nMAS LEVEL',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.monomaniacOne(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00274D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('17', style: GoogleFonts.monomaniacOne(color: Colors.white, fontSize: 32)),
                        Text('March 2025',
                            style: GoogleFonts.monomaniacOne(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Patient Assessment Section
            SizedBox(
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
                    // Header with Background Color
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00274D), // Aqua background for header
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
                    // Content Area - Dynamic Assessment
                    Container(
                      padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 10),
            // Start Assessment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartAssessmentPage(
                        patientId: patientID,
                        patientName: name,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00274D),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Start Assessment',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.monomaniacOne(
                    fontSize: 16,
                    color: Colors.white,
                  ),
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
