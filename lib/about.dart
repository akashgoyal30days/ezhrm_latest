import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'main.dart';

class About extends StatefulWidget {
  const About({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About>
    with SingleTickerProviderStateMixin<About> {
  var currDt = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  _launchURL(lurl) async {
    var url = lurl;
    if (await canLaunch(url)) {
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/30days.png', scale: 1.5),
                Column(
                  children: [
                    SizedBox(
                      child: Image.asset(
                        'assets/ezlogo.png',
                        scale: 6,
                      ),
                    ),
                    const Text(
                      'A Complete HR Management Software',
                      style: TextStyle(
                        color: Color(0xff072a99),
                      ),
                    ),
                    Text(
                      'v$version+$buildNumber',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 25,
                        fontFamily: font1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Let's get connected",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await launch(
                                  "https://www.youtube.com/channel/UCy-rTHg2QlS1UyrP6OXejGg");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.youtube,
                              color: Colors.red,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch("https://www.facebook.com/ezhrm");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.facebook,
                              color: Colors.indigo,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch(
                                  "https://www.linkedin.com/in/ezhrm-hr-and-payroll-management-software-2864291a3/");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.linkedin,
                              color: Colors.blue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch("https://twitter.com/EhrmSoftware");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.twitter,
                              color: Colors.blue,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await launch("https://wa.me/917056321321");
                            },
                            child: const FaIcon(
                              FontAwesomeIcons.whatsappSquare,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          await launch("tel:+917056321321");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.phone,
                              color: Colors.indigo,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '+91 7056321321',
                              style: TextStyle(
                                  color: Color(0xff072a99),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '© ${currDt.year.toString()} EZHRM',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 25,
                fontFamily: font1,
                color: Colors.grey,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
      //bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
