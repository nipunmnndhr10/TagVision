// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// class HiveTest extends StatefulWidget {
//   const HiveTest({super.key});

//   @override
//   State<HiveTest> createState() => _HiveTestState();
// }

// class _HiveTestState extends State<HiveTest> {
//   late final Box box;
//   @override
//   void initState() {
//     super.initState();
//     var box = Hive.openBox("hive-test");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Hive Test Database"),
//         backgroundColor: Colors.amber[400],
//       ),
//       body: Column(
//         children: [
//           FutureBuilder(
//             future: Hive.openBox('hive-test'),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState != ConnectionState.done) {
//                 return const CircularProgressIndicator();
//               }
//               if (!snapshot.hasData) {
//                 return const Text("No data");
//               }

//               final box = snapshot.data as Box;

//               return Column(
//                 children: [
//                   Text(
//                     box.get("name", defaultValue: "No name"),

//                     style: TextStyle(color: Colors.white),
//                   ),
//                   Text(
//                     box.get("age", defaultValue: 18).toString(),

//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           box.put("name", "nipun");
//           box.put("age", 20);
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
