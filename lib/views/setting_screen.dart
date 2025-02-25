import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wesalvatore/provider/themeprovider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 10),
            // _buildThemeOption(
            //   context,
            //   title: "Light Mode",
            //   icon: Icons.wb_sunny_rounded,
            //   isSelected: themeProvider.themeMode == ThemeMode.light,
            //   onTap: () => themeProvider.setTheme(ThemeMode.light),
            // ),
            // _buildThemeOption(
            //   context,
            //   title: "Dark Mode",
            //   icon: Icons.nightlight_round,
            //   isSelected: themeProvider.themeMode == ThemeMode.dark,
            //   onTap: () => themeProvider.setTheme(ThemeMode.dark),
            // ),
            // _buildThemeOption(
            //   context,
            //   title: "System Default",
            //   icon: Icons.brightness_auto,
            //   isSelected: themeProvider.themeMode == ThemeMode.system,
            //   onTap: () => themeProvider.setTheme(ThemeMode.system),
            // ),
            const SizedBox(height: 20),
            _buildDarkModeToggle(context, isDarkMode, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context,
      {required String title,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 6 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              Icon(icon,
                  size: 28, color: isSelected ? Colors.teal : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500))),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.teal, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(
      BuildContext context, bool isDarkMode, ThemeProvider themeProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dark Mode",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Switch(
              value: isDarkMode,
              activeColor: Colors.teal,
              onChanged: (value) {
                themeProvider
                    .setTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ],
        ),
      ),
    );
  }
}
