import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// โมเดลสำหรับจัดการข้อมูลที่ได้จาก API
class WateringData {
  final String id;
  final DateTime date;
  final int soilMoisture;
  final int soilTemperature;
  final int water;

  WateringData({
    required this.id,
    required this.date,
    required this.soilMoisture,
    required this.soilTemperature,
    required this.water,
  });

  factory WateringData.fromJson(Map<String, dynamic> json) {
    return WateringData(
      id: json['id'],
      date: DateTime.parse(json['date']),
      soilMoisture: json['soilMoisture'],
      soilTemperature: json['soilTemperature'],
      water: json['water'],
    );
  }
}

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  late Future<List<WateringData>> futureWateringData;

  // สี Theme หลัก
  final Color primaryBlue = const Color(0xFF4552B8);
  final Color darkBackground = const Color(0xFF151525);

  @override
  void initState() {
    super.initState();
    futureWateringData = fetchWateringData();
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<List<WateringData>> fetchWateringData({int limit = 7}) async {
  final response = await http.get(
    Uri.parse(
      'https://694402dd7dd335f4c35ef7b8.mockapi.io/api/welcome-homepage/watering-graph',
    ),
  );
  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(response.body);
    List<WateringData> data = jsonList
        .map((json) => WateringData.fromJson(json))
        .toList();
    data.sort((a, b) => a.date.compareTo(b.date));
    if (limit > 0 && data.length > limit) {
      data = data.sublist(data.length - limit);
    }
    return data;
  } else {
    throw Exception('ไม่สามารถโหลดข้อมูลได้');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Watering Statistics',
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
                futureWateringData = fetchWateringData();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Header ส่วนโค้งด้านบน ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 30, top: 10),
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
                      Icons.analytics_outlined, // ใช้ไอคอนกราฟ
                      size: 40,
                      color: Color(0xFF4552B8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "วิเคราะห์ข้อมูล",
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<WateringData>>(
                  future: futureWateringData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                            Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('ไม่พบข้อมูล'));
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        // Title Row
                        Row(
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
                              'ภาพรวม 7 วันล่าสุด',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Chart Area
                        Expanded(child: _buildChart(snapshot.data!)),
                        const SizedBox(height: 30),
                        _buildLegend(),
                        const SizedBox(height: 10),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // สร้าง Widget กราฟ
  Widget _buildChart(List<WateringData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // แสดงทุกจุด
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(data[index].date),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false, // ซ่อนกรอบเพื่อให้ดู Minimal ขึ้น
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 120, // เผื่อพื้นที่ด้านบน
        lineBarsData: [
          // เส้นความชื้นในดิน (Soil Moisture)
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map(
                  (e) =>
                      FlSpot(e.key.toDouble(), e.value.soilMoisture.toDouble()),
                )
                .toList(),
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withOpacity(0.1), // ใส่สีจางๆ ใต้กราฟ
            ),
          ),
          // เส้นอุณหภูมิดิน (Soil Temperature)
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map(
                  (e) => FlSpot(
                    e.key.toDouble(),
                    e.value.soilTemperature.toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            color: Colors.orangeAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
          // เส้นปริมาณน้ำ (Water)
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.water.toDouble()))
                .toList(),
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
        // Tooltip เมื่อกดที่จุดบนกราฟ
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                // ระบุชื่อข้อมูลตามสีของเส้น
                String label = '';
                if (barSpot.bar.color == Colors.blueAccent)
                  label = 'ความชื้น: ';
                if (barSpot.bar.color == Colors.orangeAccent)
                  label = 'อุณหภูมิ: ';
                if (barSpot.bar.color == Colors.teal) label = 'น้ำ: ';

                return LineTooltipItem(
                  '$label${flSpot.y.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // สร้างคำอธิบายสีของเส้น (Legend)
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.blueAccent, 'ความชื้น (%)'),
        _buildLegendItem(Colors.orangeAccent, 'อุณหภูมิ (°C)'),
        _buildLegendItem(Colors.teal, 'น้ำ (ml)'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
