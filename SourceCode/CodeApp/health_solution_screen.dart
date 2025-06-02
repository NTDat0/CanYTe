// lib/health_solution_screen.dart
import 'package:flutter/material.dart';
import 'health_evaluation.dart';
import 'task.dart';
import 'package:intl/intl.dart';

class HealthSolutionScreen extends StatefulWidget {
  final Map<String, dynamic> healthData;
  final Map<String, String> notes; // Đảm bảo notes được truyền vào
  final List<Task> tasks;

  const HealthSolutionScreen({
    super.key,
    required this.healthData,
    required this.notes, // Đảm bảo notes được truyền vào
    required this.tasks,
  });

  @override
  State<HealthSolutionScreen> createState() => _HealthSolutionScreenState();
}

class _HealthSolutionScreenState extends State<HealthSolutionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Map<String, String>> suggestions = [
      {
        'title': 'Chế độ ăn uống cân bằng',
        'description': 'Tập trung vào rau xanh, trái cây, protein nạc và ngũ cốc nguyên hạt. Hạn chế thực phẩm chế biến sẵn, đường và chất béo không lành mạnh. Uống đủ nước mỗi ngày.',
        'asset_path': 'assets/images/diet.jpg',
      },
      {
        'title': 'Tập thể dục đều đặn',
        'description': 'Đặt mục tiêu 30 phút hoạt động thể chất vừa phải hầu hết các ngày trong tuần. Kết hợp các bài tập cardio, sức mạnh và linh hoạt.',
        'asset_path': 'assets/images/exercise.jpg',
      },
      {
        'title': 'Ngủ đủ giấc',
        'description': 'Mục tiêu 7-9 giờ ngủ mỗi đêm. Tạo thói quen đi ngủ đều đặn, đảm bảo phòng ngủ tối, yên tĩnh và mát mẻ.',
        'asset_path': 'assets/images/sleep.jpg',
      },
      {
        'title': 'Quản lý căng thẳng',
        'description': 'Thực hành các kỹ thuật thư giãn như thiền, yoga, hoặc hít thở sâu. Dành thời gian cho sở thích và kết nối xã hội.',
        'asset_path': 'assets/images/stress_management.jpg',
      },
      {
        'title': 'Kiểm tra sức khỏe định kỳ',
        'description': 'Thăm khám bác sĩ định kỳ để kiểm tra sức khỏe tổng quát và phát hiện sớm các vấn đề tiềm ẩn.',
        'asset_path': 'assets/images/checkup.jpg',
      },
    ];

    // Lọc các gợi ý không có dữ liệu cần thiết
    final List<Map<String, String>> filteredSuggestions = suggestions.where((s) {
      // Logic để kiểm tra xem gợi ý có liên quan đến dữ liệu bị thiếu hay không.
      // Ví dụ, nếu gợi ý về nhiệt độ nhưng healthData không có nhiệt độ, thì loại bỏ.
      // Hiện tại, chúng ta đã thêm điều kiện `if (widget.healthData['temperature'] != null)` trực tiếp ở trên,
      // nên bước lọc này có thể không cần thiết nếu các gợi ý đã được thêm có điều kiện.
      return true;
    }).toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải pháp sức khỏe'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              getOverallHealthAssessment(widget.healthData, widget.notes), // Sử dụng notes từ widget
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          if (filteredSuggestions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 24),
                    Text(
                      'Không có gợi ý cụ thể nào vào lúc này',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hãy đảm bảo dữ liệu sức khỏe của bạn được cập nhật để nhận các gợi ý phù hợp.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: filteredSuggestions.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildSuggestionCard(
                            theme, filteredSuggestions[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      filteredSuggestions.length,
                          (index) => _buildDotIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildSuggestionCard(
      ThemeData theme, Map<String, String> suggestion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack( // Use Stack to layer the image and the overlay
          children: [
            Positioned.fill( // Fills the entire stack with the image
              child: Image.asset(
                suggestion['asset_path']!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill( // Fills the entire stack with the darkening overlay
              child: Container(
                color: Colors.black.withOpacity(0.4), // Apply the desired darkening color and opacity
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    suggestion['title']!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      suggestion['description']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                        height: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}