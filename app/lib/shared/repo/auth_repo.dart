import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> resetUserData(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Reset'),
      content: const Text(
          'Are you sure you want to delete all your data? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: Colors.red),
    ),
  );

  try {
    final favorites = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');
    final watchList = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist');
    final snapshotsFavorite = await favorites.get();

    for (var doc in snapshotsFavorite.docs) {
      await doc.reference.delete();
    }
    final snapshotsWatchList = await watchList.get();

    for (var doc in snapshotsWatchList.docs) {
      await doc.reference.delete();
    }

    Navigator.pop(context); // close loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All your data has been deleted.'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    Navigator.pop(context); // close loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to reset data: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
