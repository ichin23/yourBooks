import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_books/screen/init.dart';
import 'package:your_books/screen/user/signup.dart';
import 'package:your_books/services/firebase/auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:your_books/services/provider/localBooks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  // var connectivityResult = await (Connectivity().checkConnectivity());

  User? user;
  FirebaseAuth.instance.userChanges().listen((User? updateUser) {
    if (user == null) {
      user = null;
    } else {
      user = updateUser;
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyBooksProvider()),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) => context.read<AuthProvider>().authStateChanges,
            initialData: null)
      ],
      child: Builder(builder: (context) {
        return MaterialApp(
            title: "Your Books",
            home: FutureBuilder(
                future: context.watch<MyBooksProvider>().db,
                builder: (context, snapshot) {
                  // Provider.of<MyBooksProvider>(context).getBooks();
                  if (snapshot.connectionState == ConnectionState.done) {
                    return context.watch<User?>() == null
                        ? const SignUpScreen()
                        : const MyApp();
                  } else {
                    return const LinearProgressIndicator();
                  }
                }));
      }),
    ),
  );
}
