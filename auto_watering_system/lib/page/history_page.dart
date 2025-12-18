import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// โมเดลข้อมูลสำหรับประวัติการรดน้ำ
class HistoryItem {
  final String id;
  final DateTime date;
  final int waterAmount;
  final int soilMoisture;

  HistoryItem({
    required this.id,
    required this.date,
    required this.waterAmount,
    required this.soilMoisture,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      date: DateTime.parse(json['date']),
      waterAmount: json['waterAmount'],
      soilMoisture: json['soilMoisture'],
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<HistoryItem>> futureHistory;

  final Color primaryBlue = const Color(0xFF4552B8);
  final Color darkBackground = const Color(0xFF151525);

  @override
  void initState() {
    super.initState();
    futureHistory = fetchHistory();
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<List<HistoryItem>> fetchHistory() async {
    final response = await http.get(
      Uri.parse(
        'https://694402dd7dd335f4c35ef7b8.mockapi.io/api/welcome-homepage/watering-history',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<HistoryItem> data = jsonList
          .map((json) => HistoryItem.fromJson(json))
          .toList();
      // เรียงลำดับจากวันที่ใหม่ไปเก่า
      data.sort((a, b) => b.date.compareTo(a.date));
      return data;
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลประวัติได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Watering History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                futureHistory = fetchHistory();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Header ส่วนโค้งด้านบน (เหมือนหน้า Main) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 15, top: 10),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.history_edu,
                      size: 40,
                      color: Color(0xFF4552B8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "บันทึกย้อนหลัง",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Main Content Area (White Card) ---
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  // Title Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'รายการรดน้ำล่าสุด',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // List Content
                  Expanded(
                    child: FutureBuilder<List<HistoryItem>>(
                      future: futureHistory,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 48,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'เกิดข้อผิดพลาดในการโหลด',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'ไม่มีข้อมูลประวัติ',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.data![index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // วันที่ (ซ้ายมือ)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            DateFormat('dd').format(item.date),
                                            style: TextStyle(
                                              color: primaryBlue,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM').format(item.date),
                                            style: TextStyle(
                                              color: primaryBlue.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // ข้อมูลรายละเอียด (ขวามือ)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'เวลา HH:mm น.',
                                              'th',
                                            ).format(item.date),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _buildInfoTag(
                                                Icons.water_drop,
                                                '${item.waterAmount} ml',
                                                Colors
                                                    .blueAccent, // ปรับสีให้ชัดบนพื้นขาว
                                              ),
                                              const SizedBox(width: 16),
                                              _buildInfoTag(
                                                Icons.grass,
                                                'ความชื้น ${item.soilMoisture}%',
                                                Colors
                                                    .green, // ปรับสีให้ชัดบนพื้นขาว
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color:
                Colors.grey[700], // สีข้อความเทาเข้มเพื่อให้อ่านง่ายบนพื้นขาว
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
