import 'package:DigitalTraveler/app/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:DigitalTraveler/app/landing/responsive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  tapEvent: () async {
                    const url =
                        'https://drive.google.com/file/d/1ONMzh4vIeaX6b73udy1lwHE5En8aWRXE/view?usp=sharing';
                    if (await canLaunch(url)) {
                      await launch(url, forceWebView: true);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
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
