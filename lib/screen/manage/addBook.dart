import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:your_books/models/book.dart';
import 'package:your_books/services/firebase/firestore.dart';
import 'package:your_books/services/firebase/storage.dart';
import 'package:your_books/services/provider/localBooks.dart';

class AddBook extends StatefulWidget {
  const AddBook({Key? key}) : super(key: key);

  @override
  _AddBookState createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  late BannerAd myBanner;
  bool _isBannerAdReady = false;
  @override
  void initState() {
    super.initState();
    myBanner = BannerAd(
      adUnitId: 'ca-app-pub-5031113227566495/5781521749',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );
    myBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              if (_isBannerAdReady)
                Container(
                    height: double.parse(myBanner.size.height.toString()),
                    width: double.parse(myBanner.size.width.toString()),
                    child: AdWidget(ad: myBanner)),
              TextButton(
                child: const Text("Get File"),
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                          type: FileType.custom, allowedExtensions: ['pdf']);
                  if (result != null) {
                    print(result.paths);
                  }
                  setState(() {
                    loading = true;
                  });
                  try {
                    String? path =
                        await StorageApp().doUpload(File(result!.paths[0]!));
                    if (path != null) {
                      Book book = Book(
                          nome: result.paths[0]!
                              .split('/')
                              .last
                              .replaceAll(".pdf", ""),
                          link: path,
                          pag: 1);
                      await FirestoreApp()
                          .addBook(book, context)
                          .then((value) async {
                        await FirestoreApp().getBooks(context);
                        Provider.of<MyBooksProvider>(context, listen: false)
                            .getBooks();
                      });
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Upload concluído"),
                    ));
                  } catch (e) {
                    print(e);
                  }
                  setState(() {
                    loading = false;
                  });
                },
              ),
              if (loading) CircularProgressIndicator(),
            ],
          ),
        ));
  }
}
