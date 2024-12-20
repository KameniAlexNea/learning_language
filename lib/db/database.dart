import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkUsernameAvailability(String username) async {
  try {
    // Check Firestore for existing username
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isEmpty;
  } catch (e) {
    return false;
  }
}

Future<void> createUser(String uid, String username, String email) {
  return FirebaseFirestore.instance.collection('users').doc(uid).set({
    'username': username,
    'email': email,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
  final data = FirebaseFirestore.instance.collection('users').doc(uid).get();
  return data;
}

Future<void> updateFirestoreUser(String userId, String displayName) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'displayName': displayName,
  });
}
