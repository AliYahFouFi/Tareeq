import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/RoutesList.dart';
import 'package:flutter_frontend/components/login.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  //for bus routes
  List<BusStop> stopsForOneRoute = [];

  List<BusStop> GetstopsForOneRoute() {
    return stopsForOneRoute;
  }

  @override
  Widget build(BuildContext context) {
    return GNav(
      gap: 8,
      backgroundColor: Colors.deepPurple,
      color: Colors.white,
      activeColor: Colors.white,
      tabBackgroundColor: Colors.deepPurple.shade400,
      padding: const EdgeInsets.all(16),
      tabMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tabs: [
        GButton(
          icon: Icons.home,
          text: 'Home',
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
        ),
        GButton(
          icon: Icons.directions_bus,
          text: 'Routes',
          onPressed: () => showBusRoutesBottomSheet(context),
        ),
        GButton(
          icon: Icons.settings,
          text: 'Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ],
    );
  }
}
