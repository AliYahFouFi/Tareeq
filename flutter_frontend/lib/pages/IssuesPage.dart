import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/BusModel.dart';
import 'package:flutter_frontend/models/ReportModel.dart';
import 'package:flutter_frontend/pages/BusListScreen.dart';
import 'package:flutter_frontend/Db/database_helper.dart';
import 'package:flutter_frontend/pages/ReportFormScreen.dart';

class IssuesPage extends StatefulWidget {
  @override
  _IssuesPageState createState() => _IssuesPageState();
}

class _IssuesPageState extends State<IssuesPage> {
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() async {
    final db = await BusDatabase.database;
    final results = await db.rawQuery('''
      SELECT reports.*, buses.name AS busName
      FROM reports
      JOIN buses ON reports.bus_id = buses.id
    ''');
    setState(() {
      _reports = results;
    });
  }

  void _deleteReport(int id) async {
    final db = await BusDatabase.database;
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
    _loadReports();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report deleted'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _editReport(Map<String, dynamic> report) async {
    final bus = Bus(id: report['bus_id'], name: report['busName']);
    final existingReport = Report(
      id: report['id'],
      busId: report['bus_Id'],
      issueType: report['issue_type'],
      description: report['description'],
      imagePath: report['image_path'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ReportFormScreen(bus: bus, existingReport: existingReport),
      ),
    ).then((_) => _loadReports());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Issue'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child:
                  _reports.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.report_problem,
                              size: 100,
                              color: Colors.redAccent,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No issues reported yet.',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(report['issue_type']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bus: ${report['busName']}'),
                                  Text(report['description']),
                                  if (report['image_path'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.file(
                                        File(report['image_path']),
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // TextButton.icon(
                                      //   icon: Icon(Icons.edit, color: Colors.blue),
                                      //   label: Text('Edit'),
                                      //   onPressed: () => _editReport(report),
                                      // ),
                                      TextButton.icon(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        label: Text('Remove'),
                                        onPressed:
                                            () => _deleteReport(report['id']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('Report a Problem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                textStyle: TextStyle(fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusListScreen()),
                ).then((_) => _loadReports()); // Refresh when returning
              },
            ),
          ],
        ),
      ),
    );
  }
}
