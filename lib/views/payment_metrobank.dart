import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:url_launcher/url_launcher.dart' as URL;

class PaymentMetroBank extends StatefulWidget {
  const PaymentMetroBank({Key? key}) : super(key: key);

  @override
  PaymentMetroBankState createState() => PaymentMetroBankState();
}

class PaymentMetroBankState extends State<PaymentMetroBank> {
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
                child: Image.asset('assets/images/metrobank.png', fit: BoxFit.contain),
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
                '(fill out green payment slip)\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Open Sans', fontSize: 16),
              ),
              RichText(
                text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                  TextSpan(text: 'Company Name/Loan Type: '),
                  TextSpan(text: 'LPU Cavite\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Subscriber/Account Name: '),
                  TextSpan(text: ': Student Name\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Subscriber Number: '),
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
  text: TextSpan(
    style: const TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black),
    children: <TextSpan>[
      const TextSpan(text: '1. Go to Metrobank website '),
      TextSpan(
        text: '(onlinebanking.metrobank.com.ph).\n',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffA62D38)),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            URL.launchUrl(Uri.parse('https://onlinebanking.metrobank.com.ph/signin'));
          },
      ),
      const TextSpan(
        text: '2. Enter User ID and Password\n',
      ),
      const TextSpan(text: '3. Select Pay Bills\n'),
      const TextSpan(
        text: '4. Select “School” in the category drop down list then select “LPU Cavite” biller. For subscriber number field enter your Applicant Number.\n',
      ),
      const TextSpan(text: '5. Select account to debit\n'),
      const TextSpan(text: '6. You will receive a One Time Password (OTP) on your mobile number\n'),
      const TextSpan(text: '7. Select confirm\n'),
    ],
  ),
)
            ],
          ),
        ));
  }
}
