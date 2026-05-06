import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class PatientDetailScreen extends StatelessWidget {
  final String motherId;

  const PatientDetailScreen({super.key, required this.motherId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final mother = state.getMother(motherId);
        if (mother == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Patient Not Found')),
            body: const Center(child: Text('This patient does not exist.')),
          );
        }

        final children = state.getChildrenForMother(motherId);
        final visits = state.getVisitsForPatient(motherId);
        final schedules = state.getSchedulesForPatient(motherId);

        return Scaffold(
          appBar: AppBar(
            title: Text(mother.name),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildMotherInfo(context, mother),
              const SizedBox(height: 16),
              _buildChildrenSection(context, children),
              const SizedBox(height: 16),
              _buildSchedulesSection(context, state, schedules),
              const SizedBox(height: 16),
              _buildVisitsSection(context, state, motherId, visits),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMotherInfo(BuildContext context, Mother mother) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mother Information', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            Text('Name: ${mother.name}'),
            Text('Phone: ${mother.phone}'),
            Text('Location: ${mother.location}'),
            Text('EDD: ${mother.edd.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenSection(BuildContext context, List<Child> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Children', style: Theme.of(context).textTheme.titleLarge),
                // Add child button could go here
              ],
            ),
            const Divider(),
            if (children.isEmpty)
              const Text('No children registered.')
            else
              ...children.map((child) => ListTile(
                    title: Text('Child ID: ${child.id.substring(0, 8)}'),
                    subtitle: Text('DOB: ${child.dateOfBirth.toLocal().toString().split(' ')[0]} | Sex: ${child.sex}'),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesSection(BuildContext context, AppState state, List<Schedule> schedules) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Schedule', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            if (schedules.isEmpty)
              const Text('No upcoming schedules.')
            else
              ...schedules.map((schedule) => ListTile(
                    title: Text('${schedule.type} - Due: ${schedule.dueDate.toLocal().toString().split(' ')[0]}'),
                    trailing: Checkbox(
                      value: schedule.completed,
                      onChanged: (val) {
                        state.markScheduleCompleted(schedule.id, val ?? false);
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitsSection(BuildContext context, AppState state, String patientId, List<Visit> visits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Visits', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => _showAddVisitDialog(context, state, patientId),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Visit'),
                )
              ],
            ),
            const Divider(),
            if (visits.isEmpty)
              const Text('No visits recorded.')
            else
              ...visits.map((visit) => ListTile(
                    title: Text('${visit.type} - ${visit.date.toLocal().toString().split(' ')[0]}'),
                    subtitle: Text(visit.notes.isEmpty ? 'No notes' : visit.notes),
                  )),
          ],
        ),
      ),
    );
  }

  void _showAddVisitDialog(BuildContext context, AppState state, String patientId) {
    final notesController = TextEditingController();
    String type = 'ANC';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Visit'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ['ANC', 'Postnatal', 'Child']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => type = val!);
                    },
                    decoration: const InputDecoration(labelText: 'Visit Type'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.addVisit(
                      patientId: patientId,
                      type: type,
                      date: DateTime.now(),
                      notes: notesController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
