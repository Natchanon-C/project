import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import หน้าปลายทาง
import 'tips_page.dart';
import 'graph_page.dart';
import 'history_page.dart';
import 'setting.dart';
import 'manual.dart'; 

class Homepage extends StatelessWidget {
  final bool isSelectingDate;

  const Homepage({super.key, this.isSelectingDate = false});

  @override
  Widget build(BuildContext context) {
    return WateringCalendarScreen(isSelectingDate: isSelectingDate);
  }
}

class WateringCalendarScreen extends StatefulWidget {
  final bool isSelectingDate;
  const WateringCalendarScreen({super.key, this.isSelectingDate = false});

  @override
  State<WateringCalendarScreen> createState() => _WateringCalendarScreenState();
}

class _WateringCalendarScreenState extends State<WateringCalendarScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151525), 
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const GraphPage(),
          CalendarPage(isSelectingDate: widget.isSelectingDate),
          const HistoryPage()
        ],
      ),
      bottomNavigationBar: Container(
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
          backgroundColor: const Color.fromARGB(255, 19, 19, 40),
          indicatorColor: const Color.fromARGB(255, 81, 81, 165).withOpacity(0.8),
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
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Component หน้าปฏิทิน (CalendarPage)
// ---------------------------------------------------------
class CalendarPage extends StatefulWidget {
  final bool isSelectingDate;
  const CalendarPage({super.key, this.isSelectingDate = false});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> _phaseList = [];
  final Color primaryBlue = const Color(0xFF4552B8);
  final Color darkBackground = const Color(0xFF151525);
  final Color actionGreen = const Color(0xFF3F9165);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _lastClickedTime;

  Set<DateTime> _datesWithData = {};
  bool _isLoading = true;
  late bool _isSelectionMode;
  
  Future<void> _fetchPhaseData() async {
  try {
    final response = await http.get(
      Uri.parse('https://695002908531714d9bcf94fc.mockapi.io/water/phase1'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      setState(() {
        _phaseList = data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  } catch (e) {
    print("Phase fetch error: $e");
  }
}


  @override
  void initState() {
    super.initState();
    _isSelectionMode = widget.isSelectingDate;
    _fetchDataFromAPI();
    _fetchPhaseData();
  }

  // ดึงข้อมูลวันที่มีการรดน้ำ
  Future<void> _fetchDataFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://695002908531714d9bcf94fc.mockapi.io/water/store-data-manual'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _datesWithData = data.map((item) {
              DateTime date = DateTime.parse(item['date']);
              return DateTime(date.year, date.month, date.day);
            }).toSet();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error fetching data: $e');
    }
  }

//  ฟังก์ชัน Save 
  Future<void> _saveStartDateToApi(DateTime selectedDate) async {
    final String editUrl = "https://695002908531714d9bcf94fc.mockapi.io/water/edit-watering-phase";
    final String defaultUrl = "https://695002908531714d9bcf94fc.mockapi.io/water/watering-phase";
    final String targetUrl = "https://695002908531714d9bcf94fc.mockapi.io/water/phase1";

    try {
      // 1. ล้างข้อมูลเก่าใน phase1 ทิ้ง (Reset)
      final oldDataResp = await http.get(Uri.parse(targetUrl));
      if (oldDataResp.statusCode == 200) {
        List<dynamic> oldData = json.decode(oldDataResp.body);
        for (var item in oldData) {
          // ลบทีละตัวเพื่อให้แน่ใจว่า Key ขยะหายไปจริงๆ
          await http.delete(Uri.parse("$targetUrl/${item['id']}"));
        }
      }

      // 2. ดึงข้อมูลจาก Edit และ Default
      final responses = await Future.wait([
        http.get(Uri.parse(editUrl)),
        http.get(Uri.parse(defaultUrl)),
      ]);

      List<dynamic> editedData = json.decode(responses[0].body);
      List<dynamic> defaultData = json.decode(responses[1].body);
      int timestamp = selectedDate.millisecondsSinceEpoch ~/ 1000;

      // 3. สร้างข้อมูลใหม่ (Clean Build)
      for (int i = 1; i <= 7; i++) {
        String currentId = i.toString();
        Map<String, dynamic>? sourceItem;

        // หาจาก Edit ก่อน
        for (var e in editedData) {
          if (e['id'].toString() == currentId) {
            sourceItem = Map<String, dynamic>.from(e);
            break;
          }
        }
        // ถ้าไม่มี หาจาก Default
        if (sourceItem == null) {
          for (var d in defaultData) {
            if (d['id'].toString() == currentId) {
              sourceItem = Map<String, dynamic>.from(d);
              break;
            }
          }
        }

        if (sourceItem != null) {
          String startT = sourceItem["schedule_start"].toString();
          String endT = sourceItem["schedule_end"].toString();
          if (!startT.contains(":")) startT = "07:00";
          if (!endT.contains(":")) endT = "17:00";

          // --- จุดสำคัญ: Logic การเลือกค่า ---
          // เราจะดึงค่าจาก key ไหนก็ได้ (ถูกหรือผิด) มาเก็บไว้ในตัวแปรเดียว
          int finalStartM = int.tryParse(sourceItem["startMoisture"]?.toString() ?? sourceItem["startMoisture"]?.toString() ?? "0") ?? 0;
          int finalStopM = int.tryParse(sourceItem["stopMoisture"]?.toString() ?? sourceItem["stopMoisture"]?.toString() ?? "0") ?? 0;
          int finalTargetM = int.tryParse(sourceItem["targetMoisture"]?.toString() ?? sourceItem["targetMoisture"]?.toString() ?? "0") ?? 0;
          int finalLiter = int.tryParse(sourceItem["litersAmount"]?.toString() ?? sourceItem["litersAmount"]?.toString() ?? "0") ?? 0;

          // --- สร้าง Map ใหม่ โดยใช้แต่ Key ที่ "ถูก" เท่านั้น ---
          Map<String, dynamic> cleanData = {
            "id": currentId,
            "phaseName": sourceItem["phaseName"],
            "dayAmount": int.tryParse(sourceItem["dayAmount"].toString()) ?? 0,
            
            "targetMoisture": finalTargetM, // ส่งแค่ Key ถูก
            "startMoisture": finalStartM,   // ส่งแค่ Key ถูก
            "stopMoisture": finalStopM,     // ✅ ส่งแค่ Key ถูก (ลบ stopMoisture ทิ้งไปเลย)
            "litersAmount": finalLiter,     // ส่งแค่ Key ถูก
            
            "schedule_start": startT,
            "schedule_end": endT,
            "startdate": timestamp,
            "mode": "AUTO_PHASE",
          };

          // ส่งข้อมูลที่สะอาดแล้ว
          await http.post(
            Uri.parse(targetUrl),
            headers: {"Content-Type": "application/json"},
            body: json.encode(cleanData),
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตข้อมูลเรียบร้อย!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      print("❌ Error: $e");
    }
  }

  bool _hasDataForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _datesWithData.contains(normalizedDay);
  }

  Map<String, dynamic>? _getPhaseForDate(DateTime day) {
  for (var phase in _phaseList) {
    if (phase["startdate"] == null) continue;

    int startTimestamp =
        int.tryParse(phase["startdate"].toString()) ?? 0;

    if (startTimestamp == 0) continue;

    DateTime start =
        DateTime.fromMillisecondsSinceEpoch(startTimestamp * 1000);

    int dayAmount =
        int.tryParse(phase["dayAmount"].toString()) ?? 0;

    DateTime end = start.add(Duration(days: dayAmount - 1));

    DateTime normalizedDay =
        DateTime(day.year, day.month, day.day);

    DateTime normalizedStart =
        DateTime(start.year, start.month, start.day);

    DateTime normalizedEnd =
        DateTime(end.year, end.month, end.day);

    if (!normalizedDay.isBefore(normalizedStart) &&
        !normalizedDay.isAfter(normalizedEnd)) {
      return phase;
    }
  }

  return null;
}




  Color _getPhaseColor(String id) {
  switch (id) {
    case "1":
      return Colors.green;
    case "2":
      return Colors.orange;
    case "3":
      return Colors.blue;
    case "4":
      return Colors.purple;
    case "5":
      return Colors.red;
    case "6":
      return Colors.teal;
    case "7":
      return Colors.indigo;
    default:
      return Colors.grey;
  }
}


  void _confirmStartWateringDate(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("ยืนยันวันเริ่มให้น้ำ"),
        content: Text("เริ่มวันกำหนดการให้น้ำ\n${DateFormat('d MMMM yyyy', 'th_TH').format(selectedDate)}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: actionGreen, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx); 
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('กำลังบันทึกข้อมูล 7 ระยะ...'), duration: Duration(seconds: 2)),
              );

              try {
                // เรียกฟังก์ชันบันทึก
                await _saveStartDateToApi(selectedDate);
                await _fetchPhaseData();

                if (mounted) {
                  setState(() {
                    _isSelectionMode = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('บันทึกข้อมูลสำเร็จ!'),
                      backgroundColor: actionGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาด: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("ยืนยัน"),
          ),
        ],
      ),
    );
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() => _isLoading = true);
                    _fetchDataFromAPI();
                  },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4552B8)))
          : Column(
              children: [
                // Header Curve
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
                  child: Column(children: [Container(padding: const EdgeInsets.all(4))]),
                ),
                
                if (_isSelectionMode)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.shade300),
                      boxShadow: [
                         BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                      ]
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app, color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "โหมดกำหนดวันเริ่ม",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16),
                              ),
                              Text(
                                "แตะที่ปฏิทินเพื่อเลือกวันเริ่มให้น้ำ",
                                style: TextStyle(color: Colors.black87, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => setState(() => _isSelectionMode = false),
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),
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
                              const Spacer(),
                              IconButton(
                                icon: Icon(Icons.settings_outlined, color: Colors.grey.shade600),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SettingPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCalendarHeader(),
                        
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

                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, day, events) {
                                  final phase = _getPhaseForDate(day);
                                  if (phase == null) return null;

                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 2),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getPhaseColor(phase["id"].toString()),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },

                                defaultBuilder: (context, day, focusedDay) {
                                  if (_hasDataForDay(day)) {
                                    return _buildMarkerDay(day, actionGreen, opacity: 0.2);
                                  }
                                  return null;
                                },
                              ),


                              onDaySelected: (selectedDay, focusedDay) {
                                final now = DateTime.now();

                                if (_isSelectionMode) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  _confirmStartWateringDate(selectedDay);
                                  return;
                                }

                                if (_selectedDay != null && 
                                    isSameDay(_selectedDay, selectedDay) && 
                                    _lastClickedTime != null &&
                                    now.difference(_lastClickedTime!) < const Duration(milliseconds: 400)) { 
                                  
                                  Get.to(
                                    () => const DayDetailPage(), 
                                    arguments: selectedDay,
                                  );
                                  
                                  _lastClickedTime = null; 

                                } else {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  
                                  _lastClickedTime = now; 
                                }
                              },
                              headerVisible: false,
                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: _isSelectionMode ? Colors.orange : primaryBlue,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isSelectionMode ? Colors.orange : primaryBlue).withOpacity(0.3),
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
                              onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
                            ),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _ActionButton(
                                text: 'สาระความรู้ตาราง',
                                icon: Icons.tips_and_updates,
                                color: const Color(0xFFF9A825),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const TipsPage()),
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

  Widget _buildMarkerDay(DateTime day, Color color, {double opacity = 0.2, bool isOutside = false}) {
     return Container(
       margin: const EdgeInsets.all(6),
       decoration: BoxDecoration(
         color: color.withOpacity(opacity),
         shape: BoxShape.circle,
         border: Border.all(
           color: isOutside ? color.withOpacity(0.5) : color,
           width: isOutside ? 1 : 2,
         ),
       ),
       child: Center(
         child: Text(
           '${day.day}',
           style: TextStyle(
             color: isOutside ? color.withOpacity(0.7) : color,
             fontWeight: isOutside ? FontWeight.w600 : FontWeight.bold,
           ),
         ),
       ),
     );
  }

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
            icon: const Icon(Icons.chevron_left, size: 24, color: Colors.black54),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day)),
          ),
          Text(
            DateFormat('MMMM yyyy', 'th_TH').format(_focusedDay),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24, color: Colors.black54),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, _focusedDay.day)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.text, required this.icon, required this.color, required this.onPressed});

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}