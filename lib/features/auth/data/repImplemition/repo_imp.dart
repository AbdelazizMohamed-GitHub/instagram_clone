import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:instagram_app/core/errors/failure.dart';
import 'package:instagram_app/core/utils/routs.dart';
import 'package:instagram_app/features/auth/domain/repo/auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Either<AuthFailure, User>> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return left(AuthFailure('An unknown error occurred.'));
    }
  }

  @override
  Future<Either<AuthFailure, User>> registerWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return right(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return left(AuthFailure('An unknown error occurred.'));
    }
  }

  @override
  Future<void> signOut(context) async {
    await firebaseAuth.signOut();
    Navigator.pushReplacementNamed(context, AppRouter.loginScreenRoute);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
    // Navigator.pushReplacementNamed(context, AppRouter.loginScreenRoute);
  }

  @override
  Future<Either<AuthFailure, UserCredential>> loginWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;

        // استخدام Facebook credential للتسجيل في Firebase
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        return right(userCredential);
      }
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return left(AuthFailure('An unknown error occurred.'));
    }
    return left(AuthFailure('An unknown error occurred.'));
  }

}
