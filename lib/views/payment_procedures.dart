import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/views/payment_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentProcedures extends StatefulWidget {
  const PaymentProcedures({Key? key}) : super(key: key);

  @override
  PaymentProceduresState createState() => PaymentProceduresState();
}

class PaymentProceduresState extends State<PaymentProcedures> {
  late Future<List<Map<String, dynamic>>> paymentMethods;

  @override
  void initState() {
    super.initState();
    paymentMethods = fetchPaymentMethods();
  }

  Future<List<Map<String, dynamic>>> fetchPaymentMethods() async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('payment_procedures')
      .where('visible', isEqualTo: true) // Filter by 'visible' field equal to true
      .orderBy('edited_on', descending: false) // Order by 'edited_on' field in descending order
      .get();
  
  return querySnapshot.docs.map((doc) => doc.data()).toList();
}


  Widget _buildLogoImage(dynamic logoData) {
  if (logoData is String) {
    // If 'logoData' is a String (single URL), display the image
    return Image.network(
      logoData,
      fit: BoxFit.contain,
    );
  } else if (logoData is List<dynamic> && logoData.isNotEmpty && logoData.first is String) {
    // If 'logoData' is a List of URLs, choose the first URL to display
    return Image.network(
      logoData.first,
      fit: BoxFit.contain,
    );
  } else {
    // If the 'logoData' is not a String or a List of URLs, display a placeholder or handle accordingly
    return Text('Invalid logo data');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: AppConfig.appSecondaryTheme,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: paymentMethods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No payment methods available.'));
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                children: snapshot.data!.map((paymentMethod) {
                  return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentContent(paymentMethod: paymentMethod),
      ),
    );
  },
  child: Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: _buildLogoImage(paymentMethod['logo']),
          ),
          const SizedBox(height: 16),
          Text(
  paymentMethod['channels'] ?? 'Channel Not Available',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  ),
),
        ],
      ),
    ),
  ),
),

                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}