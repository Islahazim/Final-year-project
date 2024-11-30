import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedGender;
  String? name, email, phone, address, patientId, patientIssues;
  int? age;
  bool isLoading = false;

  // Function to submit patient data to the server
  Future<void> submitPatientData() async {
    const url = 'http://ec2-18-139-163-163.ap-southeast-1.compute.amazonaws.com:3000/addPatient'; // Replace with your EC2 server URL

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'patientId': patientId, // Include patientId in the request
          'name': name,
          'age': age,
          'email': email,
          'phoneNumber': phone,
          'address': address,
          'gender': selectedGender,
          'patientIssues': patientIssues,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient added successfully. ID: ${responseData['patientId']}')),
        );
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${errorData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build the form with validation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show spinner while loading
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Patient ID', isMandatory: true), // Add Patient ID field
              _buildTextField('Name', isMandatory: true),
              _buildTextField(
                'Age',
                keyboardType: TextInputType.number,
                isMandatory: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              _buildTextField('Email', keyboardType: TextInputType.emailAddress, isMandatory: true),
              _buildTextField('Phone Number', keyboardType: TextInputType.phone, isMandatory: true),
              _buildTextField('Address', isMandatory: true),
              Row(
                children: [
                  const Text('Gender: '),
                  Radio<String>(
                    value: 'Male',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const Text('Male'),
                  Radio<String>(
                    value: 'Female',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const Text('Female'),
                ],
              ),
              _buildTextField('Patient Issues', maxLines: 4, isMandatory: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    submitPatientData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field widget to simplify form fields
  Widget _buildTextField(
      String label, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        bool isMandatory = false,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator ??
            (isMandatory
                ? (value) => value?.isEmpty ?? true ? 'Please enter $label' : null
                : null),
        onSaved: (value) {
          if (label == 'Patient ID') patientId = value;
          if (label == 'Name') name = value;
          if (label == 'Email') email = value;
          if (label == 'Phone Number') phone = value;
          if (label == 'Address') address = value;
          if (label == 'Patient Issues') patientIssues = value;
          if (label == 'Age') age = int.tryParse(value ?? '');
        },
      ),
    );
  }
}
