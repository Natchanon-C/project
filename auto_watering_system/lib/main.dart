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