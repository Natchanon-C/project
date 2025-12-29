import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart'; // 1. ต้อง import get
import 'page/hompage.dart';

void main() async {
  // เริ่มต้นการใช้งาน Date Format ภาษาไทย
  await initializeDateFormatting('th_TH', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. เปลี่ยนจาก MaterialApp เป็น GetMaterialApp
    return GetMaterialApp( 
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

//////////////////////////////////
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'dart:async';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: const ControlPage(), debugShowCheckedModeBanner: false);
//   }
// }

// class ControlPage extends StatefulWidget {
//   const ControlPage({super.key});
//   @override
//   State<ControlPage> createState() => _ControlPageState();
// }

// class _ControlPageState extends State<ControlPage> {
//   final String apiUrl = "https://69441a237dd335f4c35f4bee.mockapi.io/api/test/1";
//   final String historyUrl = "https://69441a237dd335f4c35f4bee.mockapi.io/api/testgetdata";
  
//   String _status = "Ready";
//   String _lastUpdate = "-";
//   bool _isSending = false; // ตัวกั้นการกดซ้ำ
//   Timer? _timer;

//   Future<void> fetchStatus() async {
//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           if (data['updatedAt'] != null) {
//             DateTime time = DateTime.parse(data['updatedAt']).toLocal();
//             _lastUpdate = DateFormat('dd/MM/yyyy HH:mm:ss').format(time);
//           }
//         });
//       }
//     } catch (e) { print("Error: $e"); }
//   }

//   Future<void> updateStatus(String command) async {
//     if (_isSending) return; // ถ้ากำลังส่งอยู่ ห้ามส่งซ้ำ

//     setState(() { 
//       _isSending = true; 
//       _status = "Sending..."; 
//     });

//     try {
//       // 1. อัปเดตสถานะที่ ID 1 (PUT)
//       await http.put(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"status": command}),
//       );
//       fetchStatus();
//       setState(() { _status = "Server updated: $command"; });
//     } catch (e) {
//       setState(() { _status = "Error: $e"; });
//     } finally {
//       setState(() { _isSending = false; }); // ส่งเสร็จแล้วให้กดใหม่ได้
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchStatus();
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) => fetchStatus());
//   }

//   @override
//   void dispose() { _timer?.cancel(); super.dispose(); }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Cloud ESP32 Control"), backgroundColor: Colors.blueGrey),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_status, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             Text("Last Update: $_lastUpdate", style: const TextStyle(color: Colors.blue)),
//             const SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _isSending ? null : () => updateStatus("ON"),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
//                   child: const Text("Turn ON"),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: _isSending ? null : () => updateStatus("OFF"),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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