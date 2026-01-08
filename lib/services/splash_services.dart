import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/screens/gallery_screen.dart';
import 'package:img_cls/screens/galry_sc_altr.dart';
import 'package:img_cls/screens/home_screen.dart';
import 'package:img_cls/screens/login_screen.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final user = auth.currentUser; // curr user-> already logged in user detail

    if (user != null) {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GalleryScreen()),
        ),
      );
    } else {
      Timer(
        const Duration(seconds: 3),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        ),
      );
    }
  }
}
