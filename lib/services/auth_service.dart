import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      print("===== MULAI PROSES LOGIN GOOGLE =====");
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        print("Memulai login popup untuk web...");
        UserCredential userCredential = await _auth.signInWithPopup(
          GoogleAuthProvider(),
        );
        print("Login web berhasil: ${userCredential.user?.displayName}");
        return userCredential.user;
      } else {
        print("Memulai GoogleSignIn.signIn() untuk mobile...");
        googleUser = await _googleSignIn.signIn();
        print(
            "Hasil GoogleSignIn.signIn(): ${googleUser?.displayName ?? 'null'}");
      }

      if (googleUser == null && !kIsWeb) {
        Navigator.pop(context);
        print('Login Google dibatalkan oleh pengguna.');
        return null;
      }

      if (!kIsWeb) {
        print("Mendapatkan autentikasi dari googleUser...");
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;
        print(
            "Token akses diterima: ${googleAuth.accessToken?.substring(0, 10)}...");
        print("ID token diterima: ${googleAuth.idToken?.substring(0, 10)}...");

        print("Membuat kredensial Firebase...");
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print("Menjalankan signInWithCredential...");
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;
        print("Hasil signInWithCredential: ${user?.displayName ?? 'null'}");

        Navigator.pop(context);

        if (user != null) {
          print('Berhasil login dengan Google: ${user.displayName}');
          print('Email: ${user.email}');
          print('User ID: ${user.uid}');

          Navigator.pushReplacementNamed(context, '/main');
          return user;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) Navigator.pop(context);

      print('===== ERROR FIREBASE AUTH =====');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('StackTrace: ${e.stackTrace}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      print('===== ERROR UMUM LOGIN GOOGLE =====');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('StackTrace: ${StackTrace.current}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print("Google Sign-Out berhasil");

      await _auth.signOut();
      print("Firebase Auth Sign-Out berhasil");

      await _auth.authStateChanges().first;
      print("AuthState berhasil diperbarui");
    } catch (e) {
      print("Error saat logout: $e");
      rethrow;
    }
  }
}
