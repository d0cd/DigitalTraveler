import 'package:flutter/material.dart';
import 'package:DigitalTraveler/app/landing/components/main_button.dart';
import 'package:DigitalTraveler/app/landing/responsive.dart';
import 'package:DigitalTraveler/app/sign_in/sign_in_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:DigitalTraveler/routing/app_router.dart';

import '../constants.dart';

class Jumbotron extends StatelessWidget {
  const Jumbotron({
    Key? key,
  }) : super(key: key);

  Future<void> _showEmailPasswordSignInPage(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      AppRoutes.emailPasswordSignInPage,
      arguments: () => navigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(right: !isMobile(context) ? 40 : 0),
              child: Column(
                mainAxisAlignment: !isMobile(context)
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                crossAxisAlignment: !isMobile(context)
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: <Widget>[
                  if (isMobile(context))
                    Image.asset(
                      'assets/images/main_1.png',
                      height: size.height * 0.3,
                    ),
                  RichText(
                      textAlign: !isMobile(context)
                          ? TextAlign.start
                          : TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Gain insights into your\n',
                            style: GoogleFonts.robotoMono(
                                fontSize: isDesktop(context) ? 40 : 20,
                                fontWeight: FontWeight.w800,
                                color: kTextColor)),
                        TextSpan(
                            text: 'manufacturing process.\n',
                            style: GoogleFonts.robotoMono(
                                fontSize: isDesktop(context) ? 40 : 20,
                                fontWeight: FontWeight.w800,
                                color: kTextColor)),
                        TextSpan(
                            text: 'Pathify',
                            style: GoogleFonts.robotoMono(
                                fontSize: isDesktop(context) ? 64 : 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.deepPurpleAccent)),
                      ])),
                  SizedBox(height: 10),
                  SizedBox(height: 16),
                  Wrap(
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      MainButton(
                        title: 'LEARN MORE',
                        color: kPrimaryColor,
                        tapEvent: () => _showEmailPasswordSignInPage(
                            context), //TODO: Send to manual page
                      ),
                      SizedBox(width: 10),
                      MainButton(
                        title: 'Sign In',
                        color: kSecondaryColor,
                        tapEvent: () => _showEmailPasswordSignInPage(context),
                      )
                    ],
                  )
                ],
              ),
            )),
            if (isDesktop(context) || isTab(context))
              Expanded(
                  child: Image.asset(
                'assets/images/main_3.png',
                height: size.height * 0.7,
              ))
          ],
        ));
  }
}
