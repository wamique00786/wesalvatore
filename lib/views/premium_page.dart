import 'package:flutter/material.dart';

class SubscriptionPlans extends StatefulWidget {
  const SubscriptionPlans({super.key});

  @override
  SubscriptionPlansState createState() => SubscriptionPlansState();
}

class SubscriptionPlansState extends State<SubscriptionPlans> {
  bool isAnnual = true; // Tracks if the user is viewing annual or monthly plans

  final List<Map<String, dynamic>> annualPlans = [
    {
      'name': 'Bronze Plan',
      'price': '₹5000.00',
      'facilities': ['Basic consultation', 'Emergency assistance'],
      'buttonText': 'Buy Bronze',
      'color': Colors.brown[300],
    },
    {
      'name': 'Silver Plan',
      'price': '₹10000.00',
      'facilities': ['Basic consultation', 'Emergency assistance'],
      'buttonText': 'Buy Silver',
      'color': Colors.grey[400],
    },
    {
      'name': 'Gold Plan',
      'price': '₹15000.00',
      'facilities': ['Basic', 'Emergency assistance'],
      'buttonText': 'Buy Gold',
      'color': Colors.amber[400],
    },
  ];

  final List<Map<String, dynamic>> monthlyPlans = [
    {
      'name': 'Bronze Plan',
      'price': '₹500.00',
      'facilities': ['Basic consultation', 'Emergency assistance'],
      'buttonText': 'Buy Bronze',
      'color': Colors.brown[300],
    },
    {
      'name': 'Silver Plan',
      'price': '₹1000.00',
      'facilities': ['Basic consultation', 'Emergency assistance'],
      'buttonText': 'Buy Silver',
      'color': Colors.grey[400],
    },
    {
      'name': 'Gold Plan',
      'price': '₹1500.00',
      'facilities': ['Basic', 'Emergency assistance'],
      'buttonText': 'Buy Gold',
      'color': Colors.amber[400],
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentPlans =
        isAnnual ? annualPlans : monthlyPlans;

    return Scaffold(
      appBar: AppBar(
          title: Text('Subscription Plans'),
          backgroundColor: Colors.blueAccent,
          automaticallyImplyLeading: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
              top: Radius.circular(20),
            ),
          )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ToggleButtons(
                isSelected: [!isAnnual, isAnnual],
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Monthly'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Annually'),
                  ),
                ],
                onPressed: (index) {
                  setState(() {
                    isAnnual = index == 1;
                  });
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: currentPlans.length,
                  itemBuilder: (context, index) {
                    final plan = currentPlans[index];
                    return Card(
                      color: plan['color'],
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${isAnnual ? 'Annually' : 'Monthly'}: ${plan['price']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  plan['facilities'].map<Widget>((facility) {
                                return Text('• $facility');
                              }).toList(),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                              child: Text(plan['buttonText']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
