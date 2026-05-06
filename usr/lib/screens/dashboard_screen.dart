import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCH Follow-up Dashboard'),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          final mothers = state.mothers;
          final today = DateTime.now();
          final startOfToday = DateTime(today.year, today.month, today.day);
          final missedSchedules = state.schedules.where((s) => 
            !s.completed && s.dueDate.isBefore(startOfToday)
          ).toList();
          final upcomingSchedules = state.schedules.where((s) => 
            !s.completed && (s.dueDate.isAtSameMomentAs(startOfToday) || s.dueDate.isAfter(startOfToday)) &&
            s.dueDate.isBefore(startOfToday.add(const Duration(days: 7)))
          ).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWide)
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard(context, 'Total Mothers', mothers.length.toString(), Colors.blue)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMetricCard(context, 'Missed Visits', missedSchedules.length.toString(), Colors.red)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMetricCard(context, 'Upcoming (7 Days)', upcomingSchedules.length.toString(), Colors.orange)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildMetricCard(context, 'Total Mothers', mothers.length.toString(), Colors.blue),
                          const SizedBox(height: 16),
                          _buildMetricCard(context, 'Missed Visits', missedSchedules.length.toString(), Colors.red),
                          const SizedBox(height: 16),
                          _buildMetricCard(context, 'Upcoming (7 Days)', upcomingSchedules.length.toString(), Colors.orange),
                        ],
                      ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Registered Mothers', style: Theme.of(context).textTheme.titleLarge),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Register Mother'),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (mothers.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No mothers registered yet.'),
                      ))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mothers.length,
                        itemBuilder: (context, index) {
                          final mother = mothers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(mother.name),
                              subtitle: Text('EDD: ${mother.edd.toLocal().toString().split(' ')[0]}\nLocation: ${mother.location}'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(context, '/patient_detail', arguments: mother.id);
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
