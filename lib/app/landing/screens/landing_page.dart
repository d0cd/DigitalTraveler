import 'package:flutter/material.dart';
import 'package:DigitalTraveler/app/landing/components/footer.dart';
import 'package:DigitalTraveler/app/landing/components/header.dart';
import 'package:DigitalTraveler/app/landing/components/side_menu.dart';
import 'package:DigitalTraveler/routing/app_router.dart';

import '../components/jumbotron.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      endDrawer: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300),
        child: SideMenu(),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: size.width,
            constraints: BoxConstraints(minHeight: size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Header(), Jumbotron(), Footer()],
            ),
          ),
        ),
      ),
    );
  }
}
