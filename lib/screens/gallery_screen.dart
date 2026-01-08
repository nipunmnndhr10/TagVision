// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:img_cls/screens/login_screen.dart';
// import 'package:img_cls/utils/snack_bar.dart';

// class GalleryScreen extends StatefulWidget {
//   const GalleryScreen({super.key});

//   @override
//   State<GalleryScreen> createState() => _GalleryScreenState();
// }

// class _GalleryScreenState extends State<GalleryScreen> {
//   final auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Gallery Screen"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               auth
//                   .signOut()
//                   .then((value) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   })
//                   .onError((error, stackTrace) {
//                     ShowPopup.showError(context, error.toString());
//                   });
//             },
//             icon: Icon(Icons.logout),
//           ),
//           SizedBox(width: 20),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../screens/login_screen.dart'; // adjust path if needed
import '../utils/snack_bar.dart'; // your custom snackbar

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker(); // for image selection

  Database? _database; // nullable SQLite DB instance
  List<Map<String, dynamic>> _photos =
      []; // list of maps to hold DB Query result as maps
  bool _isLoading = true;

  // initState runs once when the state is created - perfect for one-time setup like opening the DB.
  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // ────────────────────────────────
  // 1. Initialize SQLite Database
  // ────────────────────────────────
  Future<void> _initDatabase() async {
    final databasesPath =
        await getApplicationDocumentsDirectory(); // get app's document directory
    final pathToDb = path.join(
      databasesPath.path,
      'gallery.db',
    ); // build the database path - inside the app's doc path

    // open or create database
    _database = await openDatabase(
      pathToDb,
      version: 1,
      // callback func that runs SQL only on first create - creates SQL table
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );

    await _loadPhotos();
  }

  // ────────────────────────────────
  // 2. Load all saved photos from DB
  // ────────────────────────────────
  Future<void> _loadPhotos() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> maps = await _database!.query(
      'photos',
      orderBy: 'created_at DESC',
    );

    setState(() {
      _photos = maps;
      _isLoading = false;
    });
  }

  // ────────────────────────────────
  // 3. Pick image → copy → save path to DB
  // ────────────────────────────────
  Future<void> _pickAndSaveImage() async {
    // Request permission
    var status = await Permission.photos.request();
    // if user did not allow permission
    if (!status.isGranted) {
      if (mounted) {
        ShowPopup.showError(context, "Storage permission is required");
      }
      return;
    }

    try {
      // xfile nullable cause user might not choose a file
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Create photos folder inside app documents
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(appDir.path, 'photos'));
      // create photos direc (to store imported photo's path) if doesn't exists
      if (!await photosDir.exists()) {
        await photosDir.create(
          recursive: true,
        ); // recursvtrue: Safe even if intermediate folders don’t exist. creates parent direc if missing
      }

      // Generate unique filename[]
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = path.join(photosDir.path, fileName);

      // Copy original image to our private directory
      await File(image.path).copy(newPath);

      // Save path to SQLite
      await _database!.insert('photos', {
        'file_path': newPath,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Refresh UI
      await _loadPhotos();

      if (mounted) {
        ShowPopup.showSuccess(context, "Photo added successfully");
      }
    } catch (e) {
      if (mounted) {
        ShowPopup.showError(context, "Error adding photo: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Add new photo',
            onPressed: _pickAndSaveImage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await _auth.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ShowPopup.showError(context, e.toString());
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),

              itemCount: _photos.length,
              // core logic: called once per visible grid item
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final filePath = photo['file_path'] as String;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(filePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            "Your gallery is empty",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add your first photo"),
            onPressed: _pickAndSaveImage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
