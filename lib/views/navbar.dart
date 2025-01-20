import 'package:flutter/material.dart';

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
        color: Color.fromRGBO(13, 114, 114, 1),
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
                    onClicked: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Adoption',
                    icon: Icons.pets,
                    onClicked: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white70),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'Notifications',
                    icon: Icons.notifications_outlined,
                    onClicked: () => Navigator.pop(context),
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
