// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/login.dart';
import 'package:flutter_frontend/pages/SavedPlacesPage.dart';
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
    busRouteProvider = Provider.of<BusRouteProvider>(context, listen: false);
    busStopsProvider = Provider.of<BusStopsProvider>(context, listen: false);
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: Icon(Icons.directions_bus, size: 40, color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool showBadge = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Colors.deepPurple),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      // trailing: showBadge ? _buildNotificationBadge() : null,
      onTap: onTap,
    );
  }

  // Widget _buildNotificationBadge() {
  //   return Container(
  //     padding: EdgeInsets.all(4),
  //     decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
  //     child: Text('3', style: TextStyle(color: Colors.white, fontSize: 12)),
  //   );
  // }

  Widget _buildAuthButton() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final isLoggedIn = snapshot.data!.getString('token') != null;
        final isUser = snapshot.data!.getString('role') == 'user';

        return Column(
          children: [
            Divider(height: 1),
            if (isLoggedIn && isUser) _buildUserTicketOption(snapshot.data!),
            Material(
              color: isLoggedIn ? Colors.red[50] : Colors.green[50],
              child: InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  if (isLoggedIn) {
                    context.read<AuthProvider>().logout(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isLoggedIn
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLoggedIn ? Icons.logout : Icons.login,
                          color: isLoggedIn ? Colors.red : Colors.green,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        isLoggedIn ? 'Logout' : 'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isLoggedIn ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserTicketOption(SharedPreferences prefs) {
    return _buildDrawerItem(
      icon: Icons.confirmation_number,
      title: 'My Tickets',
      onTap: () {
        String? userId = prefs.getString('id');
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketPage(userId: userId!)),
        );
      },
      iconColor: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.directions_bus,
                  title: 'Show All Bus Routes',
                  onTap: () async {
                    Navigator.pop(context);
                    busRouteProvider.polylines = await initializeAllPolylines();
                    busStopsProvider.loadAllBusStops();
                  },
                ),
                // _buildDrawerItem(
                //   icon: Icons.notifications,
                //   title: 'Notifications',
                //   onTap: () => Navigator.pop(context),
                //   showBadge: true,
                // ),
                _buildDrawerItem(
                  icon: Icons.schedule,
                  title: 'Timetable',
                  onTap: () => Navigator.pushNamed(context, '/timetable'),
                ),
                _buildDrawerItem(
                  icon: Icons.favorite,
                  title: 'Saved Places',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedPlacesPage(),
                        ),
                      ),
                ),
                // _buildDrawerItem(
                //   icon: Icons.settings,
                //   title: 'Settings',
                //   onTap: () => Navigator.pushNamed(context, '/settings'),
                // ),
                _buildDrawerItem(
                  icon: Icons.info,
                  title: 'About Us',
                  onTap: () => Navigator.pushNamed(context, '/AboutUs'),
                ),
                _buildDrawerItem(
                  icon: Icons.report_problem,
                  title: 'Issues',
                  onTap: () => Navigator.pushNamed(context, '/issues'),
                )
              ],
            ),
          ),
          _buildAuthButton(),
        ],
      ),
    );
  }
}
