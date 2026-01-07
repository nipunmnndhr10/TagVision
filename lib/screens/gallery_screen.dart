import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/screens/login_screen.dart';
import 'package:img_cls/utils/snack_bar.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery Screen"),
        actions: [
          IconButton(
            onPressed: () {
              auth
                  .signOut()
                  .then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  })
                  .onError((error, stackTrace) {
                    ShowPopup.showError(context, error.toString());
                  });
            },
            icon: Icon(Icons.logout),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
