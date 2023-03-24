import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/transfer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewWindow extends StatefulWidget {
  const NewWindow({super.key});
  static const routeName = '/PageMain';
  @override
  State<NewWindow> createState() => _NewWindowState();
}

class _NewWindowState extends State<NewWindow> {
  bool isEditMode = false;
  var selectedTaskId = '';
  TextEditingController txtName = TextEditingController();
  TextEditingController txtContent = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final double skWidth = MediaQuery.of(context).size.width;
    final double skHeight = MediaQuery.of(context).size.height;
    final args = ModalRoute.of(context)!.settings.arguments as Transfer;
    String uID = args.userID ?? args.credential!.user!.uid;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isEditMode) {
            setState(() {
              if (txtName.text != "" && txtContent.text != "") {
                var firestore = FirebaseFirestore.instance;
                var taskPath =
                    firestore.collection('user').doc(uID).collection('tasks');
                var creationDate =
                    DateFormat('dd.MM.yyyy hh:mm').format(DateTime.now());

                taskPath.doc(selectedTaskId).set({
                  'name': txtName.text,
                  'content': txtContent.text,
                  'date': creationDate.toString()
                });
                isEditMode = false;
              } else {
                var bar = const SnackBar(
                  content: Text('Заполните все поля'),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(bar);
              }
            });
          } else {
            setState(() {
              if (txtName.text != "" && txtContent.text != "") {
                var firestore = FirebaseFirestore.instance;
                var taskPath =
                    firestore.collection('user').doc(uID).collection('tasks');
                var creationDate =
                    DateFormat('dd.MM.yyyy hh:mm').format(DateTime.now());

                taskPath.add({
                  'name': txtName.text,
                  'content': txtContent.text,
                  'date': creationDate.toString()
                });
                txtContent.text = '';
                txtName.text = '';
              } else {
                var bar = const SnackBar(
                  content: Text('Заполните все поля'),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(bar);
              }
            });
          }
        },
        child: isEditMode == false
            ? const Icon(Icons.add_circle_outline_rounded)
            : const Icon(Icons.edit_calendar_outlined),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: double.infinity,
                height: skHeight * 0.15,
                child: TextField(
                  controller: txtName,
                  decoration:
                      const InputDecoration(hintText: 'Название заметки'),
                )),
            SizedBox(
                width: double.infinity,
                height: skHeight * 0.15,
                child: TextField(
                  controller: txtContent,
                  decoration:
                      const InputDecoration(hintText: 'Содержание заметки'),
                )),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(uID)
                    .collection('tasks')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs
                        .map((task) => ListTile(
                              onLongPress: () async {
                                var firestore = FirebaseFirestore.instance;
                                var taskPath = firestore
                                    .collection('user')
                                    .doc(uID)
                                    .collection('tasks');
                                await taskPath.doc(task.id).delete();
                              },
                              title: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.yellow.shade300,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onDoubleTap: () {
                                      setState(() {
                                        txtName.text = task.get('name');
                                        txtContent.text = task.get('content');
                                        isEditMode = true;
                                        selectedTaskId = task.id;
                                      });
                                    },
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Center(
                                            child: Text(
                                              task.get('name'),
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          Text(
                                            task.get('content'),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(task.get('date'))),
                                        ]),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            )
          ],
        ),
      )),
    );
  }
}
