// import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:package_info_plus/package_info_plus.dart';

import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:http/http.dart' as http;

import '../../widgets/widgets.dart';
import '../language/languages.dart';
import '../login/login.dart';
import '../noInternet/noInternet.dart';
import '../onTripPage/booking_confirmation.dart';
import '../onTripPage/invoice.dart';
import '../onTripPage/map_page.dart';
import 'loading.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

dynamic package;

class _LoadingPageState extends State<LoadingPage> {
  String dot = '.';
  bool updateAvailable = false;

  dynamic _version;
  bool _isLoading = false;
  bool _error = false;

  @override
  void initState() {
    getLanguageDone();

    super.initState();
  }

  //navigate
  navigate() {
    if (userRequestData.isNotEmpty && userRequestData['is_completed'] == 1) {
      //invoice page of ride
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Invoice()),
          (route) => false);
    } else if (userRequestData.isNotEmpty &&
        userRequestData['is_completed'] != 1) {
      //searching ride page
      if (userRequestData['is_rental'] == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => BookingConfirmation(
                      type: 1,
                    )),
            (route) => false);
      } else if (userRequestData['drop_lat'] == null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => BookingConfirmation(
                      type: 2,
                    )),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BookingConfirmation()),
            (route) => false);
      }
    } else {
      //home page
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Maps()),
          (route) => false);
    }
  }

  getData() async {
    package = await PackageInfo.fromPlatform();

    for (var i = 0; _error == true; i++) {
      await getLanguageDone();
    }
  }

//get language json and data saved in local (bearer token , choosen language) and find users current status
  getLanguageDone() async {
    // var wallet = await FirebaseDatabase.instance.ref().child('enable_wallet').get();
    // print('wallet value is ${wallet.value}');

     package = await PackageInfo.fromPlatform();
     // if (platform == TargetPlatform.android && package != null) {
     //   await FirebaseDatabase.instance
     //       .ref()
     //       .update({'user_package_name': package.packageName.toString()});
     // } else if (package != null) {
     //   await FirebaseDatabase.instance
     //       .ref()
     //       .update({'user_bundle_id': package.packageName.toString()});
     // }
    // try {
    //   if (platform == TargetPlatform.android) {
    //     _version = await FirebaseDatabase.instance
    //         .ref()
    //         .child('user_android_version')
    //         .get();
    //   } else {
    //     _version = await FirebaseDatabase.instance
    //         .ref()
    //         .child('user_ios_version')
    //         .get();
    //   }
    //   _error = false;
    //   if (_version.value != null) {
    //     var version = _version.value.toString().split('.');
    //     var packages = package.version.toString().split('.');
    //
    //     for (var i = 0; i < version.length || i < packages.length; i++) {
    //       if (i < version.length && i < packages.length) {
    //         if (int.parse(packages[i]) < int.parse(version[i])) {
    //           setState(() {
    //             updateAvailable = true;
    //           });
    //           break;
    //         } else if (int.parse(packages[i]) > int.parse(version[i])) {
    //           setState(() {
    //             updateAvailable = false;
    //           });
    //           break;
    //         }
    //       } else if (i >= version.length && i < packages.length) {
    //         setState(() {
    //           updateAvailable = false;
    //         });
    //         break;
    //       } else if (i < version.length && i >= packages.length) {
    //         setState(() {
    //           updateAvailable = true;
    //         });
    //         break;
    //       }
    //     }
    //   }

      if (updateAvailable == false) {
        await getDetailsOfDevice();
        if (internet == true) {
          var val = await getLocalData();

          if (val == '3') {
            navigate();
          } else if (val == '2') {
            Future.delayed(const Duration(seconds: 2), () {
              //login page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            });
          } else {
            Future.delayed(const Duration(seconds: 2), () {
              //choose language page
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Languages()));
            });
          }
        } else {
          setState(() {});
        }
      }
    // } catch (e) {
    //   if (_error == false) {
    //     setState(() {
    //       _error = true;
    //     });
    //     getData();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: media.height * 1,
              width: media.width * 1,
              decoration: BoxDecoration(
                color: buttonColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(media.width * 0.01),
                    width: media.width * 0.429,
                    height: media.width * 0.429,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain)),
                  ),
                ],
              ),
            ),

            //update available

            (updateAvailable == true)
                ? Positioned(
                    top: 0,
                    child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: media.width * 0.9,
                              padding: EdgeInsets.all(media.width * 0.05),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: page,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: media.width * 0.8,
                                      child: Text(
                                        'New version of this app is available in store, please update the app for continue using',
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            fontWeight: FontWeight.w600),
                                      )),
                                  SizedBox(
                                    height: media.width * 0.05,
                                  ),
                                  Button(
                                      onTap: () async {
                                        if (platform ==
                                            TargetPlatform.android) {
                                          openBrowser(
                                              'https://play.google.com/store/apps/details?id=${package.packageName}');
                                        } else {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          var response = await http.get(Uri.parse(
                                              'http://itunes.apple.com/lookup?bundleId=${package.packageName}'));
                                          if (response.statusCode == 200) {
                                            openBrowser(jsonDecode(
                                                    response.body)['results'][0]
                                                ['trackViewUrl']);
                                          }

                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                      text: 'Update')
                                ],
                              ))
                        ],
                      ),
                    ))
                : Container(),

            //loader
            (_isLoading == true && internet == true)
                ? const Positioned(top: 0, child: Loading())
                : Container(),

            //no internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        setState(() {
                          internetTrue();
                          getLanguageDone();
                        });
                      },
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
