import 'package:flutter/material.dart';

class VisualTimetablePage extends StatefulWidget {
  @override
  _VisualTimetablePageState createState() => _VisualTimetablePageState();
}

class _VisualTimetablePageState extends State<VisualTimetablePage> {
  String? _selectedRoute;

  final List<String> _routes = ["Route A", "Route B"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Timetable (Sample)'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed:
                () => showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: Text("Sample Data"),
                        content: Text("This shows mock timetable visuals only"),
                      ),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route selector
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Select route..."),
                          value: _selectedRoute,
                          items:
                              _routes.map((route) {
                                return DropdownMenuItem<String>(
                                  value: route,
                                  child: Text(route),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedRoute = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Frequency summary
            _buildScheduleCard(
              icon: Icons.access_time,
              title: "Typical Frequency",
              content: "Weekdays: Every 15-20 mins\nWeekends: Every 30 mins",
            ),

            SizedBox(height: 20),

            // Visual stop list
            Text("Sample Stops", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            ...List.generate(3, (i) => _buildStopCard(i + 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(int stopNumber) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('$stopNumber')),
                SizedBox(width: 16),
                Text(
                  "Stop $stopNumber",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTimeChip("7:00 AM"),
                _buildTimeChip("7:20 AM"),
                _buildTimeChip("7:40 AM"),
                _buildTimeChip("8:00 AM"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    return Chip(
      label: Text(time),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(color: Colors.black87),
    );
  }
}
