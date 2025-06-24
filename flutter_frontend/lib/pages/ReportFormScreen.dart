import 'package:flutter/material.dart';
import 'package:flutter_frontend/db/database_helper.dart';
import 'package:flutter_frontend/models/ReportModel.dart';
import 'package:flutter_frontend/pages/IssuesPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_frontend/models/BusModel.dart';

class ReportFormScreen extends StatefulWidget {
  final Bus bus;
  final Report? existingReport;

  ReportFormScreen({required this.bus, this.existingReport});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIssueType;
  String _description = '';
  File? _image;

  final List<String> _issueTypes = [
    'Broken Bench',
    'Missing Sign',
    'No Shade',
    'Trash Overflow',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      _selectedIssueType = widget.existingReport!.issueType;
      _description = widget.existingReport!.description;
      if (widget.existingReport!.imagePath != null) {
        _image = File(widget.existingReport!.imagePath!);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open camera: $e')));
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedIssueType != null) {
      _formKey.currentState!.save();

      Report report = Report(
        id: widget.existingReport?.id,
        busId: widget.bus.id!,
        issueType: _selectedIssueType!,
        description: _description,
        imagePath: _image?.path,
      );

      if (widget.existingReport == null) {
        await BusDatabase.insertReport(report);
      } else {
        await BusDatabase.updateReport(report);
      }

      await BusDatabase.syncReportToLaravel(report);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            widget.existingReport == null
                ? 'Report submitted for ${widget.bus.name}!'
                : 'Report updated for ${widget.bus.name}!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IssuesPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please complete the form')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ).copyWith(secondary: Colors.redAccent),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingReport == null ? 'New Report' : 'Edit Report',
          ),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Issue Type',
                          labelStyle: TextStyle(color: Colors.redAccent),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                        ),
                        value: _selectedIssueType,
                        items:
                            _issueTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedIssueType = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select an issue type'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.redAccent),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.redAccent),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter a description'
                                    : null,
                        onSaved: (value) {
                          _description = value!;
                        },
                      ),
                      SizedBox(height: 16),
                      if (_image != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, height: 150),
                        ),
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Remove Photo',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ] else
                        Text('No image selected', textAlign: TextAlign.center),
                      TextButton.icon(
                        icon: Icon(Icons.camera_alt, color: Colors.redAccent),
                        label: Text(
                          'Take Photo',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
