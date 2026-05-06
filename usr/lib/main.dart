import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/dashboard_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/patient_detail_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCH Follow-up System',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/patient_detail') {
          final motherId = settings.arguments as String?;
          if (motherId != null) {
            return MaterialPageRoute(
              builder: (context) => PatientDetailScreen(motherId: motherId),
            );
          }
        }
        return null;
      },
      routes: {
        '/': (context) => const DashboardScreen(),
        '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}
