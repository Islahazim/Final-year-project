import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientService {
  final String baseUrl = 'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000';

  Future<bool> addPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addPatient'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(patientData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Error adding patient: $error');
      return false;
    }
  }
}

