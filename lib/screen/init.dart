import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:your_books/components/books/homeBook.dart';
import 'package:your_books/screen/manage/addBook.dart';
import 'package:your_books/screen/view.dart';
import 'package:your_books/services/firebase/auth.dart';
import 'package:your_books/services/firebase/firestore.dart';
import 'package:your_books/services/provider/localBooks.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late Animation anim;
  late AnimationController animCont;

  Tween<double> slide = Tween(begin: 100, end: 0);

  @override
  void initState() {
    super.initState();

    Provider.of<MyBooksProvider>(context, listen: false);

    animCont = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    anim = slide.animate(animCont)
      ..addListener(() {
        setState(() {});
      });

    animCont.forward();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getBooks(context));
  }

  Future getBooks(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    SharedPreferences pref = await SharedPreferences.getInstance();
    var bolle = pref.getBool('initUpload');
    print(bolle);
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      if (bolle != null) {
        if (bolle) {
          print("UPLOAD DE DADOS");
          FirestoreApp().updateBooks(context);
          pref.setBool('initUpload', false);
        }
      }
      print("Download DE DADOS");
      await FirestoreApp().getBooks(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    MyBooksProvider books = Provider.of<MyBooksProvider>(context);
    AuthProvider authProv = Provider.of<AuthProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              "Bem vindo, ${authProv.nome.toString()}",
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AddBook()));
            },
            leading: const Icon(Icons.book),
            title: const Text("Adicionar Livro"),
          ),
          ListTile(
            onTap: () {
              authProv.singOut();
            },
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Sair"),
          ),
        ],
      )),
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: "blueSquare",
                child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 10,
                      right: 10),
                  height: height * 0.3,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    gradient: LinearGradient(
                        colors: [Colors.blue[300]!, Colors.blue[700]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                  child: Center(
                      child: Container(
                    padding:
                        EdgeInsets.only(top: anim.isCompleted ? 0 : anim.value),
                    child: const Text(
                      "Bem-Vindo! O que vamos ler hoje?!",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  )),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 10,
                      right: 10),
                  child: IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                        //Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu)))
            ],
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: height -
                  (height * 0.3) -
                  (MediaQuery.of(context).padding.bottom +
                      MediaQuery.of(context).padding.top),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: width / (height / 1.3),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: books.livros.length,
                itemBuilder: (builder, i) => GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PdfView(book: books.livros[i])));

                    await books.getBooks();
                    print(books.livros[i].toMap().toString());
                    // pri]AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAA\nAAAAAAAAA\nAAAAAAAA\nSAAAAAAAAAAAAAAAA");
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    print(connectivityResult);
                    if (connectivityResult != ConnectivityResult.none) {
                      FirestoreApp().updateBooks(context);
                    }
                  },
                  child: HomeBook(
                    livro: books.livros[i],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
