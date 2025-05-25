class Bus {
  final int id;
  final String name;

  Bus({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Bus.fromMap(Map<String, dynamic> map) {
    return Bus(id: map['id'], name: map['name']);
  }
}
