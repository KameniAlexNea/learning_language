import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_google.dart';
import 'model.dart';

class UserDBManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String collectionName = 'users';

  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      // Check Firestore for existing username
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<void> createUser(String uid, String username, String email) {
    return _firestore.collection(collectionName).doc(uid).set({
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    final data = _firestore.collection(collectionName).doc(uid).get();
    return data;
  }

  static Future<void> updateFirestoreUser(
      String userId, String displayName) async {
    await _firestore.collection(collectionName).doc(userId).update({
      'displayName': displayName,
    });
  }
}

class DiscussionInteractionDBManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String? userId = GoogleAuthService.user?.uid;
  static final String collectionName = 'discussion_interactions';

  // Create a new discussion interaction
  static Future<String> createDiscussionInteraction(
      DiscussionInteraction interaction) async {
    try {
      if (userId == null) {
        throw Exception('User must be logged in to create an interaction');
      }

      // Convert the interaction to JSON and add user ID and timestamp
      final data = {
        ...interaction.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore and get the document reference
      final DocumentReference docRef =
          await _firestore.collection(collectionName).add(data);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create discussion interaction: $e');
    }
  }

  // Get a single discussion interaction by ID
  static Future<DiscussionUserInteraction?> getDiscussionInteraction(
      String documentId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(documentId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return DiscussionUserInteraction.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get discussion interaction: $e');
    }
  }

  // Get all discussion interactions for the current user
  static Stream<List<DiscussionUserInteraction>>
      getUserDiscussionInteractions() {
    if (userId == null) {
      throw Exception('User must be logged in to get interactions');
    }

    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiscussionUserInteraction.fromJson(doc.data()))
            .toList());
  }

  // Update an existing discussion interaction
  static Future<void> updateDiscussionInteraction(
    String documentId,
    DiscussionInteraction updatedInteraction,
  ) async {
    try {
      if (userId == null) {
        throw Exception('User must be logged in to update an interaction');
      }

      // Get the existing document
      final DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(documentId).get();

      if (!doc.exists) {
        throw Exception('Discussion interaction not found');
      }

      // Verify the user owns this interaction
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        throw Exception(
            'User does not have permission to update this interaction');
      }

      // Update the document
      await _firestore.collection(collectionName).doc(documentId).update({
        ...updatedInteraction.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update discussion interaction: $e');
    }
  }

  // Delete a discussion interaction
  static Future<void> deleteDiscussionInteraction(String documentId) async {
    try {
      if (userId == null) {
        throw Exception('User must be logged in to delete an interaction');
      }

      // Get the document
      final DocumentSnapshot doc =
          await _firestore.collection(collectionName).doc(documentId).get();

      if (!doc.exists) {
        throw Exception('Discussion interaction not found');
      }

      // Verify the user owns this interaction
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        throw Exception(
            'User does not have permission to delete this interaction');
      }

      // Delete the document
      await _firestore.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete discussion interaction: $e');
    }
  }
}
