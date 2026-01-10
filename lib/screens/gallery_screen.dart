import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_cls/services/showConfirmDialog.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens/login_screen.dart'; // adjust path
import '../utils/snack_bar.dart'; // adjust path
import '../services/db_service.dart'; // ← new import

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();

  final _dbService = DbService(); // ← using our new service

  //!Image labeler
  ImageLabeler? labeler;

  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    labeler = ImageLabeler(options: ImageLabelerOptions());
  }

  @override
  void dispose() {
    labeler?.close();
    _dbService.closeDatabase(); // good practice
    super.dispose();
  }

  //! label Image Func
  Future<List<ImageLabel>> labelImage(String path) async {
    // InputImage inputImage = InputImage.fromFilePath(path);
    // List<ImageLabel> labels = await labeler!.processImage(
    //   inputImage,
    // ); // returns List<ImageLabel>
    // return labels;

    final inputImage = InputImage.fromFilePath(path);

    final List<ImageLabel> labels = await labeler!.processImage(inputImage);

    // 1. Filter by confidence > 0.5
    final filtered = labels.where((label) => label.confidence > 0.5).toList();

    // 2. Sort by confidence descending
    filtered.sort((a, b) => b.confidence.compareTo(a.confidence));

    // 3. Take top 5
    return filtered.take(5).toList();
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await _dbService.getAllPhotos();
      // print(photos);
      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ShowPopup.showError(context, "Failed to load photos");
      }
    }
  }

  Future<void> _pickAndSaveImage() async {
    // 1. Permission
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) {
        ShowPopup.showError(context, "Photos permission is required");
      }
      return;
    }

    // 2. Pick image
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // 3. Get private photos folder & create unique name
      final photosDirPath = await _dbService.getPhotosDirectoryPath();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = '$photosDirPath/$fileName';

      // 4. Copy file to our safe location
      await File(image.path).copy(newPath);

      // 5. Save path to database
      await _dbService.insertPhoto(newPath);

      final labels = await labelImage(newPath);

      for (final label in labels) {
        print('${label.label} (${label.confidence})');
      }

      // 6. Refresh UI
      await _loadPhotos();

      if (mounted) {
        ShowPopup.showSuccess(context, "Photo saved successfully");
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
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
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
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final filePath = photo['file_path'] as String;
                final int photoId = photo['id'] as int;

                return GestureDetector(
                  onLongPress: () async {
                    // Show the reusable confirmation dialog
                    final bool confirmed = await ShowConfirmDialog.show(
                      context,
                      title: "Delete Photo?",
                      content: "Are you sure you want to delete this Photo?",
                      cancelText: "Cancel",
                      confirmText: "Delete",
                    );

                    if (confirmed) {
                      // User confirmed → delete the task
                      // Delete from DB
                      await _dbService.deletePhoto(photoId);

                      // Delete from disk
                      final file = File(filePath);
                      if (await file.exists()) {
                        await file.delete();
                      }
                    }

                    // Refresh UI
                    setState(() {
                      _photos = List<Map<String, dynamic>>.from(_photos)
                        ..removeAt(index);
                    });
                  },

                  child: ClipRRect(
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
                  ),
                );
              },
            ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ShowPopup.showError(context, e.toString());
      }
    }
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
}
