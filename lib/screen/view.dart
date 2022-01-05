import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:provider/provider.dart';
//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:your_books/models/book.dart';
import 'package:your_books/services/provider/localBooks.dart';

class PdfView extends StatefulWidget {
  const PdfView({Key? key, required this.book}) : super(key: key);
  final Book book;
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  PdfViewerController controllerPdf = PdfViewerController();
  int pages = 0;
  bool init = false;
  //final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  int atualPage = 0;
  bool change = true;

  @override
  void initState() {
    super.initState();
    if (widget.book.pag == 0) {
      widget.book.pag = 1;
    }
    controllerPdf.addListener(() {
      Provider.of<MyBooksProvider>(context, listen: false)
          .changePage(widget.book.id!, controllerPdf.currentPageNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.path!.split("/").last),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
            ),
            onPressed: () {
              // _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: PdfViewer.openFile(widget.book.path!,
          viewerController: controllerPdf,
          params: PdfViewerParams(
            // pageDecoration: BoxDecoration(color: Colors.red),
            pageNumber: widget.book.pag,
          )),
    );
  }
}
