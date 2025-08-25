import 'package:flutter/material.dart';

import '../../shared/theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1.2),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'asset/images/person.png', // ✅ corrected path
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Ali Ismail",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: 3),
                          Text("ismailovich1904@gmail.com",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit, color: CineMindTheme.primaryRed),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Account Section
              const Text("Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 5),
              _buildListTile(Icons.lock, "Change Password"),

              const SizedBox(height: 20),

              // General Section
              const Text("General",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 10),
              _buildListTile(Icons.notifications, "Notifications"),
              _buildListTile(Icons.help, "Help & Support"),
              _buildListTile(Icons.info, "About"),
              _buildListTile(Icons.star, "Rate Us"),
              _buildListTile(Icons.logout, "Logout"),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildListTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: CineMindTheme.primaryRed),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing:
            const Icon(Icons.chevron_right, color: CineMindTheme.primaryRed),
      ),
    );
  }
}
