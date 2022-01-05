import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:your_books/models/book.dart';
import 'package:your_books/services/firebase/firestore.dart';
import 'package:your_books/services/firebase/storage.dart';

class MyBooksProvider extends ChangeNotifier {
  List arquivos = [];
  List<Book> livros = [];
  bool loading = false;
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    while (_db == null) {
      _db = await initDb();
    }
    return _db!;
  }

  MyBooksProvider() {
    //initDb();
    getLocalFiles();
    getBooks();
  }

  Future getLocalFiles() async {
    arquivos = [];
    livros = [];
    Directory documents = await getApplicationDocumentsDirectory();
    Directory livrosGet =
        await Directory(documents.path + "/myBooks").create(recursive: true);
    await for (var arquivo in livrosGet.list()) {
      print(arquivo.absolute.path);
      arquivos.add(arquivo.absolute.path);
    }

    notifyListeners();
    return arquivos;
  }

  void changeState() {
    loading = !loading;
    notifyListeners();
  }

  Future initDb() async {
    Directory path = await getApplicationDocumentsDirectory();
    try {
      var opendb = await openDatabase(join(path.path, "yourBooks.db"),
          version: 1, onCreate: _createDb);
      return opendb;
    } catch (e) {
      print(e);
    }
    return "OK";
  }

  Future _createDb(Database odb, int version) async {
    await odb.execute(
        "CREATE TABLE Books(id TEXT primary key, nome TEXT, path TEXT, link TEXT, pag INTEGER)");
    print("Tebelas criadas");
  }

  Future addBook(Book book) async {
    var dbClient = await db;
    var books =
        await dbClient.rawQuery("SELECT * FROM Books where id=?", [book.id]);
    //print("Erro: Já existe ${books.toString()}");

    if (books.isEmpty) {
      await dbClient.insert("Books", {
        'id': book.id,
        'nome': book.nome,
        'path': book.path,
        'link': book.link,
        'pag': 0,
      });
      getBooks();
    } else {
      if (books[0]['pag'] != book.pag) {
        changePage(book.id!, book.pag);
        print("Alterando Pagina ${book.pag}");
        getBooks();
      } else {
        print("Erro: Já existe ${books.toString()}");
      }
    }
  }

  Future getBooks() async {
    livros = [];
    var dbClient = await db;
    var books = await dbClient.rawQuery("SELECT * FROM Books");
    for (var book in books) {
      print(book);
      if (book['path'] != null) {
        livros.add(Book.fromMap(book, book['id'].toString()));
      }
    }
    notifyListeners();
    return;
  }

  Future deleteBookDB(String id) async {
    var dbClient = await db;
    await dbClient.delete("Books", where: "id=?", whereArgs: [id]);
  }

  Future changePage(String id, int page) async {
    var dbClient = await db;

    await dbClient.update("Books", {'pag': page},
        where: "id=?", whereArgs: [id]);
    var ver = await dbClient.rawQuery("SELECT * FROM Books where id=?", [id]);
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      var pref = await SharedPreferences.getInstance();
      pref.setBool('initUpload', true);
    } else {}
    print(ver);
  }

  Future deleteBook(Book book) async {
    await StorageApp().deleteFile(book.link!);
    await FirestoreApp().deleteBook(book.id!);
    await deleteBookDB(book.id!);
    await getBooks();
  }
}
