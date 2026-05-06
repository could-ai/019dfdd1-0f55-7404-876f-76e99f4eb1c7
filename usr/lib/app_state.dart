import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();

  final List<Mother> _mothers = [];
  final List<Child> _children = [];
  final List<Visit> _visits = [];
  final List<Schedule> _schedules = [];

  List<Mother> get mothers => _mothers;
  List<Child> get children => _children;
  List<Visit> get visits => _visits;
  List<Schedule> get schedules => _schedules;

  // Reminders/Dashboard logic
  List<Schedule> get upcomingSchedules {
    final now = DateTime.now();
    return _schedules
        .where((s) => !s.completed && s.dueDate.isAfter(now))
        .toList();
  }

  List<Schedule> get missedSchedules {
    final now = DateTime.now();
    return _schedules
        .where((s) => !s.completed && s.dueDate.isBefore(now))
        .toList();
  }

  void addMother(String name, String phone, DateTime edd, String location) {
    final motherId = _uuid.v4();
    final mother = Mother(
      id: motherId,
      name: name,
      phone: phone,
      edd: edd,
      location: location,
    );
    _mothers.add(mother);
    
    // Auto-schedule ANC visits based on EDD
    // Simple logic: ANC1 (12 weeks before EDD), ANC2 (8 weeks), ANC3 (4 weeks)
    _schedules.add(Schedule(id: _uuid.v4(), patientId: motherId, dueDate: edd.subtract(const Duration(days: 84)), type: 'ANC1'));
    _schedules.add(Schedule(id: _uuid.v4(), patientId: motherId, dueDate: edd.subtract(const Duration(days: 56)), type: 'ANC2'));
    _schedules.add(Schedule(id: _uuid.v4(), patientId: motherId, dueDate: edd.subtract(const Duration(days: 28)), type: 'ANC3'));

    notifyListeners();
  }

  void addChild(String motherId, DateTime dob, String sex) {
    final childId = _uuid.v4();
    final child = Child(
      id: childId,
      motherId: motherId,
      dob: dob,
      sex: sex,
    );
    _children.add(child);

    // Auto-schedule basic vaccines
    _schedules.add(Schedule(id: _uuid.v4(), patientId: childId, dueDate: dob, type: 'BCG / OPV0'));
    _schedules.add(Schedule(id: _uuid.v4(), patientId: childId, dueDate: dob.add(const Duration(days: 42)), type: 'Penta1 / OPV1'));
    _schedules.add(Schedule(id: _uuid.v4(), patientId: childId, dueDate: dob.add(const Duration(days: 270)), type: 'Measles'));

    notifyListeners();
  }

  void addVisit(String patientId, String type, DateTime date, String notes) {
    final visitId = _uuid.v4();
    _visits.add(Visit(
      id: visitId,
      patientId: patientId,
      type: type,
      date: date,
      notes: notes,
    ));
    notifyListeners();
  }

  void completeSchedule(String scheduleId) {
    final index = _schedules.indexWhere((s) => s.id == scheduleId);
    if (index != -1) {
      _schedules[index].completed = true;
      notifyListeners();
    }
  }

  // Pre-fill some demo data
  void loadDemoData() {
    if (_mothers.isNotEmpty) return;
    final now = DateTime.now();
    addMother('Jane Doe', '555-0101', now.add(const Duration(days: 60)), 'Village A');
    addMother('Alice Smith', '555-0102', now.add(const Duration(days: 15)), 'Village B');
    
    // Create a missed schedule for demo purposes
    final motherId = _mothers.first.id;
    _schedules.add(Schedule(id: _uuid.v4(), patientId: motherId, dueDate: now.subtract(const Duration(days: 5)), type: 'ANC0'));
  }
}
