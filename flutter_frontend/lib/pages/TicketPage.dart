// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_frontend/models/Ticket_model.dart';
import 'package:flutter_frontend/services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show Stripe;
import 'package:pretty_qr_code/pretty_qr_code.dart';

class TicketPage extends StatefulWidget {
  final String userId;

  TicketPage({required this.userId});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey =
        'pk_test_51R8N58RqkFEca6vdKc4r0whD5noHO5XrwLCf3KMOQTCFGmKGc3eoJx39Iu9l4242hGR7Z894uCIZHRT5MjgjBYzU00vegOu5nb';
  }

  void _showFullScreenQr(BuildContext context, String ticketNumber) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PrettyQr(
                    size: MediaQuery.of(context).size.width * 0.7,
                    data: ticketNumber,
                    errorCorrectLevel: QrErrorCorrectLevel.H,
                    typeNumber: 4,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Tickets",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                bool success = await PaymentService.instance.makePayment();
                if (success) {
                  setState(() {}); // re-trigger build and refresh FutureBuilder
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment failed. Please try again.'),
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Buy Ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Ticket>>(
              future: PaymentService.instance.fetchTickets(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tickets found.'));
                } else {
                  List<Ticket> tickets = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      final createdAt =
                          ticket.createdAt != null
                              ? DateTime.parse(
                                ticket.createdAt!,
                              ).toLocal().toString()
                              : 'Unknown date';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ticket #${ticket.ticketNumber}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Created at: $createdAt',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    OutlinedButton(
                                      onPressed: () {
                                        PaymentService.instance.deleteTicket(
                                          ticket.id!,
                                        );
                                        setState(() {});
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: BorderSide(color: Colors.red),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text('Remove Ticket'),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => _showFullScreenQr(
                                      context,
                                      ticket.ticketNumber,
                                    ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: PrettyQr(
                                        size: 80,
                                        data: ticket.ticketNumber,
                                        errorCorrectLevel:
                                            QrErrorCorrectLevel.H,
                                        typeNumber: 4,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Tap to enlarge",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
