/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isinitialized = false;

  static Future<void> _initSignin() async {
    if (!isinitialized) {
      await _googleSignIn.initialize(
          serverClientId:
              "562101504181-ppkujm9rltcpct40n5pte85eflnmvjud.apps.googleusercontent.com");

      isinitialized = true;
    }
  }

  //for signin

  static Future<UserCredential> signinWithGoogle() async {
    await _initSignin();
    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    if (account == null) {
      throw FirebaseAuthException(
          code: "SIGN IN ABORTED BY USER",
          message: "User did not complete the sign-in");
    }
    final idToken = account.authentication.idToken;
    final authClient = account.authorizationClient;

    GoogleSignInClientAuthorization? auth =
        await authClient.authorizationForScopes(['email', 'profile']);

    final accessToken = auth?.accessToken;
    if (accessToken == null) {
      final auth2 = await authClient.authorizationForScopes(
        ['email', 'profile'],
      );
      if (auth2?.accessToken == null) {
        throw FirebaseAuthException(
          code: "No Accesss Token",
          message: "Fail to retrive google access token",
        );
      }
      auth = auth2;
    }
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  //For Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
 */
