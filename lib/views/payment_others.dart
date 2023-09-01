import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';

class PaymentOthers extends StatefulWidget {
  const PaymentOthers({Key? key}) : super(key: key);

  @override
  PaymentOthersState createState() => PaymentOthersState();
}

class PaymentOthersState extends State<PaymentOthers> {
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
              const Text(
                'OFFSITE PAYMENT CHANNELS FOR CONTINUING STUDENTS',
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
              SizedBox(
                height: 100,
                child: Image.asset('assets/images/sm.png', fit: BoxFit.contain),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'SM BILLS PAYMENT\nOVER THE COUNTER PAYMENT\n(fill out BPS validation slip)\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, fontWeight: FontWeight.w600),
              ),
              RichText(
                text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                  TextSpan(text: 'Biller Company: '),
                  TextSpan(text: 'Lyceum of the Philippines University Cavite\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Card/Account/Policy No: '),
                  TextSpan(text: 'Student Number\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Account Name: '),
                  TextSpan(text: 'Student Name\n', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
              SizedBox(
                height: 100,
                child: Image.asset('assets/images/mlhuillier.png', fit: BoxFit.contain),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'MLHUILLIER\nOVER THE COUNTER PAYMENT\n(fill out bills payment slip)\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, fontWeight: FontWeight.w600),
              ),
              RichText(
                text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                  TextSpan(text: 'Payment to: '),
                  TextSpan(text: 'Lyceum of the Philippines University Cavite\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Account Name: '),
                  TextSpan(text: 'Student Name\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Account Number: '),
                  TextSpan(text: 'Student Number\n\n', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
              SizedBox(
                height: 100,
                child: Image.asset('assets/images/bayadcenter.png', fit: BoxFit.contain),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'BAYAD CENTER\nOVER THE COUNTER PAYMENT\n(fill out transaction form)\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, fontWeight: FontWeight.w600),
              ),
              RichText(
                text: const TextSpan(style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, color: Colors.black), children: <TextSpan>[
                  TextSpan(text: 'Biller: '),
                  TextSpan(text: 'Lyceum of the Philippines University Cavite\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Account Number: '),
                  TextSpan(text: 'Student Number\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Account Name: '),
                  TextSpan(text: 'Student Name\n', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
        ));
  }
}
