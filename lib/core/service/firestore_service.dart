// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:instagram_app/core/service/storge_service.dart';
import 'package:instagram_app/features/auth/data/model/user_model.dart';
import 'package:instagram_app/features/home/data/models/comment_model.dart';
import 'package:instagram_app/features/home/data/models/post_model.dart';

class FireStoreService {
   FirebaseFirestore firestore;
   FirebaseAuth auth ;
  FireStoreService({
    required this.firestore,
    required this.auth,
  });

   Future<void> updateUserProfileWithImage({
    required String username,
    required Uint8List imageFile,
    required String bio,
  }) async {
    DocumentSnapshot doc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    UserModel user = UserModel.toGetData(doc);

    if (user.profilePictureUrl != '') {
      
      await StorgeService.deleteImage(user.profilePictureUrl!);
    }

    String imageUrl = await StorgeService.uploadImage(
      image: imageFile,
      floderName: "users",
    );

    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'username': username,
      'profilePictureUrl': imageUrl,
      'bio': bio,
    });
    QuerySnapshot snapshot = await firestore
        .collection('posts')
        .where('userId', isEqualTo: auth.currentUser!.uid)
        .get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Create a reference to each post document
      await firestore.collection('posts').doc(doc.id).update({
        'username': username,
        'profilePictureUrl': imageUrl,
      });
    }
  }

   Future<void> updateUserProfile({
    required String username,
    required String bio,
  }) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'username': username,
      'bio': bio,
    });
    QuerySnapshot snapshot = await firestore
        .collection('posts')
        .where('userId', isEqualTo: auth.currentUser!.uid)
        .get();
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Create a reference to each post document
      await firestore.collection('posts').doc(doc.id).update({
        'username': username,
      });
    }
  }

   Future<void> followUser({
    required List following,
    required String userId,
  }) async {
    try {
      if (following.contains(userId)) {
        // Unfollow the user

        await firestore.collection('users').doc(auth.currentUser!.uid).update({
          'following': FieldValue.arrayRemove([userId])
        });

        await firestore.collection('users').doc(userId).update({
          'followers': FieldValue.arrayRemove([auth.currentUser!.uid])
        });
      }
      //  if (!following.contains(userId))
      else {
        // Follow the user
        await firestore.collection('users').doc(auth.currentUser!.uid).update({
          'following': FieldValue.arrayUnion([userId])
        });

        await firestore.collection('users').doc(userId).update({
          'followers': FieldValue.arrayUnion([auth.currentUser!.uid])
        });
      }
    } catch (e) {
      // You may want to handle errors more gracefully in a real app
    }
  }

   Future<UserModel> getUserData({required String userId}) async {
    DocumentSnapshot doc =
        await firestore.collection('users').doc(userId).get();

    UserModel user = UserModel.toGetData(doc);

    return user;
  }

   Future<void> addPost(
      {required String caption, required Uint8List imageFile}) async {
    DocumentSnapshot doc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    UserModel user = UserModel.toGetData(doc);
    var postId = const Uuid().v1();
    String imageUrl =
        await StorgeService.uploadImage(image: imageFile, floderName: 'Posts');
    PostModel post = PostModel(
        postId: postId,
        userId: user.id,
        likes: [],
        caption: caption,
        timestamp: Timestamp.now(),
        imageUrl: imageUrl,
        username: user.username,
        profilePictureUrl: user.profilePictureUrl);
    firestore.collection('posts').doc(postId).set(post.toMap());
  }

   Future<void> likePosts(
      {required String postId,
      required String uId,
      required List likes}) async {
    if (likes.contains(uId)) {
      firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([uId])
      });
    } else {
      firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uId])
      });
    }
  }

   Future<void> deletePost(
      {required String postId, required String imagUrl}) async {
    await firestore.collection('posts').doc(postId).delete();
    await StorgeService.deleteImage(imagUrl);
  }

   Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    var cId = const Uuid().v1();
    DocumentSnapshot doc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    UserModel user = UserModel.toGetData(doc);
    CommentModel comments = CommentModel(
        commentId: cId,
        postId: postId,
        userId: user.id,
        username: user.username,
        profilePictureUrl: user.profilePictureUrl,
        comment: comment,
        timestamp: Timestamp.now());
    firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(cId)
        .set(comments.toMap());
  }

   Future<void> deleteComments(
      {required String postId, required String cId}) async {
    await firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(cId)
        .delete();
  }
}
