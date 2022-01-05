import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:your_books/models/book.dart';
import 'package:your_books/services/firebase/storage.dart';
import 'package:your_books/services/provider/localBooks.dart';

class FirestoreApp {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> addBook(Book book, BuildContext context,
      {String? nome, String? link}) async {
    try {
      firestore
          .collection('books')
          // .withConverter<Book>(
          //     fromFirestore: (snap, _) => Book.fromMap(snap.data()!, snap.id),
          //     toFirestore: (book, _) => book.toMap())
          .doc()
          .set(book.toUpload(context));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future deleteBook(String id) async {
    await firestore.collection("books").doc(id).delete();
  }

  Future updateBooks(BuildContext context) async {
    //await context.read<MyBooksProvider>().getBooks();
    var booksCole = firestore.collection("books").withConverter<Book>(
        fromFirestore: (snap, _) => Book.fromMap(snap.data()!, snap.id),
        toFirestore: (book, _) => book.toMap());
    // var livros = Provider.of<MyBooksProvider>(context, listen: false).livros;
    var livros = context.read<MyBooksProvider>().livros;
    print(livros);
    for (var livro in livros) {
      print(livro.toMap()['pag']);
      await booksCole
          .doc(livro.id)
          .set(livro, SetOptions(merge: true))
          .then((value) {
        print("OK: " + livro.toMap().toString());
      });
    }
    print("SUCESO NO UPDATE");
  }

  Future updateBook(BuildContext context, Book livro) async {}

  Future getBooks(BuildContext context) async {
    var livros = await firestore
        .collection("books")
        .withConverter<Book>(
            fromFirestore: (snap, _) => Book.fromMap(snap.data()!, snap.id),
            toFirestore: (book, _) => book.toMap())
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => value.docs);

    for (var livro in livros) {
      //print(livro.data()['link']);
      Book book = livro.data();
      if (book.link != null) {
        print(book.link);
        StorageApp storage = StorageApp();
        var docs = await getApplicationDocumentsDirectory();
        var livroPath =
            Directory(join(docs.path, "myBooks", livro.data().nome));
        if (!await livroPath.exists()) {
          String path = await storage.downloadFile(book.link!);
          print(path);

          book.setPath = path;
        } else {
          book.setPath = livroPath.path;
        }
        Provider.of<MyBooksProvider>(context, listen: false).addBook(book);
      }
    }
    for (var livro
        in Provider.of<MyBooksProvider>(context, listen: false).livros) {
      if (!livros.any((element) => livro.id == element.data().id)) {
        Provider.of<MyBooksProvider>(context, listen: false)
            .deleteBookDB(livro.id!);
        Provider.of<MyBooksProvider>(context, listen: false).getBooks();
      }
    }
  }
}
