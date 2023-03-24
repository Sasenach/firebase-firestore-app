import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Transfer {
  UserCredential? credential;
  String? userID;
  Transfer({this.credential, this.userID});
}
