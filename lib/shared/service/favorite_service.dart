import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final CollectionReference userRef =
      FirebaseFirestore.instance.collection("users");

  CollectionReference favorites(String userId) {
    return userRef.doc(userId).collection('favorites');
  }

  // Add a favorite with timestamp
  Future<void> addFavorite(String userId, String mediaId, String type) async {
    await favorites(userId).doc(mediaId).set({
      'id': mediaId,
      'type': type,
      'addedAt':
          FieldValue.serverTimestamp(), // Firestore sets the current time
    });
  }

  // Remove a favorite
  Future<void> removeFavorite(String userId, String mediaId) async {
    await favorites(userId).doc(mediaId).delete();
  }

  // Check if a media is favorited
  Future<bool> checkIfFavorite(String userId, String mediaId) async {
    var docSnapShot = await favorites(userId).doc(mediaId).get();
    return docSnapShot.exists;
  }

  // Get all favorite TV shows
  Future<List<String>> getAllFavoriteTv(String userId) async {
    try {
      var querySnapshot = await favorites(userId)
          .where('type', isEqualTo: 'tv')
          .orderBy('addedAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return []; // return empty list to avoid spinner hang
    }
  }

  // Get all favorite movies
  Future<List<String>> getAllFavoriteMovie(String userId) async {
    try {
      var querySnapshot = await favorites(userId)
          .where('type', isEqualTo: 'movie')
          .orderBy('addedAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return []; // return empty list to avoid spinner hang
    }
  }
}
