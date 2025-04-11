import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/login.dart';
import 'package:flutter_frontend/pages/TicketPage.dart';
import 'package:flutter_frontend/providers/AuthProvider.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late BusRouteProvider busRouteProvider;
  late BusStopsProvider busStopsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Save a reference to the provider
    busRouteProvider = Provider.of<BusRouteProvider>(context, listen: false);
    busStopsProvider = Provider.of<BusStopsProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            accountName: Text('John Doe'),
            accountEmail: Text('johndoe@email.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
            ),
          ),
          ListTile(
            leading: Icon(Icons.directions_bus),
            title: Text('Bus Routes'),
            onTap: () async {
              Navigator.pop(context);
              busRouteProvider.polylines = await initializeAllPolylines();
              busStopsProvider.loadAllBusStops();
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Timetable'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/timetable');
            },
          ),

          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(); // or a shimmer/loading if you prefer
              }

              bool isLoggedIn = snapshot.data!.getString('token') != null;

              if (!isLoggedIn) {
                return SizedBox(); // Hide the ListTile completely if not logged in
              }

              return ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('Buy Tickets'),
                onTap: () {
                  SharedPreferences prefs = snapshot.data!;
                  String? userId = prefs.getString('id');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketPage(userId: userId!),
                    ),
                  );
                },
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Saved Routes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/saved_routes');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/AboutUs');
            },
          ),
          Divider(),
          ListTile(
            leading: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Icon(
                    Icons.hourglass_empty,
                  ); // Placeholder icon while loading
                }

                bool isLoggedIn = snapshot.data!.getString('token') != null;

                return Icon(
                  isLoggedIn ? Icons.logout : Icons.login,
                  color:
                      isLoggedIn
                          ? Colors.red
                          : Colors.green, // Red for logout, green for login
                );
              },
            ),
            title: FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Loading...');
                }

                bool isLoggedIn = snapshot.data!.getString('token') != null;

                return Text(isLoggedIn ? 'Logout' : 'Login');
              },
            ),
            onTap: () async {
              Navigator.pop(context);
              bool isLoggedIn = context.read<AuthProvider>().isLoggedIn;

              if (isLoggedIn) {
                context.read<AuthProvider>().logout(context);
              } else {
                // Navigate to Login Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
