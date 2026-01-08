import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/data/notifiers.dart';
import 'package:img_cls/screens/login_screen.dart';
import 'package:img_cls/utils/snack_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Widget _buildAiTaggingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2D2D2D),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.auto_awesome, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('AI Tagging...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Icon(Icons.photo_album, size: 32),
        ),
        title: const Text(
          'TagVision',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          SizedBox(width: 5),
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
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for your image here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷️ Tag Chips (horizontal scroll)
          // SizedBox(
          //   height: 40,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     children: const [
          //       TagChip(label: 'dog', selected: true),
          //       TagChip(label: 'food'),
          //       TagChip(label: 'nature'),
          //       TagChip(label: 'travel'),
          //       TagChip(label: 'cat'),
          //       TagChip(label: 'pizza'),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: 16),

          // // 🖼️ Image Grid
          // Expanded(
          //   child: GridView.count(
          //     crossAxisCount: 2,
          //     crossAxisSpacing: 8,
          //     mainAxisSpacing: 8,
          //     padding: const EdgeInsets.symmetric(horizontal: 8),
          //     childAspectRatio: 0.85,
          //     children: [
          //       ...mockImages.map((img) => ImageCard(image: img)).toList(),
          //       HomeScreen._buildAiTaggingCard(),
          //     ],
          //   ),
          // ),

          // // 📊 Bottom Stats Bar
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFF1E1E1E),
          //     border: Border(top: BorderSide(color: Colors.grey.shade800!)),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: const [
          //       Text('12 photos • ', style: TextStyle(color: Colors.grey)),
          //       Text(
          //         '3 tagged today',
          //         style: TextStyle(
          //           color: Colors.blue,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// // 🏷️ Reusable Tag Chip
// class TagChip extends StatelessWidget {
//   final String label;
//   final bool selected;

//   const TagChip({super.key, required this.label, this.selected = false});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 8.0),
//       child: FilterChip(
//         label: Text(label),
//         selected: selected,
//         onSelected: (_) {},
//         showCheckmark: false,
//         selectedColor: Colors.blue[700],
//         backgroundColor: const Color(0xFF2D2D2D),
//         labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey),
//       ),
//     );
//   }
// }

// // 🖼️ Image Card with Tag & Confidence
// class ImageCard extends StatelessWidget {
//   final MockImage image;

//   const ImageCard({super.key, required this.image});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Stack(
//         children: [
//           // Image
//           Image.network(
//             image.url,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),

//           // Confidence badge (top-right)
//           Positioned(
//             top: 8,
//             right: 8,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text(
//                 '${image.confidence}%',
//                 style: const TextStyle(color: Colors.white, fontSize: 10),
//               ),
//             ),
//           ),

//           // Tags overlay (bottom)
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [Color(0xCC000000), Color(0x00000000)],
//                 ),
//               ),
//               child: Text(
//                 image.tags,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // 🧪 Mock Data
// class MockImage {
//   final String url;
//   final String tags;
//   final int confidence;

//   MockImage({required this.url, required this.tags, required this.confidence});
// }

// final List<MockImage> mockImages = [
//   MockImage(
//     url:
//         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsN7dZrWMxZNc9ySZRwWlztSZjsV4TlSVCFa77QrTgen01wafzLNF7xacAHb4XUtMLSIm2yRhQDASqHdOlIPCYLhXSIIuQ8sKs5QFIXA&s=10',
//     tags: 'Golden Retriever, grass',
//     confidence: 98,
//   ),
//   MockImage(
//     url:
//         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBNGQoTYoPylCrp6GAlSKceZ68LSWHMS6tJQ&s',
//     tags: 'Momo, Dumplings',
//     confidence: 99,
//   ),
//   MockImage(
//     url:
//         'https://www.hunts.com/sites/g/files/qyyrlu211/files/uploadedImages/img_6934_48664.jpg',
//     tags: 'Pepperoni Pizza',
//     confidence: 85,
//   ),
//   MockImage(
//     url:
//         'https://www.aaha.org/wp-content/uploads/2024/09/kitten-lying-in-blanket.jpg',
//     tags: 'Cat, Sofa',
//     confidence: 99,
//   ),
//   MockImage(
//     url:
//         'https://images.stockcake.com/public/4/d/a/4da151f6-88b6-44ee-ac59-e80f079f5db5_large/moonlit-mountain-landscape-stockcake.jpg',
//     tags: 'Snowy Peak, Night',
//     confidence: 82,
//   ),
// ];
