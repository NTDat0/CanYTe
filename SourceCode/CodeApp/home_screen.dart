// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'health_tracking_screen.dart';
import 'health_solution_screen.dart';
import 'notes_and_tasks_screen.dart'; // Đổi tên import từ task_notes_screen.dart
import 'health_evaluation.dart';
import 'task.dart'; // Import model Task

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _healthData = {};
  Map<String, String> _healthNotes = {};
  List<Task> _tasks = []; // Thêm trạng thái cho danh sách nhiệm vụ

  void _updateHealthDataAndNotes(
      Map<String, dynamic> newHealthData, Map<String, String> newHealthNotes) {
    setState(() {
      _healthData = newHealthData;
      _healthNotes = newHealthNotes;
    });
  }

  void _onNotesUpdated(Map<String, String> updatedNotes) {
    setState(() {
      _healthNotes = updatedNotes;
    });
  }

  void _onTasksUpdated(List<Task> updatedTasks) { // Callback mới cho nhiệm vụ
    setState(() {
      _tasks = updatedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng Sức khỏe'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào!', // Bạn có thể thay đổi tên này
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),

            // Các thẻ chức năng chính
            _buildCard(
              theme: theme,
              icon: Icons.monitor_heart,
              iconColor: Colors.blue.shade700,
              title: 'Theo dõi chỉ số',
              description: 'Xem và quản lý các chỉ số sức khỏe của bạn (nhịp tim, SpO2, nhiệt độ, độ ẩm, cân nặng).',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HealthTrackingScreen(
                      onDataUpdated: _updateHealthDataAndNotes,
                      initialHealthNotes: _healthNotes,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Thẻ Giải pháp Sức khỏe
            _buildCard(
              theme: theme,
              icon: Icons.lightbulb_outline,
              iconColor: Colors.orange.shade700,
              title: 'Giải pháp Sức khỏe',
              description: 'Nhận các gợi ý cá nhân hóa dựa trên dữ liệu sức khỏe của bạn.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HealthSolutionScreen(
                      healthData: _healthData,
                      notes: _healthNotes, // Vẫn truyền notes để dùng cho đánh giá tổng thể
                      tasks: _tasks, // Vẫn truyền tasks nếu cần cho logic gợi ý trong tương lai
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Thẻ Ghi chú & Nhiệm vụ
            _buildCard(
              theme: theme,
              icon: Icons.assignment,
              iconColor: Colors.purple.shade700,
              title: 'Ghi chú & Nhiệm vụ',
              description: 'Ghi lại các ghi chú sức khỏe quan trọng và quản lý các nhiệm vụ hàng ngày.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesAndTasksScreen(
                      initialHealthNotes: _healthNotes,
                      onNotesChanged: _onNotesUpdated,
                      initialTasks: _tasks,
                      onTasksChanged: _onTasksUpdated,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Bạn có thể thêm các thẻ khác ở đây nếu cần
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}