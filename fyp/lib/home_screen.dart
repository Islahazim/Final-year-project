import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedAppointment; // To track which tab is selected (e.g., Current Appointment)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Appointment",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row of appointment tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current Appointment
                _appointmentTab(
                  label: "Current",
                  isSelected: selectedAppointment == "current",
                  onTap: () {
                    setState(() {
                      selectedAppointment = "current";
                    });
                  },
                ),
                // Next Appointment
                _appointmentTab(
                  label: "Upcoming",
                  isSelected: selectedAppointment == "next",
                  onTap: () {
                    setState(() {
                      selectedAppointment = "next";
                    });
                  },
                ),
                // Completed Appointment
                _appointmentTab(
                  label: "Completed",
                  isSelected: selectedAppointment == "last",
                  onTap: () {
                    setState(() {
                      selectedAppointment = "last";
                    });
                  },
                ),
              ],
            ),
          ),
          // Appointment details (conditionally displayed based on selection)
          if (selectedAppointment != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0), // Space around the container
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4), // Shadow below the container
                    ),
                  ],
                ),
                child: _buildAppointmentDetails(),
              ),
            ),
        ],
      ),
    );
  }

  // Widget for individual appointment tab
  Widget _appointmentTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget to display appointment details based on selection
  Widget _buildAppointmentDetails() {
    switch (selectedAppointment) {
    case "last":
    return const Text(
    "Last Appointment Details:\nDate: 18 Nov 2024\nTime: 3:00 PM\nTherapist: Dr. John Doe",
    style: TextStyle(fontSize: 16),
    );
    case "next":
    return const Text(
    "Next Appointment Details:\nDate: 22 Nov 2024\nTime: 11:00 AM\nTherapist: Dr. Jane Smith",
    style: TextStyle(fontSize: 16),
    );
    case "current":
    return const Text(
    "Current Appointment Details:\nDate: 20 Nov 2024\nTime: 1:00 PM\nTherapist: Dr. Emily Davis",
    style: TextStyle(fontSize: 16),
    );
    default:
    return const SizedBox.shrink();
    }
  }
}