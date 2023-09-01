import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';

class PaymentGCash extends StatefulWidget {
  const PaymentGCash({Key? key}) : super(key: key);

  @override
  PaymentGCashState createState() => PaymentGCashState();
}

class PaymentGCashState extends State<PaymentGCash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
            ),
            color: AppConfig.appSecondaryTheme,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Image.asset('assets/images/gcash.png', fit: BoxFit.contain),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'OVER THE COUNTER PAYMENT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: Color(0xffD94141),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Steps on how to pay using GCash',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Open Sans', fontSize: 16),
              ),
              RichText(
                  text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                TextSpan(text: '1. Tap \'Pay Bills\' on the GCash App dashboard\n'),
                TextSpan(
                  text: '2. Choose Biller’s Categories – \'Schools\'\n',
                ),
                TextSpan(text: '3. Tap \'Lyceum of the Philippines University\'\n'),
                TextSpan(text: '4. Enter the necessary information\n'),
                TextSpan(
                  text: '\u2022 For New Student Applicant: Use your applicant number at the student number field, amount due, payable amount, student name, campus (\'Cavite\') and email (optional)\n',
                ),
                TextSpan(
                  text: '\u2022 For Continuing Students : Student number (Do not include the dash), amount due, payable amount, student name, campus (“Cavite”) and email (optional)\n',
                ),
                TextSpan(text: '5. Email a screenshot of your payment confirmation to the Accounting Department email at '),
              ])),
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  child: const Text('lpuc_accounting@lpu.edu.ph', textAlign: TextAlign.left, style: TextStyle(color: Color(0xffA62D38), fontWeight: FontWeight.bold)),
                  onTap: () => URL.launch('mailto:lpuc_accounting@lpu.edu.ph'),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await LaunchApp.openApp(
                      androidPackageName: 'com.globe.gcash.android',
                      iosUrlScheme: 'gcash://',
                      appStoreLink: 'https://apps.apple.com/ph/app/gcash/id520020791',
                      // openStore: false
                    );

                    // Enter the package name of the App you want to open and for iOS add the URLscheme to the Info.plist file.
                    // The `openStore` argument decides whether the app redirects to PlayStore or AppStore.
                    // For testing purpose you can enter com.instagram.android
                  },
                  child: const Text(
                    'Open GCash',
                    style: TextStyle(fontFamily: 'Futura', color: AppConfig.appSecondaryTheme, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        width: 2,
                        color: AppConfig.appSecondaryTheme,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      )),
                ),
              ),
            ],
          ),
        ));
  }
}
