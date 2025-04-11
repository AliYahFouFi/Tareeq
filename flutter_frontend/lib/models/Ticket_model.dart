class Ticket {
  final String ticketNumber;
  // final String tripId;
  final String price;
  final String createdAt;

  Ticket({
    required this.ticketNumber,
    // required this.tripId,
    required this.price,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketNumber: json['ticket_number'],
      // tripId: json['trip_id'],
      price: json['price'].toString(),
      createdAt: json['created_at'],
    );
  }
}
