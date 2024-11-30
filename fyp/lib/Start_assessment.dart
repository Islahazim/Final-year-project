import 'package:flutter/material.dart';

class StartAssessmentPage extends StatelessWidget {
  const StartAssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QSAT", style: TextStyle(fontSize: 24)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _EMGDataChart(),
            const SizedBox(height: 16),
            _NewMasLevelBox(),
            const SizedBox(height: 16),
            _PlayStopControls(),
            const SizedBox(height: 16),
            _MasLevelDisplay(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text(
            "UPDATE",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// EMG Data Chart Widget
class _EMGDataChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          "Real-Time EMG Data Processing Chart",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

// New MAS Level Box Widget
class _NewMasLevelBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("NEW MAS LEVEL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("READY", style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}

// Play and Stop Control Widget
class _PlayStopControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.green, size: 40),
          onPressed: () {
            // Add play functionality here
          },
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.stop, color: Colors.red, size: 40),
          onPressed: () {
            // Add stop functionality here
          },
        ),
      ],
    );
  }
}

// MAS Level Display Widget
class _MasLevelDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("MAS LEVEL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("0", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          Text("Status: Stable", style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
