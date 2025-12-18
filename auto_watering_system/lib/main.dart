import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'page/hompage.dart';

void main() async {
  await initializeDateFormatting('th_TH', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Watering Calendar',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.indigo,
        useMaterial3: false,
      ),
      home: const Homepage(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: const ControlPage());
//   }
// }

// class ControlPage extends StatefulWidget {
//   const ControlPage({super.key});
//   @override
//   State<ControlPage> createState() => _ControlPageState();
// }

// class _ControlPageState extends State<ControlPage> {
//   final String apiUrl = "https://694422687dd335f4c35f65a4.mockapi.io/device/device/1";

//   String _status = "Ready";

//   Future<void> updateStatus(String command) async {
//     setState(() {
//       _status = "Sending...";
//     });

//     try {
//       final response = await http.put(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"status": command}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _status = "Server updated: $command";
//         });
//       } else {
//         setState(() {
//           _status = "Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _status = "Failed: $e";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Cloud ESP32 Control")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_status, style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => updateStatus("ON"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   child: const Text("Turn ON"),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () => updateStatus("OFF"),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text("Turn OFF"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
