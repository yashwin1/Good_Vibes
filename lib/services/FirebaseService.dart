import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final databaseRef = FirebaseDatabase.instance.reference();

  Future<String?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      await addUser();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> addUser() async{
    // databaseRef.push().set({'name': data, 'comment': 'A good season'});
    // String key = databaseRef.child('Users/').push().key;
    databaseRef.child('Users/${_auth.currentUser!.uid}').set({
      'uid': _auth.currentUser!.uid,
      'name': _auth.currentUser!.displayName,
      'email': _auth.currentUser!.email,
      'photo': _auth.currentUser!.photoURL,
    });
  }

}