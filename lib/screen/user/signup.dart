import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_books/services/colors.dart';
import 'package:your_books/services/firebase/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool inOrUp = false;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    TextEditingController emailCont = TextEditingController();
    TextEditingController senhaCont = TextEditingController();
    TextEditingController nomeCont = TextEditingController();

    InputDecoration nome = InputDecoration(
        labelText: "Nome",
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        suffixIcon: Icon(Icons.person));
    InputDecoration login = InputDecoration(
        labelText: "Email",
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        suffixIcon: Icon(Icons.email));
    InputDecoration senha = InputDecoration(
        labelText: "Senha",
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        suffixIcon: Icon(Icons.password));

    return Scaffold(
      body: Stack(children: [
        Hero(
          tag: "blueSquare",
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                gradient: verticalGradient,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            // child: const Center(
            //     child: Text(
            //   "YourBooks",
            //   style: TextStyle(fontSize: 20),
            // )),
          ),
        ),
        Container(
          padding: EdgeInsets.all(15),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                inOrUp
                    ? TextFormField(decoration: nome, controller: nomeCont)
                    : Container(),
                inOrUp ? const SizedBox(height: 10) : Container(),
                TextFormField(decoration: login, controller: emailCont),
                const SizedBox(height: 10),
                TextFormField(decoration: senha, controller: senhaCont),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            Size(width * 0.3, height * 0.06)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue[400]),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                      ),
                      child: Text(
                        inOrUp ? "Cadastro" : "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        //await FirebaseAuth.instance.signInAnonymously();
                        if (inOrUp) {
                          var resposta = await auth.signUp(
                              emailCont.text, senhaCont.text, nomeCont.text);
                          print(resposta);
                        } else {
                          var resposta =
                              await auth.signIn(emailCont.text, senhaCont.text);
                          print(resposta);
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Text(inOrUp ? "Cadastrar" : "Logar"),
                        Switch(
                            value: inOrUp,
                            onChanged: (newValue) {
                              setState(() {
                                inOrUp = newValue;
                              });
                              print(inOrUp);
                            }),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
