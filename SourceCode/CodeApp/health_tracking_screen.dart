// health_tracking_screen.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'health_card.dart';
import 'health_evaluation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main.dart'; // Import main.dart để truy cập flutterLocalNotificationsPlugin

class HealthTrackingScreen extends StatefulWidget {
  final Function(Map<String, dynamic>, Map<String, String>) onDataUpdated;
  final Map<String, String> initialHealthNotes;

  const HealthTrackingScreen({
    super.key,
    required this.onDataUpdated,
    required this.initialHealthNotes,
  });

  @override
  _HealthTrackingScreenState createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sensors');
  Map<String, dynamic> healthData = {};
  late Map<String, String> healthNotes;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    healthNotes = Map<String, String>.from(widget.initialHealthNotes);
    _fetchHealthData();
  }

  @override
  void dispose() {
    // Đảm bảo không gọi setState sau khi dispose nếu _dbRef listener vẫn hoạt động
    // Thực tế bạn có thể cần quản lý stream subscription tốt hơn nếu listener vẫn hoạt động ngầm
    super.dispose();
  }

  void _updateParent() {
    widget.onDataUpdated(healthData, healthNotes);
  }

  Future<void> _fetchHealthData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      _dbRef.onValue.listen((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          setState(() {
            healthData = data;
            isLoading = false;
          });
          _updateParent(); // Cập nhật dữ liệu lên HomeScreen
        } else {
          setState(() {
            healthData = {};
            isLoading = false;
            // errorMessage = 'Không có dữ liệu sức khỏe.';
          });
          _updateParent();
        }
      }, onError: (Object error) {
        setState(() {
          errorMessage = 'Lỗi tải dữ liệu: $error';
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi không xác định: $e';
        isLoading = false;
      });
    }
  }

  void showNoteDialog(BuildContext context, String noteKey, String title) {
    TextEditingController noteController = TextEditingController(text: healthNotes[noteKey]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ghi chú cho $title'),
          content: TextField(
            controller: noteController,
            maxLines: 5, // Cho phép nhập nhiều dòng
            decoration: const InputDecoration(
              hintText: 'Nhập ghi chú của bạn...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  healthNotes[noteKey] = noteController.text;
                });
                _updateParent(); // Cập nhật ghi chú lên HomeScreen
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Xác định số cột dựa trên chiều rộng màn hình
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 cột cho màn hình lớn, 2 cho màn hình nhỏ

    // Điều chỉnh childAspectRatio để các thẻ dài hơn một chút
    // Giá trị nhỏ hơn 1.0 sẽ làm thẻ cao hơn so với chiều rộng của nó.
    final double childAspectRatio = screenWidth > 600 ? 0.9 : 0.8; // Điều chỉnh tùy theo kích thước mong muốn

    // Định nghĩa các thông số sức khỏe để hiển thị
    final List<Map<String, dynamic>> metrics = [
      {
        'key': 'temperature',
        'title': 'Nhiệt độ',
        'unit': '°C',
        'safeMin': 20.0,
        'safeMax': 28.0,
        'issueMin': 18.0,
        'issueMax': 30.0,
        'icon': Icons.thermostat,
      },
      {
        'key': 'humidity',
        'title': 'Độ ẩm',
        'unit': '%',
        'safeMin': 40.0,
        'safeMax': 60.0,
        'issueMin': 30.0,
        'issueMax': 70.0,
        'icon': Icons.water_drop,
      },
      {
        'key': 'heart_rate',
        'title': 'Nhịp tim',
        'unit': 'bpm',
        'safeMin': 60.0,
        'safeMax': 100.0,
        'issueMin': 50.0,
        'issueMax': 120.0,
        'icon': Icons.favorite,
      },
      {
        'key': 'spo2',
        'title': 'SpO2',
        'unit': '%',
        'safeMin': 95.0,
        'safeMax': 100.0,
        'issueMin': 90.0,
        'issueMax': 100.0,
        'icon': Icons.monitor_heart,
      },
      {
        'key': 'weight',
        'title': 'Cân nặng',
        'unit': 'kg',
        'safeMin': 45.0,
        'safeMax': 80.0,
        'issueMin': 40.0,
        'issueMax': 100.0,
        'icon': Icons.scale,
      },
      // Thêm các chỉ số khác nếu có
    ];

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Theo dõi sức khỏe'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Theo dõi sức khỏe'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: $errorMessage',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchHealthData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi sức khỏe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Đã xóa phần "Đánh giá sức khỏe tổng thể" tại đây
            // Text(
            //   'Đánh giá sức khỏe tổng thể:',
            //   style: theme.textTheme.headlineSmall?.copyWith(
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // Text(
            //   getOverallHealthAssessment(healthData, healthNotes),
            //   style: theme.textTheme.bodyLarge?.copyWith(
            //     color: theme.colorScheme.onSurface.withOpacity(0.8),
            //   ),
            // ),
            // const SizedBox(height: 20), // Giữ hoặc điều chỉnh khoảng cách này nếu cần

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0, // Tăng khoảng cách giữa các hàng
                childAspectRatio: childAspectRatio, // Điều chỉnh tỷ lệ này
              ),
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                final metric = metrics[index];
                final String metricKey = metric['key'] as String;
                // Đảm bảo tên title trong healthNotes khớp với title của metric
                final String noteKey = '${metric['title']} (${metric['unit']})';


                return HealthCard(
                  title: '${metric['title']} (${metric['unit']})',
                  value: healthData[metricKey],
                  safeMin: metric['safeMin'] as double,
                  safeMax: metric['safeMax'] as double,
                  issueMin: metric['issueMin'] as double,
                  issueMax: metric['issueMax'] as double,
                  onNotePressed: () => showNoteDialog(context, noteKey, '${metric['title']} (${metric['unit']})'),
                  note: healthNotes[noteKey],
                  icon: metric['icon'] as IconData,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}