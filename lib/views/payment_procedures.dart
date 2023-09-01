import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/payment_bpi.dart';
import 'package:lpu_app/views/payment_gcash.dart';
import 'package:lpu_app/views/payment_metrobank.dart';
import 'package:lpu_app/views/payment_others.dart';

class PaymentProcedures extends StatefulWidget {
  const PaymentProcedures({Key? key}) : super(key: key);

  @override
  PaymentProceduresState createState() => PaymentProceduresState();
}

class PaymentProceduresState extends State<PaymentProcedures> {
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
      body: Container(
          height: 1080,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
          child:
              // Column(
              //   children: [
              // Container(
              //     child: Image.asset(
              //       'assets/images/payment_procedures.png',
              //       width: double.infinity,
              //     ),
              //     padding: const EdgeInsets.only(bottom: 16)),
              SizedBox(
                  child: GridView.count(physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0, children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentBPI()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: Center(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Expanded(child: Image.asset('assets/images/bpi.png', fit: BoxFit.contain)),
                        const SizedBox(height: 16),
                        const Text('Bank of the Philippine Islands (BPI)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )),
                      ]),
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMetroBank()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: Center(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Expanded(child: Image.asset('assets/images/metrobank.png', fit: BoxFit.contain)),
                        const SizedBox(height: 16),
                        const Text('Metrobank',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )),
                      ]),
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentGCash()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: Center(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Expanded(child: Image.asset('assets/images/gcash.png', fit: BoxFit.contain)),
                        const SizedBox(height: 16),
                        const Text('GCash',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )),
                      ]),
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentOthers()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                    child: Center(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                        Expanded(child: Image.asset('assets/images/others.png', fit: BoxFit.contain)),
                        const SizedBox(height: 16),
                        const Text('Other Payment Channels',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )),
                      ]),
                    )),
              ),
            ),
          ]))

          // ],)
          ),
    );
  }
}
