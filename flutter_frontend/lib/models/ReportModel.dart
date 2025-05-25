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
      'busId': busId,
      'issueType': issueType,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      busId: map['busId'],
      issueType: map['issueType'],
      description: map['description'],
      imagePath: map['imagePath'],
    );
  }
}
