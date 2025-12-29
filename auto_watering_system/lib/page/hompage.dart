import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import หน้าปลายทาง
import 'tips_page.dart';
import 'selectDay_page.dart';
import 'graph_page.dart';
import 'history_page.dart';
import 'manaul.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const Homepage()));
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Watering Calendar',
      theme: ThemeData(
        fontFamily: 'Roboto',
        // เปิดใช้ Material 3 เพื่อ UI ที่ทันสมัยขึ้น
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4552B8),
          primary: const Color(0xFF4552B8),
          secondary: const Color(0xFF3F9165),
          surface: const Color(0xFFF5F7FA),
        ),
      ),
      home: const WateringCalendarScreen(),
    );
  }
}

class WateringCalendarScreen extends StatefulWidget {
  const WateringCalendarScreen({super.key});

  @override
  State<WateringCalendarScreen> createState() => _WateringCalendarScreenState();
}

class _WateringCalendarScreenState extends State<WateringCalendarScreen> {
  int _selectedIndex = 1;

  // ใช้สีหลักเดียวกับ Theme
  final Color primaryBlue = const Color(0xFF4552B8);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังของ Scaffold หลัก
      backgroundColor: const Color(0xFF151525),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [GraphPage(), CalendarPage(), HistoryPage()],
      ),
      bottomNavigationBar: Container(
        // เพิ่มเงาให้ BottomNavigationBar ดูลอยมีมิติ
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: const Color.fromARGB(
            255,
            19,
            19,
            40,
          ), // สีพื้นหลัง Dark Theme
          indicatorColor: const Color.fromARGB(
            255,
            81,
            81,
            165,
          ).withOpacity(0.8),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.show_chart, color: Colors.white),
              label: 'กราฟ',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.home, color: Colors.white),
              label: 'หน้าหลัก',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined, color: Colors.white60),
              selectedIcon: Icon(Icons.history, color: Colors.white),
              label: 'ประวัติ',
            ),
          ],
          // ปรับสี Text Label
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Component หน้าปฏิทิน (ปรับปรุงใหม่)
// ---------------------------------------------------------
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color primaryBlue = const Color(0xFF4552B8);
  final Color darkBackground = const Color(0xFF151525);
  final Color actionGreen = const Color(0xFF3F9165);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // เก็บวันที่ที่มีข้อมูลจาก API
  Set<DateTime> _datesWithData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataFromAPI();
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<void> _fetchDataFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://695002908531714d9bcf94fc.mockapi.io/water/store-data-manual',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _datesWithData = data.map((item) {
            // แปลงวันที่จาก API เป็น DateTime และเก็บเฉพาะส่วนวันที่ (ไม่รวมเวลา)
            DateTime date = DateTime.parse(item['date']);
            return DateTime(date.year, date.month, date.day);
          }).toSet();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  // ฟังก์ชันตรวจสอบว่าวันนี้มีข้อมูลหรือไม่
  bool _hasDataForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _datesWithData.contains(normalizedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'วางแผนการให้น้ำ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });
                    _fetchDataFromAPI();
                  },
            tooltip: 'รีเฟรชข้อมูล',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4552B8)),
            )
          : Column(
              children: [
                // Header ส่วนโค้งด้านบน
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [Container(padding: const EdgeInsets.all(4))],
                  ),
                ),

                const SizedBox(height: 20),

                // Main Content Area (Card ลอย)
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
                                'ปฏิทินการให้น้ำ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Calendar Navigation Header
                        _buildCalendarHeader(),

                        // Calendar Table
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TableCalendar(
                              shouldFillViewport: true,
                              locale: 'th_TH',
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                if (isSameDay(_selectedDay, selectedDay)) {
                                  // ถ้ากดวันที่เดิมซ้ำ (ครั้งที่ 2) ให้เปลี่ยนหน้า
                                  // ส่งค่าวันที่ไปด้วยเพื่อให้หน้าปลายทางรู้ว่าเป็นวันไหน
                                  Get.to(
                                    () => const DayDetailPage(),
                                    arguments: selectedDay,
                                    transition: Transition
                                        .rightToLeft, // เพิ่ม Animation
                                  );
                                } else {
                                  // ถ้ากดครั้งแรก ให้แค่เลือกวันที่
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                }
                              },
                              headerVisible: false,
                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryBlue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                todayDecoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                todayTextStyle: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                                cellMargin: const EdgeInsets.all(6),
                              ),
                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekendStyle: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                                weekdayStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                });
                              },
                              // เพิ่มการแสดงสถานะสีเขียวสำหรับวันที่มีข้อมูล
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, day, focusedDay) {
                                  if (_hasDataForDay(day)) {
                                    return Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: actionGreen.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: actionGreen,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: actionGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                                outsideBuilder: (context, day, focusedDay) {
                                  if (_hasDataForDay(day)) {
                                    return Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: actionGreen.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: actionGreen.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: actionGreen.withOpacity(0.7),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                          child: Column(
                            children: [
                              _ActionButton(
                                text: 'กำหนดการให้น้ำตามตาราง',
                                icon: Icons.edit_calendar,
                                color: actionGreen,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SelectdayPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _ActionButton(
                                text: 'สาระความรู้ตาราง',
                                icon: Icons.tips_and_updates,
                                color: const Color(
                                  0xFFF9A825,
                                ), // สีเหลืองเข้มสำหรับ Tips
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TipsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
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

  // Widget ส่วนหัวปฏิทิน
  Widget _buildCalendarHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 24,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                  _focusedDay.day,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'th_TH').format(_focusedDay),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                  _focusedDay.day,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}

// Widget ปุ่มกด (Reusable Component) ที่ปรับปรุงใหม่
class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
