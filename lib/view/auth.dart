import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/transfer.dart';
import 'package:firebase_test/view/new_window.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authorization extends StatefulWidget {
  const Authorization({super.key});

  @override
  State<Authorization> createState() => _AuthorizationState();
}

class _AuthorizationState extends State<Authorization> {
  TextEditingController txtLogin = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtName = TextEditingController();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: skWidth * 0.7,
              height: skHeight * 0.15,
              child: TextField(
                controller: txtLogin,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
              ),
            ),
            SizedBox(
              width: skWidth * 0.7,
              height: skHeight * 0.15,
              child: TextField(
                controller: txtPassword,
                obscureText: _obscureText,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
                width: skWidth * 0.7,
                height: skHeight * 0.15,
                child: TextField(
                  controller: txtName,
                  decoration:
                      const InputDecoration(hintText: 'Имя пользователя'),
                )),
            ElevatedButton(
                onPressed: () async {
                  var user;
                  try {
                    user = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: txtLogin.text, password: txtPassword.text);
                    Navigator.pushNamed(context, NewWindow.routeName,
                        arguments: new Transfer(credential: user));
                  } on FirebaseAuthException catch (e) {
                    var bar;
                    bar = SnackBar(
                      duration: const Duration(seconds: 4),
                      content: Text(e.message.toString()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(bar);
                  }
                },
                child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: const Text(
                      'Войти',
                      style: TextStyle(fontSize: 22),
                    ))),
            ElevatedButton(
                onPressed: () async {
                  var bar;
                  try {
                    var user = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: txtLogin.text,
                      password: txtPassword.text,
                    );
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    var userPath = firestore
                        .collection('user')
                        .doc(user.user!.uid)
                        .collection('akkInfo');
                    await userPath.add({
                      'name': txtName.text,
                      'email': txtLogin.text,
                      'pswd': txtPassword.text,
                    });
                    bar = const SnackBar(
                      content: Text("You've successfuly signed up!"),
                      duration: Duration(seconds: 4),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(bar);
                  } on FirebaseAuthException catch (e) {
                    bar = SnackBar(
                      duration: const Duration(seconds: 4),
                      content: Text(e.message.toString()),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(bar);
                  }
                },
                child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(fontSize: 16),
                    ))),
            ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var uID = prefs.getString('uID') ?? '';
                  if (uID.isEmpty) {
                    var user = await signInAnonymously();
                    prefs.setString('uID', user.user!.uid);
                    Navigator.pushNamed(context, NewWindow.routeName,
                        arguments: Transfer(credential: user));
                  } else {
                    Navigator.pushNamed(context, NewWindow.routeName,
                        arguments: Transfer(userID: uID));
                  }
                },
                child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: const Text(
                      'Анонимно',
                      style: TextStyle(fontSize: 16),
                    ))),
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: skWidth * 0.7,
              child: GestureDetector(
                onTap: () async {
                  var link = ActionCodeSettings(
                    url:
                        'https://example.com/completeSignUp?email=${txtLogin.text}',
                    handleCodeInApp: true,
                    iOSBundleId: 'com.example.firebase_test',
                    androidPackageName: 'com.example.firebase_test',
                    androidInstallApp: true,
                    androidMinimumVersion: '10',
                  );
                  var bar;
                  try {
                    await FirebaseAuth.instance.sendSignInLinkToEmail(
                        email: txtLogin.text, actionCodeSettings: link);
                  } on FirebaseAuthException catch (e) {
                    bar = SnackBar(
                        duration: const Duration(seconds: 4),
                        content: Text(e.message.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(bar);
                  }
                },
                child: Center(
                  child: Text(
                    'Получить ссылку для регистрации',
                    style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        color: Colors.blue.shade900),
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  Future<UserCredential> signInAnonymously() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.signInAnonymously();
    return userCredential;
  }
}
