import 'package:cinemind/module/about_us.dart';
import 'package:cinemind/module/support_screen.dart';
import 'package:cinemind/shared/repo/auth_repo.dart';
import 'package:cinemind/shared/service/notification_service.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../shared/cubit/tv/tv_trending/provider/auth_provider.dart';
import '../authentication/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
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
                      child: user?.photoURL != null
                          ? Image.network(
                              user!.photoURL!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'asset/images/person.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName ?? "User Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: 3),
                          Text(user?.email ?? "No Email Found Amigo",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // General Section
              const Text("General",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 10),
              _buildListTile(Icons.notifications, "Notifications",
                  function: () {
                NotificationService.showBasicNotification();
              }),
              _buildListTile(Icons.help, "Help & Support", function: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HelpSupportScreen()));
              }),

              _buildListTile(Icons.info, "About", function: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutScreen()));
              }),
              _buildListTile(Icons.refresh, "Reset Data", function: () async {
                resetUserData(context);
              }),

              _buildListTile(Icons.logout, "Logout", function: () async {
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // prevent closing by tapping outside
                  builder: (context) => const Center(
                    child: SpinKitHourGlass(
                      color: Colors.redAccent,
                    ),
                  ),
                );

                try {
                  await AuthProviderCustome.signOut();

                  // Close the loading dialog
                  Navigator.pop(context);

                  // Navigate to login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } catch (e) {
                  Navigator.pop(context); // close the loading dialog if error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildListTile(IconData icon, String title,
      {dynamic function}) {
    return GestureDetector(
      onTap: function,
      child: Container(
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
      ),
    );
  }
}
