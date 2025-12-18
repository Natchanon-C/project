import 'package:flutter/material.dart';
import 'hompage.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  // สี Theme
  final Color primaryBlue = const Color(0xFF4552B8);
  final Color darkBackground = const Color(0xFF151525);
  final Color actionGreen = const Color(0xFF3F9165);

  int _selectedIndex = 1; // Highlight หน้า Home

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // ถ้ากด Tab อื่น ให้กลับไปหน้าหลักแล้วเลือก Tab นั้น
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
          'Watering Tips',
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
                      Icons.lightbulb_outline, // ไอคอนหลอดไฟ
                      size: 40,
                      color: Color(0xFF4552B8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "เกร็ดความรู้",
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
                    // หัวข้อใหญ่
                    _buildMainTitle('สาระน่ารู้การให้น้ำ'),
                    const SizedBox(height: 20),

                    // เนื้อหาส่วนที่ 1
                    _buildSectionHeader('1) ทุเรียนต้องการ "น้ำแบบเป็นช่วง"'),
                    const SizedBox(height: 10),
                    const Text(
                      'ข้อมูลจากกรมส่งเสริมการเกษตร (DOA) และ ม.เกษตรศาสตร์ (KU) ระบุตรงกันว่า ทุเรียนต้องการน้ำต่างกันในแต่ละช่วง:',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBulletPoint(
                      'ฟื้นฟูต้นหลังเก็บเกี่ยว',
                      'เริ่มให้น้ำ ≤25% / หยุด ≥35% / น้ำ 156 ลิตร/ต้น/วัน',
                    ),
                    _buildBulletPoint(
                      'ช่วงทำใบ',
                      'เริ่ม ≤30% / หยุด ≥40% / น้ำ 167 ลิตร',
                    ),
                    _buildBulletPoint(
                      'กระตุ้นการออกดอก',
                      'เริ่ม ≤20% / หยุด ≥28% / น้ำ 93 ลิตร',
                    ),

                    const SizedBox(height: 25),

                    // เนื้อหาส่วนที่ 2
                    _buildSectionHeader('2) วิธีสังเกตต้นทุเรียน'),
                    const SizedBox(height: 10),
                    const Text(
                      'คำแนะนำจากสำนักงานเกษตรจังหวัดจันทบุรี:',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'อาการขาดน้ำ:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    _buildSimpleBullet('ปลายใบอ่อนห่อหรือเหี่ยว'),
                    _buildSimpleBullet('ดินแห้งแตกร่วน'),
                    _buildSimpleBullet('ใบแก่กลับด้านขึ้น'),
                    const SizedBox(height: 8),
                    const Text(
                      'อาการน้ำมากเกินไป:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    _buildSimpleBullet('ใบซีดหรือเหลือง'),
                    _buildSimpleBullet('ใบอ่อนร่วงง่าย'),
                    

                    const SizedBox(height: 25),

                    // เนื้อหาส่วนที่ 3
                    _buildSectionHeader('3) การคำนวณปริมาณน้ำ'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สูตรคำนวณ:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'ปริมาณน้ำ (ลิตร/วัน) = พื้นที่ทรงพุ่ม × ค่าความต้องการน้ำรายวัน (ETc)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'หลักการง่ายๆ: ช่วงแตกใบใช้น้ำน้อย, ช่วงขยายผลใช้น้ำมาก แอปพลิเคชันนี้ช่วยคำนวณให้ท่านอัตโนมัติ',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const Text(
                      'เกษตรกรไม่ต้องคำนวณเอง แอปสามารถคำนวณให้อัตโนมัติได้',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // เนื้อหาส่วนที่ 4
                    _buildSectionHeader('4) ทำไมต้อง “ลดน้ำก่อนออกดอก”?'),
                    const SizedBox(height: 10),
                    _buildSimpleBullet('เพื่อให้ต้นเกิดความเครียดที่เหมาะสม'),
                    _buildSimpleBullet('กระตุ้นให้รากส่งสัญญาณเตรียมออกดอก'),
                    _buildSimpleBullet('ป้องกันการแตกใบอ่อนแทนดอก'),
                    const Text(
                      'นี่คือเหตุผลที่สวนมืออาชีพต้องคุมให้ดินแห้งในช่วงเตรียมออกดอก',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // เนื้อหาส่วนที่ 5
                    _buildSectionHeader('5) ช่วงขยายผลทำไมต้องน้ำเยอะ?'),
                    const SizedBox(height: 10),
                    _buildSimpleBullet('80% ของน้ำหนักผลทุเรียนคือน้ำ'),
                    _buildSimpleBullet('ขาดน้ำ = เนื้อแห้ง ผลเบา เมล็ดลีบ'),
                    const Text(
                      'ข้อมูลนี้มีในคำแนะนำจันทบุรีและงานวิจัยของ ม.เกษตรศาสตร์เหมือนกัน',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // เนื้อหาส่วนที่ 6
                    _buildSectionHeader('6) เทคนิค "น้อยแต่บ่อย"'),
                    const SizedBox(height: 10),
                    _buildSimpleBullet('ทุเรียนชอบความชื้นสม่ำเสมอ'),
                    _buildSimpleBullet('ไม่ชอบน้ำขัง (รากต้องการอากาศ)'),
                    _buildSimpleBullet('ระบบสปริงเกลอร์จึงเหมาะสมที่สุด'),
                    const Text(
                      'ดังนั้น ระบบน้ำแบบสปริงเกลอร์/มินิสปริงเกลอร์หรือหยดจึงเหมาะที่สุด',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar (Style เดียวกับหน้าอื่น)
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

  Widget _buildMainTitle(String title) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF3F9165), // Action Green
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4552B8), // Primary Blue
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF3F9165)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
