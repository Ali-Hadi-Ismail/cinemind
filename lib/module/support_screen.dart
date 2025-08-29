import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cinemind/shared/theme/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Your support email
  final String supportEmail = "yali.hadi.ismail0@example.com";

  Future<void> _sendSupportEmail(BuildContext context) async {
    // Method 1: Simple mailto (most reliable)
    final Uri emailUri = Uri.parse(
        'mailto:$supportEmail?subject=CineMind App Support - Error Report&body=Hello Ali,%0A%0AI found an issue in CineMind:%0A[Describe the error here]%0A%0AApp Version: 1.0.0%0ADevice: [Your Device Name]%0AOS: [Android/iOS version]');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication, // Force external app
        );
      } else {
        // Fallback: Try alternative methods
        await _tryAlternativeEmailMethods(context);
      }
    } catch (e) {
      _showErrorDialog(context, 'Error opening email app: $e');
    }
  }

  Future<void> _tryAlternativeEmailMethods(BuildContext context) async {
    // Method 2: Try with different launch modes
    final Uri simpleEmailUri = Uri.parse('mailto:$supportEmail');

    try {
      await launchUrl(
        simpleEmailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Method 3: Show manual contact info
      _showManualContactDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email App Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 10),
            const Text('Please contact us manually at:'),
            const SizedBox(height: 5),
            SelectableText(
              supportEmail,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showManualContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('No email app found. Please contact us manually:'),
            const SizedBox(height: 10),
            const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(supportEmail),
            const SizedBox(height: 10),
            const Text('Subject:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SelectableText('CineMind App Support - Error Report'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.support_agent,
                size: 100, color: CineMindTheme.primaryRed),
            const SizedBox(height: 30),
            Text(
              "Need Help?",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CineMindTheme.primaryRed,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              "If you encounter an error or something isn't working as expected, "
              "you can reach out directly to us. Tap the button below to send us an email. "
              "Please include as many details as possible so we can help you faster.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CineMindTheme.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => _sendSupportEmail(context),
              icon: const Icon(Icons.email_outlined, color: Colors.white),
              label: const Text(
                "Send Error Report",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
