import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:provider/provider.dart';
import 'package:your_books/models/book.dart';
import 'package:your_books/services/provider/localBooks.dart';

class HomeBook extends StatefulWidget {
  const HomeBook({Key? key, required this.livro}) : super(key: key);
  final Book livro;
  @override
  _HomeBookState createState() => _HomeBookState();
}

class _HomeBookState extends State<HomeBook> {
  @override
  Widget build(BuildContext context) {
    var books = Provider.of<MyBooksProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) async {
        await showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
              details.globalPosition.dx, details.globalPosition.dy, 0, 0),
          items: [
            PopupMenuItem(
              child: const Text("Apagar"),
              onTap: () {
                books.deleteBook(widget.livro);
              },
            )
          ],
          elevation: 8.0,
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blue[300],
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Column(
          children: [
            Container(
                height: (width / 1.3) * 0.7,
                child: PdfViewer.openFile(
                  widget.livro.path!,
                  params: const PdfViewerParams(
                    pageNumber: 1,
                  ),
                )),
            // Icon(
            //   Icons.auto_stories,
            //   size: 60,
            //   color: Colors.white,
            // ),
            Column(
              children: [Text(widget.livro.nome)],
            ),
          ],
        ),
      ),
    );
  }
}
