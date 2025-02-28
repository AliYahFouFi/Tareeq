import 'package:flutter/material.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({super.key});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Sheet Example')),
      body: Stack(
        children: [
          // Your main screen content
          const Center(child: Text('Main Screen Content')),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.15, // Initial height (15% of screen)
            minChildSize: 0.15, // Minimum height when collapsed
            maxChildSize: 0.7, // Maximum height when expanded
            snap: true,
            snapSizes: const [0.15, 0.5, 0.7],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    // Scrollable content area
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Bus Route Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Downtown Beirut Route'),
                          const Text('Estimated Arrival: 5 mins'),
                          const SizedBox(height: 24),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Save Route'),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Share'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Add Note',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
