import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Book {
  late String? id;
  late String nome;
  late String? path;
  late String? link;
  late int pag;

  Book({this.id, required this.nome, this.path, this.link, required this.pag});

  Book.fromMap(Map<String, dynamic> data, String newId)
      : this(
          id: newId,
          nome: data['nome'],
          path: data["path"],
          link: data["link"],
          pag: data['pag'] ?? 1,
        );

  set setPath(String path) {
    this.path = path;
  }

  set setLink(String link) {
    this.link = link;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'link': link,
      'pag': pag,
    };
  }

  Map<String, dynamic> toUpload(BuildContext context) {
    return {
      'nome': nome,
      'link': link,
      'pag': pag,
      'userId': FirebaseAuth.instance.currentUser!.uid
    };
  }
}
