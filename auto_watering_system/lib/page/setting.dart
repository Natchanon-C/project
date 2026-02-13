import 'package:flutter/material.dart';

// 1. Import ไฟล์หน้าปลายทาง
import '7_Step_Watering_Schedule.dart'; 

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // พื้นหลังสีขาวนวล
      appBar: AppBar(
        backgroundColor: const Color(0xFF4552B8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'การตั้งค่า',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- เมนูที่ 1: กำหนดการให้น้ำตามตาราง ---
            _buildSettingMenu(
              context,
              title: 'กำหนดการให้น้ำตามตาราง',
              subtitle: 'ตั้งค่าเวลาและความถี่แบบรวม',
              icon: Icons.calendar_month_outlined,
              iconColor: const Color(0xFF3F9165), // สีเขียว
              onTap: () {
                 // 2. สั่งให้เปลี่ยนหน้าไปที่ 7_Step_Watering_Schedule.dart
                 // ** ตรวจสอบชื่อ Class ให้ตรงกับในไฟล์นั้นนะครับ **
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => const SevenStepWateringSchedule(),
                   ),
                 );
              },
            ),

            const SizedBox(height: 15),

            // --- เมนูที่ 2: กำหนดการให้น้ำต่อต้น ---
            _buildSettingMenu(
              context,
              title: 'กำหนดการให้น้ำต่อต้น',
              subtitle: 'ตั้งค่าเฉพาะเจาะจงรายต้น',
              icon: Icons.local_florist_outlined,
              iconColor: const Color(0xFFF9A825), // สีเหลืองส้ม
              onTap: () {
                 // ยังไม่มีไฟล์ปลายทาง ใส่ print ไว้ก่อน
                 print("เลือก: กำหนดการให้น้ำต่อต้น");
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget สร้างปุ่มเมนู (Design เดิม)
  Widget _buildSettingMenu(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}