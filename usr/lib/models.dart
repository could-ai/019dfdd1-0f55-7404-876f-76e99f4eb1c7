import 'package:flutter/foundation.dart';

class Mother {
  final String id;
  final String name;
  final String phone;
  final DateTime edd; // Estimated Delivery Date
  final String location;

  Mother({
    required this.id,
    required this.name,
    required this.phone,
    required this.edd,
    required this.location,
  });
}

class Child {
  final String id;
  final String motherId;
  final DateTime dob; // Date of Birth
  final String sex;

  Child({
    required this.id,
    required this.motherId,
    required this.dob,
    required this.sex,
  });
}

class Visit {
  final String id;
  final String patientId; // Can be motherId or childId
  final String type; // e.g., 'ANC', 'Postnatal', 'Child'
  final DateTime date;
  final String notes;

  Visit({
    required this.id,
    required this.patientId,
    required this.type,
    required this.date,
    required this.notes,
  });
}

class Schedule {
  final String id;
  final String patientId;
  final DateTime dueDate;
  final String type; // e.g., 'ANC1', 'BCG Vaccine'
  bool completed;

  Schedule({
    required this.id,
    required this.patientId,
    required this.dueDate,
    required this.type,
    this.completed = false,
  });
}
