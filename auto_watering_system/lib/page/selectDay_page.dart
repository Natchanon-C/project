import 'package:flutter/material.dart';
import 'hompage.dart';

class SelectDayPage extends StatefulWidget {
  const SelectDayPage({super.key});

  @override
  State<SelectDayPage> createState() => _SelectDayPageState();
}

class _SelectDayPageState extends State<SelectDayPage> {
  // สี Theme
  final Color primaryBlue = const Color(0xFF4552B8);
  final Color darkBackground = const Color(0xFF151525);
  final Color actionGreen = const Color(0xFF3F9165);

  int _selectedIndex = 1; // Highlight หน้า Home

  // ตัวแปรสำหรับเลือกวัน
  final List<String> days = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
  final List<bool> selectedDays = [
    false,
    true,
    false,
    true,
    false,
    true,
    false,
  ];

  // ตัวแปรเวลา
  TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 30);
  int durationMinutes = 15;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // หมายเหตุ: ปกติหน้านี้เป็นหน้าย่อย การกด Tab อาจจะให้ Redirect กลับไปหน้าหลักตาม Index
    if (index != 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Watering Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            // ย้อนกลับไปหน้าก่อนหน้า
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
              );
            }
          },
        ),
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
                      Icons.timer_outlined, // ไอคอนนาฬิกา
                      size: 40,
                      color: Color(0xFF4552B8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "ตั้งเวลาให้น้ำ",
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
              width: double.infinity,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. เลือกวัน
                    _buildSectionTitle(
                      'เลือกวันที่ต้องการให้น้ำ',
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(days.length, (index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedDays[index] = !selectedDays[index];
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedDays[index]
                                  ? actionGreen
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                              boxShadow: selectedDays[index]
                                  ? [
                                      BoxShadow(
                                        color: actionGreen.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                              border: Border.all(
                                color: selectedDays[index]
                                    ? actionGreen
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  color: selectedDays[index]
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    // 2. เลือกเวลาเริ่ม
                    _buildSectionTitle('เวลาเริ่มทำงาน', Icons.access_time),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primaryBlue,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black87,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')} : ${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: primaryBlue,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 3. เลือกระยะเวลา
                    _buildSectionTitle(
                      'ระยะเวลาให้น้ำ (นาที)',
                      Icons.hourglass_bottom,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '5 นาที',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '$durationMinutes นาที',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: actionGreen,
                              ),
                            ),
                            Text(
                              '60 นาที',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: actionGreen,
                            inactiveTrackColor: actionGreen.withOpacity(0.2),
                            thumbColor: actionGreen,
                            overlayColor: actionGreen.withOpacity(0.2),
                            trackHeight: 6.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10.0,
                            ),
                          ),
                          child: Slider(
                            value: durationMinutes.toDouble(),
                            min: 5,
                            max: 60,
                            divisions: 11,
                            label: '$durationMinutes',
                            onChanged: (double value) {
                              setState(() {
                                durationMinutes = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ปุ่มบันทึก
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionGreen,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          // แสดง Dialog ยืนยัน หรือ บันทึกข้อมูล
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('บันทึกตารางงานเรียบร้อยแล้ว'),
                            ),
                          );

                          // กลับไปหน้าหลัก
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Homepage(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'บันทึกตารางงาน',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar (ใช้ Style เดียวกับ main.dart)
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
          backgroundColor: const Color(0xFF1E1E2E),
          indicatorColor: primaryBlue.withOpacity(0.8),
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
        ),
      ),
    );
  }

  // Helper Widget สำหรับหัวข้อแต่ละส่วน
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF4552B8),
        ), // ใช้สี primaryBlue
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
