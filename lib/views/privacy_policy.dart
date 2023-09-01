import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  PrivacyPolicyState createState() => PrivacyPolicyState();
}

class PrivacyPolicyState extends State<PrivacyPolicy> {
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
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  'PRIVACY POLICY',
                  style: TextStyle(fontFamily: 'Futura', color: Color(0xffD94141), fontSize: 28, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  RichText(
                    text: const TextSpan(style: TextStyle(fontSize: 17, color: Colors.black), children: [
                      TextSpan(
                          text: '\t \t The Lyceum of the Philippines University Cavite is committed to protecting the '
                              'privacy of our stakeholders, complying fully with the provisions of Republic Act 10173 '
                              'known as The Data Privacy Act of 2012. \n \n'),
                      TextSpan(
                          text: '\t \t In order to provide you with the best services and to properly process your transactions'
                              'with the University, we necessarily have to collect pertinent information and data from you.'
                              'Such as personal data include but not limited to the following: \n'),
                    ]),
                    softWrap: true,
                    textAlign: TextAlign.justify,
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Text(
                          '• Name \n• Date of Birth \n• Gender \n• Email Address \n',
                          style: TextStyle(fontSize: 17, color: Colors.black),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Text(
                          '• Address \n• Age \n• Contact Number \n• and other personal data as many \n\t be required',
                          style: TextStyle(fontSize: 17, color: Colors.black),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontSize: 17, color: Colors.black), children: [
                      TextSpan(
                          text: '\n \t \t These information and/or data will be used for purpose permitted by law to allow this education'
                              'institution to conduct its functions, which include but not limited to academic, administrative and research '
                              'purposes. The University will retain your information indefinitely or as may be required by the process '
                              'itself and also for historical and statistical purposes. \n \n'),
                      TextSpan(
                          text: '\t \t Please be assured that we are committed to securing all the information we have collected. '
                              'In fact we have put reasonable physical, technical and administrative safeguards to prevent unauthorized access '
                              'to or use of these collected information. \n \n'),
                      TextSpan(text: '\t \t We will not disclose or share your information with third parties except when: \n'),
                    ]),
                    softWrap: true,
                    textAlign: TextAlign.justify,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      children: [
                        RichText(
                          text: const TextSpan(style: TextStyle(fontSize: 17, color: Colors.black), children: [
                            TextSpan(text: '1. permitted or required by law; \n'),
                            TextSpan(text: '2. it is necessary in order to protect the University\'s interests;\n'),
                            TextSpan(text: '3. With service providers acting on our behalf that have agreed to protect the confidentiality of the data.\n'),
                          ]),
                          softWrap: true,
                          textAlign: TextAlign.justify,
                        )
                      ],
                    ),
                  ),
                  RichText(
                    text: const TextSpan(style: TextStyle(fontSize: 17, color: Colors.black), children: [
                      TextSpan(
                          text: '\t \t As provided by law, you are entitled to certain rights such as but not limited to the right '
                              'to be informed of and to object to the processing of your personal data, the right to access, the right '
                              'to rectify and the right to erasure or blocking of your personal data. \n \n'),
                      TextSpan(text: '\t \t If you have questions, clarifications, requests, or complaints, please send an email to '),
                      TextSpan(text: 'THE DATA PROTECTION OFFICER ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'at privacy.cavite@lpu.edu.ph or call (046) 481 - 1400 local 425.')
                    ]),
                    softWrap: true,
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
