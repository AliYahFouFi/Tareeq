class Ticket {
  final String id;
  final String ticketNumber;
  // final String tripId;
  final String price;
  final String createdAt;

  Ticket({
    required this.id,
    required this.ticketNumber,
    // required this.tripId,
    required this.price,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'].toString(),
      ticketNumber: json['ticket_number'],
      // tripId: json['trip_id'],
      price: json['price'].toString(),
      createdAt: json['created_at'],
    );
  }
}
