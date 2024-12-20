import 'package:cloud_firestore/cloud_firestore.dart';

import '../utilities/auth_google.dart';
import 'model.dart';

class DiscussionInteractionDBManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = GoogleAuthService.user?.uid;
  final String collectionName = 'discussion_interactions';

  // Create a new discussion interaction
  Future<String> createDiscussionInteraction(
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
  Future<DiscussionUserInteraction?> getDiscussionInteraction(
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
  Stream<List<DiscussionUserInteraction>> getUserDiscussionInteractions() {
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
  Future<void> updateDiscussionInteraction(
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
  Future<void> deleteDiscussionInteraction(String documentId) async {
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
