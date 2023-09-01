import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';

class PaymentBPI extends StatefulWidget {
  const PaymentBPI({Key? key}) : super(key: key);

  @override
  PaymentBPIState createState() => PaymentBPIState();
}

class PaymentBPIState extends State<PaymentBPI> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
                child: Image.asset('assets/images/bpi.png', fit: BoxFit.contain),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    'Use the bills payment option on their BEA machine.\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Open Sans', fontSize: 16),
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: 'Account Number: '),
                      TextSpan(text: '8943-0751-08\n', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Merchant’s Name: '),
                      TextSpan(text: 'Lyceum of the Philippines Univerisity Inc.\n', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Reference Number: '),
                      TextSpan(text: 'Student Number', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  const Text(
                    'ONLINE PAYMENT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Futura',
                      color: Color(0xffD94141),
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Steps on how to pay in Metrobank Direct Online\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Open Sans', fontSize: 16),
                  ),
                  RichText(
                    text: TextSpan(style: const TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      const TextSpan(text: 'Enroll your account - '),
                      TextSpan(
                        text: '(www.bpi.com.ph).\n',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffA62D38)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            URL.launch('https://www.bpi.com.ph/');
                          },
                      ),
                      const TextSpan(text: '1. Using any browser, visit '),
                      TextSpan(
                        text: 'online.bpi.com.ph\n',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffA62D38)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            URL.launch('https://online.bpi.com.ph/portalserver/onlinebanking/sign-in');
                          },
                      ),
                    ]),
                  ),
                  Image.asset(
                    'assets/images/step1.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '2. Log-in using your online banking credential'),
                    ]),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/images/step2.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '3. Click the burger menu icon, then select '),
                      TextSpan(text: 'OTHER SERVICES\n', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '4. Select '),
                      TextSpan(text: 'MANAGE RECIPIENT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/images/step3&4.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '5. Click '),
                      TextSpan(text: 'ADD NEW RECIPIENT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/images/step5.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '6. Select '),
                      TextSpan(text: 'BILLER', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/images/step6.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '7. Key in the word LYCEUM, the system will display list for your option. Select the '),
                      TextSpan(text: 'LYCEUM OF THE PHILS UNIV-CAV', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/images/step7.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '8. Key in your '),
                      TextSpan(text: 'STUDENT NUMBER ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'in the Reference Number'),
                    ]),
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '9. Click '),
                      TextSpan(text: 'NEXT ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'button and click confirm'),
                    ]),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Image.asset(
                    'assets/images/step8&9.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                      TextSpan(text: '10. Click Done. LPU Cavite is now added to your Biller List where you can easily make an online payment'),
                    ]),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
