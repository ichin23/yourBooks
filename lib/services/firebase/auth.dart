import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  AuthProvider(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get nome => _auth.currentUser!.displayName;

  Future<String?> signIn(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      return "logado";
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp(String email, String senha, String nome) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      await FirebaseAuth.instance.currentUser!.updateDisplayName(nome);
      return "criado";
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future<String?> singOut() async {
    try {
      await _auth.signOut();
      return "deslogado";
    } on FirebaseException catch (e) {
      return e.message;
    }
  }
}
