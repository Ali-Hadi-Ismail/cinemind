import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistService {
  CollectionReference userRef = FirebaseFirestore.instance.collection("users");

  CollectionReference watchlist(String userid) =>
      userRef.doc(userid).collection("watchlist");

  Future<void> addToWatchlist(
      String userId, String mediaType, String mediaId) async {
    await watchlist(userId).doc(mediaId).set({
      "type": mediaType,
      "addedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromWatchList(String mediaId, String userId) async {
    await watchlist(userId).doc(mediaId).delete();
  }

  Future<bool> checkIfWatchList(String mediaId, String userId) async {
    DocumentSnapshot docSnapShot = await watchlist(userId).doc(mediaId).get();
    return docSnapShot.exists;
  }

  Future<List<String>> getMovieToWatchList(
      String type, String mediaId, String userId) async {
    var querySnapShot = await watchlist(userId)
        .where("type", isEqualTo: type)
        .orderBy("addedAt", descending: true)
        .get();
    return querySnapShot.docs.map((e) => e.id).toList();
  }

  Future<List<String>> getTvToWatchList(
      String type, String mediaId, String userId) async {
    var querySnapShot = await watchlist(userId)
        .where("type", isEqualTo: type)
        .orderBy("addedAt", descending: true)
        .get();
    return querySnapShot.docs.map((e) => e.id).toList();
  }
}
