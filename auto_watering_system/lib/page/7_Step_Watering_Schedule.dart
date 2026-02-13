import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'homepage.dart'; 

class SevenStepWateringSchedule extends StatefulWidget {
  const SevenStepWateringSchedule({super.key});

  @override
  State<SevenStepWateringSchedule> createState() => _SevenStepWateringScheduleState();
}

class _SevenStepWateringScheduleState extends State<SevenStepWateringSchedule> {
  bool _isLoading = true;
  List<dynamic> _phases = [];

  // --- API Configuration ---
  final String defaultApiUrl = "https://695002908531714d9bcf94fc.mockapi.io/water/watering-phase"; 
  final String editApiUrl = "https://695002908531714d9bcf94fc.mockapi.io/water/phase1"; 

  // --- Theme Colors ---
  final Color primaryBlue = const Color(0xFF4552B8);
  final Color actionGreen = const Color(0xFF3F9165);
  final Color textDark = const Color(0xFF2D3142);

  @override
  void initState() {
    super.initState();
    _fetchPhases();
  }

  // 1. ฟังก์ชันดึงข้อมูล 
  Future<void> _fetchPhases() async {
    if (mounted) setState(() => _isLoading = true);
    
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(defaultApiUrl)),
        http.get(Uri.parse(editApiUrl)),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        List<dynamic> defaultData = json.decode(responses[0].body);
        List<dynamic> editedData = json.decode(responses[1].body);
        List<dynamic> mergedData = [];

        for (int i = 1; i <= 7; i++) {
          String targetId = i.toString();
          Map<String, dynamic>? selectedItem;

          for (var item in editedData) {
            String itemId = item['id'].toString();
            String itemPhaseId = (item['phase_id'] ?? "").toString();

            if (itemId == targetId || itemPhaseId == targetId) {
              selectedItem = Map<String, dynamic>.from(item);
              selectedItem['id'] = targetId; 
              selectedItem['real_api_id'] = itemId; 
              break; 
            }
          }

          if (selectedItem == null) {
            for (var item in defaultData) {
              if (item['id'].toString() == targetId) {
                selectedItem = Map<String, dynamic>.from(item);
                selectedItem['mode'] = "AUTO_PHASE"; 
                break;
              }
            }
          }
          if (selectedItem != null) mergedData.add(selectedItem);
        }

        if (mounted) {
          setState(() {
            _phases = mergedData;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('API Error');
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. ฟังก์ชันบันทึกข้อมูล
  Future<void> _saveData(String id, Map<String, dynamic> data) async {
    try {
      data['phase_id'] = id; 
      final response = await http.put(
        Uri.parse("$editApiUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 404) {
        data['id'] = id; 
        await http.post(
          Uri.parse(editApiUrl),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('บันทึกเรียบร้อย!'), backgroundColor: actionGreen),
        );
        _fetchPhases();
      } 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. ฟังก์ชันรีเซ็ต
  Future<void> _resetData(String targetId, String? realApiId, BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop(); // ปิด Dialog ก่อน

    bool confirm = await showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("ยืนยันการรีเซ็ต"),
        content: const Text("ต้องการรีเซ็ตข้อมูลกลับเป็นค่าเริ่มต้นหรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("ยกเลิก")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("ยืนยัน", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;
    if (mounted) setState(() => _isLoading = true);

    try {
      String deleteId = (realApiId != null && realApiId.isNotEmpty) ? realApiId : targetId;
      await http.delete(Uri.parse("$editApiUrl/$deleteId"));
      if (mounted) _fetchPhases();
    } catch (e) {
      if (mounted) _fetchPhases();
    }
  }

  // --- UI Building ---
  
  void _showEditDialog(dynamic itemRaw) {
    Map<String, dynamic> item = Map<String, dynamic>.from(itemRaw);
    final dayCtrl = TextEditingController(text: (item['dayAmount'] ?? 0).toString());
    final literCtrl = TextEditingController(text: (item['litersAmount'] ?? 0).toString());
    final startCtrl = TextEditingController(text: (item['startMoisture'] ?? 0).toString());
    final stopCtrl = TextEditingController(text: (item['stopMoiseture'] ?? item['stopMoisture'] ?? 0).toString());
    final targetCtrl = TextEditingController(text: (item['targetMoisture'] ?? 0).toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("แก้ไขระยะที่ ${item['id']}", textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNumberInput("จำนวนวัน", dayCtrl, Icons.calendar_today),
              const SizedBox(height: 10),
              _buildNumberInput("น้ำ (ลิตร/ต้น)", literCtrl, Icons.water_drop),
              const Divider(height: 30),
              Row(
                children: [
                  Expanded(child: _buildNumberInput("เริ่ม (%)", startCtrl, Icons.arrow_downward)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildNumberInput("หยุด (%)", stopCtrl, Icons.arrow_upward)),
                ],
              ),
              const SizedBox(height: 10),
              _buildNumberInput("เป้าหมาย (%)", targetCtrl, Icons.center_focus_strong),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _resetData(item['id'].toString(), item['real_api_id']?.toString(), dialogContext),
            child: const Text("รีเซ็ต", style: TextStyle(color: Colors.orange)),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("ยกเลิก")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: actionGreen),
            onPressed: () {
              _saveData(item['id'].toString(), {
                "phaseName": item['phaseName'],
                "dayAmount": int.tryParse(dayCtrl.text) ?? 0,
                "litersAmount": int.tryParse(literCtrl.text) ?? 0,
                "startMoisture": int.tryParse(startCtrl.text) ?? 0,
                "stopMoisture": int.tryParse(stopCtrl.text) ?? 0,
                "targetMoisture": int.tryParse(targetCtrl.text) ?? 0,
                "mode": "EDIT_PHASE",
                "id": item['id'].toString(),
              });
              Navigator.pop(dialogContext);
            },
            child: const Text("บันทึก", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('ตารางการให้น้ำ 7 ระยะ', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // เช็คว่าย้อนกลับได้ไหม ถ้าไม่ได้ให้ไปหน้า Home
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Homepage()));
            }
          },
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryBlue))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _phases.length,
            itemBuilder: (context, index) => _buildPhaseCard(_phases[index]),
          ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: actionGreen,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            // ใช้ pushReplacement เพื่อป้องกัน Error Navigator
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Homepage(isSelectingDate: true)),
            );
          },
          child: const Text("กำหนดวันเริ่มให้น้ำ", style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildPhaseCard(dynamic itemRaw) {
    Map<String, dynamic> item = Map<String, dynamic>.from(itemRaw);
    bool isEdited = (item['mode'] == "EDIT_PHASE");
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          ListTile(
            tileColor: isEdited ? Colors.orange.withOpacity(0.1) : primaryBlue.withOpacity(0.05),
            leading: CircleAvatar(
              backgroundColor: isEdited ? Colors.orange : primaryBlue,
              child: Text(item['id'].toString(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(item['phaseName'] ?? "ระยะที่ ${item['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: isEdited ? const Text("แก้ไขแล้ว", style: TextStyle(color: Colors.orange, fontSize: 12)) : null,
            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(item)),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCol(Icons.calendar_today, "ระยะเวลา", "${item['dayAmount']} วัน"),
                _infoCol(Icons.water_drop, "น้ำ/ต้น", "${item['litersAmount']} ลิตร"),
                _infoCol(Icons.thermostat, "ชื้น", "${item['startMoisture']}-${item['stopMoisture'] ?? item['stopMoiseture']}%"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCol(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}