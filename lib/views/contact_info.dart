import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:lpu_app/config/app_config.dart';

void main() => runApp(const ContactInfo());

class ContactInfo extends StatelessWidget {
  const ContactInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
            ),
            color: AppConfig.appSecondaryTheme,
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: const _ContactInfo(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _ContactInfo extends StatefulWidget {
  const _ContactInfo({Key? key}) : super(key: key);

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<_ContactInfo> {
  final GlobalKey<ExpansionTileCardState> cardA = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardB = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardC = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardD = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardE = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardF = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardG = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardH = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardI = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardJ = GlobalKey();
  final GlobalKey<ExpansionTileCardState> cardK = GlobalKey();

  final GlobalKey<ExpansionTileCardState> admin1 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin2 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin3 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin4 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin5 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin6 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin7 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin8 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin9 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin10 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin11 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin12 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin13 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin14 = GlobalKey();
  final GlobalKey<ExpansionTileCardState> admin15 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'ACADEMIC UNIT \nCONTACT INFO',
              style: TextStyle(fontFamily: 'Futura', color: Color(0xFFD94141), fontSize: 28, fontWeight: FontWeight.w600),
            ),
          ),
          Column(
            children: <Widget>[
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardA,
                title: const Text('College of Allied Medical Sciences'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-cams@lpu.edu.ph \n'
                          'Phone Number: (046) 481-1419 \n'
                          'Facebook: @LPUCollegeofAlliedMedicalSciences \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardB,
                title: const Text('College of Arts and Sciences'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-cas@lpu.edu.ph \n'
                          'Phone Number: (046) 481-1447 \n'
                          'Facebook: @LPUCaviteCAS \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardC,
                title: const Text('College of Business Administration'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-cba@lpu.edu.ph \n'
                          'Phone Number: (046) 481–1410 \n'
                          'Facebook: @LPUCaviteCollegeofBusinessAdministration \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardD,
                title: const Text('College of Engineering, Computer Studies, and Architecture'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: \n'
                          'Department of Architecture: cav-doa@lpu.edu.ph \n'
                          'Department of Computer Science: cav-dcs@lpu.edu.ph \n'
                          'Department of Engineering: cav-doe@lpu.edu.ph \n \n'
                          'Phone Number: (046) 481–1416 \n'
                          'Facebook: @LPUCaviteCOECSA \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardE,
                title: const Text('College of Fine Arts and Design'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-cfad@lpu.edu.ph \n'
                          'Phone Number: (046) 481-1416 \n'
                          'Facebook: @LPUCaviteCollegeofFineArtsandDesign \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardF,
                title: const Text('College of International Tourism and Hospitality Management'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-cithm@lpu.edu.ph \n'
                          'Phone Number: (046) 481-1451 \n'
                          'Facebook: @OfficialCITHM.LPUC \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardG,
                title: const Text('College of Law'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-col@lpu.edu.ph \n'
                          'Phone Number: (046) 481–1412 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardH,
                title: const Text('College of Nursing'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-con@lpu.edu.ph \n'
                          'Facebook: @lpucollegeofnursing \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardI,
                title: const Text('Culinary Institute'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-ci@lpu.edu.ph \n'
                          'Facebook: @culinaryinstitutelpucavite \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardJ,
                title: const Text('Graduate School'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-gs@lpu.edu.ph \n'
                          'Phone Number: (046) 481-1413 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: cardK,
                title: const Text('International School'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: \n'
                          'For general concerns: lpuc_is@lpu.edu.ph \n'
                          'For Inquiries: inquiry.is@lpu.edu.ph \n'
                          'For Document Request: cav-is@lpu.edu.ph \n'
                          'For Junior High School Queries: cav-jhs@lpu.edu.ph \n'
                          'For Senior High School Queries: cav-shs@lpu.edu.ph \n \n'
                          'Phone Number: (046) 481–1414 | 0966-820-7737 \n'
                          'Facebook: @LPUCaviteInternationalSchool \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'ADMINISTRATIVE UNIT \nCONTACT INFO',
              style: TextStyle(fontFamily: 'Futura', color: Color(0xFFD94141), fontSize: 28, fontWeight: FontWeight.w600),
            ),
          ),
          Column(
            children: <Widget>[
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin1,
                title: const Text('LPU Cavite Admissions/ Communications and Public Affairs Department'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: admission_cvt@lpu.edu.ph \n'
                          'Phone Number: (046) 481-1400 | 0917-382-6989 \n'
                          'Fax: (046) 484–8095 \n'
                          'Facebook: @LPUCavite \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin2,
                title: const Text('Academic Resource Center'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-arc@lpu.edu.ph \n'
                          'Facebook: @LPUCaviteARC \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin3,
                title: const Text('Accounting Department'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: \n'
                          'For general queries: lpuc_accounting@lpu.edu.ph \n'
                          'For rebates: rebates.inquiry-cvt@lpu.edu.ph \n'
                          'Phone: (046) 481–1434 | 0906-195-1483 \n'
                          'Facebook: @LPUCaviteAccountingDepartment \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin4,
                title: const Text('Alumni Affairs'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: alumniaffairs.cavite@lpu.edu.ph \n'
                          'Phone: (046) 481–1462 \n'
                          'Facebook: @LPUCAAO \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin5,
                title: const Text('Arts and Cultural Affairs'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: culturalaffairs@lpu.edu.ph \n'
                          'Phone: (046) 481–1462 \n'
                          'Facebook: @lpucaviteartcad \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin6,
                title: const Text('Data Protection Office'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: privacy.cavite@lpu.edu.ph \n'
                          'Phone: (046) 481–1425 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin7,
                title: const Text('Executive Office'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cvt-eo@lpu.edu.ph \n'
                          'Phone: (046) 481–1404 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin8,
                title: const Text('Global Relations and Strategic Partnerships'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-grasp@lpu.edu.ph \n'
                          'Phone: (046) 481–1462 \n'
                          'Facebook: @lpu.csi.iao \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin9,
                title: const Text('Guidance and Testing Center'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: lpuc_gtc@lpu.edu.ph \n'
                          'Phone: (046) 481-436 \n'
                          'Facebook: @LPU Cavite – Guidance and Testing Center \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin10,
                title: const Text('Health Services Department'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-hsd@lpu.edu.ph \n'
                          'Phone: (046) 481-1458 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin11,
                title: const Text('Human Resource Department'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-hrd@lpu.edu.ph \n'
                          'Phone: (046) 481-1454 \n'
                          'Facebook: @LPUCC \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin12,
                title: const Text('Information and Communication Technology'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: \n'
                          'For general queries and technical assistance: servicedesk.ict@lpu.edu.ph \n'
                          'Phone: (046) 481-1424 \n'
                          'Facebook: @lpucaviteictd \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin13,
                title: const Text('Office of the Executive Director for Academic Affairs'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: cav-edo@lpu.edu.ph \n'
                          'Phone: (046) 481-1408 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin14,
                title: const Text('Student Affairs Office'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: lpuc_sao@lpu.edu.ph \n'
                          'Phone: (046) 481-1460 \n \n'
                          'The following cellphone numbers are strictly call only: \n'
                          'Smart: 0951-867-4543 \n'
                          'Globe: 0915-189-0517 \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ExpansionTileCard(
                baseColor: Colors.white,
                expandedColor: AppConfig.appSecondaryTheme,
                key: admin15,
                title: const Text('Student Records Management Department or Registrar’s Office'),
                children: <Widget>[
                  Container(
                    color: const Color(0xFFD0D0D0),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Email: \n'
                          'For IS general concern: cav-regis@lpu.edu.ph \n'
                          'For college and graduate school concern: cav-regrequest@lpu.edu.ph \n'
                          'For college and graduate school enrolment concern: cav-regenroll@lpu.edu.ph \n \n'
                          'Phone: (046) 481-1430 | 0966-820-7739 \n'
                          'Facebook: @LPUCaviteSRMD \n',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
