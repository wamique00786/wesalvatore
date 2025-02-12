import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wesalvatore/views/contact_us_page.dart';
import 'package:wesalvatore/views/organization_page.dart';
import 'package:wesalvatore/views/premium_page.dart';
import 'package:wesalvatore/views/donation_page.dart';
import 'package:wesalvatore/views/adoption_page.dart';
import 'package:wesalvatore/views/team_page.dart';

class NavBar extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final name = 'John Doe';
    final email = 'john.doe@example.com';
    final imageUrl =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80';

    return Drawer(
      child: Material(
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            buildHeader(
              urlImage: imageUrl,
              name: name,
              email: email,
              onClicked: () => Navigator.pop(context),
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Donation',
                    icon: Icons.attach_money,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DonationListPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Adoption',
                    icon: Icons.pets,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdoptionPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Organizations',
                    icon: Icons.business,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrganizationPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Premium',
                    icon: Icons.money,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubscriptionPlans()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Team',
                    icon: Icons.people,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TeamPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white70),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Notifications',
                    icon: Icons.notifications_outlined,
                    onClicked: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Contact Us',
                    icon: Icons.contact_page,
                    onClicked: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactUsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Add the Logout option here
                  buildMenuItem(
                    text: 'Logout',
                    icon: Icons.exit_to_app,
                    onClicked: () async {
                      // Step 1: Clear the session data (e.g., user token, user data)
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs
                          .clear(); // Clears all data stored in SharedPreferences

                      // Step 2: Close the drawer
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);

                      // Step 3: Navigate to the login screen
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      onTap: onClicked,
    );
  }
}
