class Report {
  final int? id;
  final int busId;
  final String issueType;
  final String description;
  final String? imagePath;

  Report({
    this.id,
    required this.busId,
    required this.issueType,
    required this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bus_id': busId,
      'issue_type': issueType,
      'description': description,
      'image_path': imagePath,
    };
}

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      busId: map['bus_id'],
      issueType: map['issue_type'],
      description: map['description'],
      imagePath: map['image_path'],
    );
  }
}
