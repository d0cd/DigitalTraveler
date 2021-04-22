import 'package:DigitalTraveler/app/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:DigitalTraveler/app/landing/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'menu_item.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: <Widget>[
          Image.asset('assets/images/pathify-logo.jpg', width: 50),
          SizedBox(width: 10),
          Text(
            "Pathify",
            style: GoogleFonts.robotoMono(
                fontSize: 18, fontWeight: FontWeight.w800),
          ),
          Spacer(),
          if (!isMobile(context))
            Row(
              children: [
                NavItem(
                  title: 'Home',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'Learn More',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'About Us',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'Sign Up',
                  tapEvent: () {},
                ),
                NavItem(
                  title: 'Sign In',
                  tapEvent: () {},
                ),
              ],
            ),
          if (isMobile(context))
            IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                })
        ],
      ),
    );
  }
}
