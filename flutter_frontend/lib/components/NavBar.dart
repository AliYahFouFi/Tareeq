// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/components/RoutesList.dart';
import 'package:flutter_frontend/models/BusStop_model.dart';
import 'package:flutter_frontend/pages/BusDetailsPage.dart';
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
    return CupertinoTabBar(
      height: 60,
      backgroundColor: Colors.deepPurple,
      activeColor: Colors.white,
      inactiveColor: Colors.white.withOpacity(0.6),
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Routes'),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions),
          label: 'Plan Trip',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
            break;
          case 1:
            showBusRoutesBottomSheet(context);
            break;
          case 2:
            Navigator.pushNamed(context, '/selectStopPage');
            break;
        }
      },
    );
  }
}
