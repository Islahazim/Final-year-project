import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'patient_records_page2.dart';
import 'profile_page.dart';

void main() {
  runApp(const QSATApp());
}

class QSATApp extends StatelessWidget {
  const QSATApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Update with your primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const QSATHomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        // '/patientRecords': (context) => const PatientRecordsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class QSATHomePage extends StatefulWidget {
  const QSATHomePage({super.key});

  @override
  QSATHomePageState createState() => QSATHomePageState();
}

class QSATHomePageState extends State<QSATHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
     const PatientRecordsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Patient Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
