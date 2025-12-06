import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'recording_page.dart';
import 'appointments_page.dart';

/// Home page - Main entry point of the app
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EMA',
          style: TextStyle(
            fontSize: AppConstants.defaultFontSize + 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Welcome message
              const Text(
                'Welcome to EMA',
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize + 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Elderly Medical Appointment Assistant',
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Start Recording Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RecordingPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Start Recording',
                      style: TextStyle(
                        fontSize: AppConstants.defaultFontSize + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // View Appointments Button
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'View Appointments',
                      style: TextStyle(
                        fontSize: AppConstants.defaultFontSize + 2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Help text
              const Text(
                'Tap "Start Recording" to begin recording your consultation',
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize - 2,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

