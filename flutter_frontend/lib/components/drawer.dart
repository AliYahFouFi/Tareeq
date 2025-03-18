import 'package:flutter/material.dart';
import 'package:flutter_frontend/providers/BusRouteProvider.dart';
import 'package:flutter_frontend/providers/BusStopsProvider.dart';
import 'package:flutter_frontend/util/polyline_util.dart';
import 'package:provider/provider.dart';

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
              // ✅ Use the saved reference instead of context.read()
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
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Buy Tickets'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/buy_tickets');
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
              Navigator.pushNamed(context, '/about');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Add logout functionality
            },
          ),
        ],
      ),
    );
  }
}
