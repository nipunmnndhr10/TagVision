import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_cls/data/notifiers.dart';
import 'package:img_cls/utils/showConfirmDialog.dart';
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

  List<Map<String, dynamic>> _photos = []; // all loaded photos
  List<Map<String, dynamic>> _filteredPhotos = []; // displayed ones
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    labeler = ImageLabeler(options: ImageLabelerOptions());

    // !listen to search changes
    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();

      setState(() {
        _searchQuery = query;

        if (query.isEmpty) {
          _filteredPhotos = List.from(_photos);
        } else {
          _filteredPhotos = _photos.where((photo) {
            final tagStr =
                (photo['tag'] as String?) ??
                ''; // fetch tags column from that photo

            final normalizedTags = tagStr
                .toLowerCase()
                .split(',')
                .map((e) => e.trim())
                .join(',');

            return normalizedTags.contains(
              query,
            ); // if the tag of photo contains query then returns true -> and keeps the photo in the filtered list
          }).toList();
        }
      });
    });
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
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final photos = await _dbService.getAllPhotos(userId: uid);
      print(photos);
      if (mounted) {
        setState(() {
          _photos = photos;
          _filteredPhotos = List.from(
            _photos,
          ); //creates a new copy of the _photos lis
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
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final int photoId = await _dbService.insertPhoto(newPath, userId: uid);

      final List<ImageLabel> labels = await labelImage(newPath);

      // for assurance
      for (final label in labels) {
        print('${label.label} (${label.confidence})');
      }
      print("SUCCESSFUL Image labelling:");

      // converting list of labels into one whole comma separated string
      final String labelString = labels
          .map((l) => l.label)
          .join(','); // "cat,outdoor,sunset"

      // inserting the comma separated tags into the tag col
      await _dbService.updatePhotoTag(photoId, labelString, userId: uid);

      // for assurance
      print("UPDATED IMAGE TAG COLUMN");

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
            onPressed: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode);
              },
            ),
          ),

          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Add new photo',
            onPressed: _pickAndSaveImage,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _handleLogout),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search image by tags (dog, beach, food...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                // filter query
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPhotos.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _filteredPhotos.length,
                    itemBuilder: (context, index) {
                      final photo = _filteredPhotos[index];
                      final filePath = photo['file_path'] as String;
                      final int photoId = photo['id'] as int;

                      return GestureDetector(
                        onLongPress: () async {
                          // Show the reusable confirmation dialog
                          final bool confirmed = await ShowConfirmDialog.show(
                            context,
                            title: "Delete Photo?",
                            content:
                                "Are you sure you want to delete this Photo?",
                            cancelText: "Cancel",
                            confirmText: "Delete",
                          );

                          if (confirmed) {
                            // User confirmed → delete the task
                            // Delete from DB (only for current user)
                            final String uid =
                                FirebaseAuth.instance.currentUser!.uid;
                            await _dbService.deletePhoto(photoId, userId: uid);

                            // Delete from disk
                            final file = File(filePath);
                            if (await file.exists()) {
                              await file.delete();
                            }
                            // Refresh UI
                            setState(() {
                              _photos = List<Map<String, dynamic>>.from(_photos)
                                ..removeWhere((p) => p['id'] == photoId);

                              _filteredPhotos = List<Map<String, dynamic>>.from(
                                _filteredPhotos,
                              )..removeWhere((p) => p['id'] == photoId);
                            });
                          }
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
          ),
        ],
      ),
    );
  }

  Future<void> _filterPhotos(String query) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final photos = await _dbService.getAllPhotos(userId: uid);
  }

  Future<void> _handleLogout() async {
    ShowConfirmDialog.show(
      context,
      title: "Logout",
      content: "Are you sure you want to logout?",
      cancelText: "Cancel",
      confirmText: "Logout",
    ).then((confirmed) async {
      if (confirmed) {
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
    });
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
