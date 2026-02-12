import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayDetailPage extends StatefulWidget {
  const DayDetailPage({super.key});

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  final TextEditingController _minHumidityController = TextEditingController();
  final TextEditingController _maxHumidityController = TextEditingController();
  final TextEditingController _waterVolumeController = TextEditingController();

  bool _isLoading = false;
  late DateTime selectedDate;
  
  // [ใหม่ 1] ตัวแปรเก็บ ID ของข้อมูล (ถ้ามี) เพื่อใช้ในการลบ
  String? _existingId; 

  @override
  void initState() {
    super.initState();
    selectedDate = Get.arguments ?? DateTime.now();
    _fetchExistingData();
  }

  @override
  void dispose() {
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    _waterVolumeController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingData() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://695002908531714d9bcf94fc.mockapi.io/water/store-data-manual');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        String targetDate = DateFormat('yyyy-MM-dd').format(selectedDate);
        
        var existingEntry = data.firstWhere(
          (item) => item['date'].toString().contains(targetDate),
          orElse: () => null,
        );

        if (existingEntry != null) {
          setState(() {
            // [ใหม่ 2] เก็บ ID ไว้ใช้ตอนกดลบ
            _existingId = existingEntry['id'].toString(); 

            _minHumidityController.text = existingEntry['startmoisture'].toString();
            _maxHumidityController.text = existingEntry['stopmoisture'].toString();
            _waterVolumeController.text = existingEntry['literAmount'].toString();
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // [ใหม่ 3] ฟังก์ชันสำหรับลบข้อมูล
  Future<void> _deleteData() async {
    if (_existingId == null) return;

    setState(() => _isLoading = true);
    try {
      // MockAPI ต้องระบุ ID ต่อท้าย URL เพื่อลบ
      final url = Uri.parse('https://695002908531714d9bcf94fc.mockapi.io/water/store-data-manual/$_existingId');
      
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Get.back(); // ปิดหน้าจอ
        Get.snackbar(
          'ลบสำเร็จ', 
          'ลบข้อมูลเรียบร้อยแล้ว',
          backgroundColor: Colors.red, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
        );
      } else {
        Get.snackbar('ผิดพลาด', 'ไม่สามารถลบข้อมูลได้ (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'เกิดข้อผิดพลาดในการเชื่อมต่อ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // [ใหม่ 4] แสดง Dialog ยืนยันก่อนลบ
  void _confirmDelete() {
    Get.defaultDialog(
      title: "ยืนยันการลบ",
      middleText: "คุณต้องการลบข้อมูลการตั้งค่าของวันนี้ใช่หรือไม่?",
      textConfirm: "ลบข้อมูล",
      textCancel: "ยกเลิก",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () {
        Get.back(); // ปิด Dialog
        _deleteData(); // เรียกฟังก์ชันลบ
      },
    );
  }

  Future<void> _saveToMockApi() async {
    // 0. หุบคีย์บอร์ด
    FocusScope.of(context).unfocus();

    // 1. ตรวจสอบข้อมูลว่าง
    if (_minHumidityController.text.trim().isEmpty || 
        _maxHumidityController.text.trim().isEmpty || 
        _waterVolumeController.text.trim().isEmpty) {
      Get.snackbar('ข้อมูลไม่ครบ', 'กรุณากรอกข้อมูลให้ครบทุกช่อง', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // 2. แปลงค่าตัวเลข
    double? minHumid = double.tryParse(_minHumidityController.text);
    double? maxHumid = double.tryParse(_maxHumidityController.text);
    double? waterVol = double.tryParse(_waterVolumeController.text);

    if (minHumid == null || maxHumid == null || waterVol == null) {
      Get.snackbar('รูปแบบผิดพลาด', 'กรุณากรอกเฉพาะตัวเลข', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (minHumid > 100 || maxHumid > 100) {
      Get.snackbar('ค่าเกินกำหนด', 'ความชื้นห้ามเกิน 100%', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // [ใหม่] ตรวจสอบเงื่อนไข Start ต้องน้อยกว่า Stop
    // ถ้า Start (min) มากกว่าหรือเท่ากับ Stop (max) ให้แจ้งเตือน
    if (minHumid >= maxHumid) {
      Get.snackbar(
        'ค่ากำหนดไม่ถูกต้อง', 
        'ค่าความชื้นเริ่มต้น (Start) ต้องน้อยกว่าค่าหยุดทำงาน (Stop)',
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return; // จบการทำงาน ไม่บันทึก
    }

    // 3. เริ่มส่งข้อมูล
    setState(() => _isLoading = true);

    try {
      http.Response response;
      final Map<String, dynamic> bodyData = {
        "startmoisture": minHumid,
        "stopmoisture": maxHumid,
        "literAmount": waterVol,
        "date": selectedDate.toIso8601String(),
      };

      if (_existingId != null) {
        // UPDATE
        final url = Uri.parse('https://695002908531714d9bcf94fc.mockapi.io/water/store-data-manual/$_existingId');
        response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyData),
        );
      } else {
        // CREATE
        final url = Uri.parse('https://695002908531714d9bcf94fc.mockapi.io/water/store-data-manual');
        response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); 
        Get.snackbar(
          'สำเร็จ', 
          _existingId != null ? 'อัปเดตข้อมูลเรียบร้อยแล้ว' : 'บันทึกข้อมูลใหม่เรียบร้อยแล้ว',
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('ผิดพลาด', 'Server Error (${response.statusCode})', 
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('ผิดพลาด', 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้', 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMMM yyyy', 'th_TH').format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('ตั้งค่าวันที่ $formattedDate'),
        backgroundColor: const Color(0xFF4552B8),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildInputField('เริ่มทำงานเมื่อความชื้นน้อยกว่า', _minHumidityController, '%'),
                _buildInputField('หยุดทำงานเมื่อความชื้นมากกว่า ', _maxHumidityController, '%'),
                _buildInputField('ปริมาณน้ำที่ให้ ', _waterVolumeController, 'ลิตร'),
                const SizedBox(height: 40),
                
                // ปุ่มบันทึกข้อมูล
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4552B8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveToMockApi,
                    child: const Text("บันทึกข้อมูล", style: TextStyle(color: Colors.white, fontSize: 17)),
                  ),
                ),

                // [ใหม่ 5] ปุ่มลบข้อมูล (แสดงเฉพาะเมื่อมีข้อมูลเก่าอยู่แล้ว _existingId ไม่เป็น null)
                if (_existingId != null) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.red,
                      ),
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("ลบข้อมูลของวันนี้", style: TextStyle(fontSize: 17)),
                    ),
                  ),
                ]
              ],
            ),
          ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Expanded(flex: 4, child: Text(label)),
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  fillColor: const Color(0xFFF8F9FE),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(unit, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}