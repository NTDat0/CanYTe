// lib/notes_and_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'task.dart'; // Import model Task

class NotesAndTasksScreen extends StatefulWidget {
  final Map<String, String> initialHealthNotes;
  final Function(Map<String, String>) onNotesChanged;
  final List<Task> initialTasks;
  final Function(List<Task>) onTasksChanged;

  const NotesAndTasksScreen({
    super.key,
    required this.initialHealthNotes,
    required this.onNotesChanged,
    required this.initialTasks,
    required this.onTasksChanged,
  });

  @override
  State<NotesAndTasksScreen> createState() => _NotesAndTasksScreenState();
}

class _NotesAndTasksScreenState extends State<NotesAndTasksScreen>
    with SingleTickerProviderStateMixin {
  late Map<String, String> _currentHealthNotes;
  late List<Task> _tasks;
  late TabController _tabController;
  final TextEditingController _newTaskGoalController = TextEditingController();
  final Uuid _uuid = const Uuid();

  // Biến tạm thời cho DateTimePicker, được khởi tạo trong initState
  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;

  @override
  void initState() {
    super.initState();
    _currentHealthNotes = Map<String, String>.from(widget.initialHealthNotes);
    _tasks = List<Task>.from(widget.initialTasks);

    // Khởi tạo _selectedDueDate và _selectedDueTime với giá trị mặc định hợp lý
    _selectedDueDate = DateTime.now();
    _selectedDueTime = TimeOfDay.now();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Tắt chế độ chỉnh sửa ghi chú khi chuyển tab
        _currentHealthNotes.forEach((key, value) {
          if (_noteControllers.containsKey(key)) {
            _noteControllers[key]?.dispose(); // Giải phóng controller cũ
          }
        });
        _noteControllers.clear();
        _isEditingNote.clear();
      });
    });
  }

  // Map để lưu trữ trạng thái chỉnh sửa của từng ghi chú
  final Map<String, bool> _isEditingNote = {};
  // Map để lưu trữ TextEditingController cho từng ghi chú
  final Map<String, TextEditingController> _noteControllers = {};

  // Cập nhật trạng thái notes và tasks nếu có sự thay đổi từ bên ngoài
  @override
  void didUpdateWidget(covariant NotesAndTasksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialHealthNotes != oldWidget.initialHealthNotes) {
      setState(() {
        _currentHealthNotes = Map<String, String>.from(widget.initialHealthNotes);
        // Cần cập nhật lại các controller nếu ghi chú bị xóa
        _noteControllers.keys.toList().forEach((key) {
          if (!_currentHealthNotes.containsKey(key)) {
            _noteControllers[key]?.dispose();
            _noteControllers.remove(key);
            _isEditingNote.remove(key);
          }
        });
      });
    }
    if (widget.initialTasks != oldWidget.initialTasks) {
      setState(() {
        _tasks = List<Task>.from(widget.initialTasks);
      });
    }
  }


  void _toggleEditNote(String key, String initialValue) {
    setState(() {
      if (_isEditingNote[key] == true) {
        // Đang ở chế độ chỉnh sửa, bấm lần nữa để lưu
        _currentHealthNotes[key] = _noteControllers[key]!.text;
        _noteControllers[key]?.dispose(); // Giải phóng controller sau khi lưu
        _noteControllers.remove(key);
        widget.onNotesChanged(_currentHealthNotes); // Cập nhật lên widget cha
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu ghi chú cho $key')),
        );
      } else {
        // Chuyển sang chế độ chỉnh sửa
        _noteControllers[key] = TextEditingController(text: initialValue);
      }
      _isEditingNote[key] = !(_isEditingNote[key] ?? false);
    });
  }

  // Hàm xóa ghi chú
  void _deleteNote(String key) {
    setState(() {
      _currentHealthNotes.remove(key);
      _noteControllers[key]?.dispose();
      _noteControllers.remove(key);
      _isEditingNote.remove(key);
      widget.onNotesChanged(_currentHealthNotes); // Cập nhật lên widget cha
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa ghi chú cho $key')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newTaskGoalController.dispose();
    _noteControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // Hàm hiển thị Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  // Hàm hiển thị Time Picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );
    if (picked != null && picked != _selectedDueTime) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  void _addNewTask() async {
    _newTaskGoalController.clear();
    // Reset ngày và giờ khi thêm nhiệm vụ mới
    _selectedDueDate = DateTime.now();
    _selectedDueTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Thêm nhiệm vụ mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newTaskGoalController,
                    decoration: const InputDecoration(
                      labelText: 'Mục tiêu nhiệm vụ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ngày đến hạn: ${DateFormat('dd/MM/yyyy').format(_selectedDueDate)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          await _selectDate(context);
                          setStateInDialog(() {}); // Cập nhật UI trong dialog
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Giờ đến hạn: ${_selectedDueTime.format(context)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          await _selectTime(context);
                          setStateInDialog(() {}); // Cập nhật UI trong dialog
                        },
                      ),
                    ],
                  ),
                ],
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
                    if (_newTaskGoalController.text.isNotEmpty) {
                      final newDueDate = DateTime(
                        _selectedDueDate.year,
                        _selectedDueDate.month,
                        _selectedDueDate.day,
                        _selectedDueTime.hour,
                        _selectedDueTime.minute,
                      );
                      setState(() {
                        _tasks.add(
                          Task(
                            id: _uuid.v4(),
                            goal: _newTaskGoalController.text,
                            createdAt: DateTime.now(),
                            dueDate: newDueDate,
                          ),
                        );
                        widget.onTasksChanged(_tasks);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Không xóa nhiệm vụ khi hoàn thành, chỉ đánh dấu là hoàn thành
  void _toggleTaskCompletion(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex].toggleComplete();
        widget.onTasksChanged(_tasks);
      }
    });
  }

  // Hàm xóa nhiệm vụ (chỉ sử dụng khi người dùng muốn xóa hẳn)
  void _deleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
      widget.onTasksChanged(_tasks);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nhiệm vụ đã được xóa.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Lọc các ghi chú có giá trị không rỗng để hiển thị
    final Map<String, String> displayNotes = Map.fromEntries(
      _currentHealthNotes.entries.where(
            (entry) => entry.value.isNotEmpty,
      ),
    );

    // Sắp xếp các nhiệm vụ: chưa hoàn thành và chưa quá hạn lên đầu, sau đó đến hoàn thành và quá hạn
    _tasks.sort((a, b) {
      final now = DateTime.now();
      final isACompleted = a.isCompleted;
      final isBCompleted = b.isCompleted;
      final isAOverdue = a.dueDate.isBefore(now) && !a.isCompleted;
      final isBOverdue = b.dueDate.isBefore(now) && !b.isCompleted;

      // Nhiệm vụ chưa hoàn thành và chưa quá hạn lên đầu
      if (!isACompleted && !isAOverdue && (isBCompleted || isBOverdue)) return -1;
      if (!isBCompleted && !isBOverdue && (isACompleted || isAOverdue)) return 1;

      // Nhiệm vụ quá hạn chưa hoàn thành sau đó
      if (isAOverdue && !isBOverdue) return -1;
      if (isBOverdue && !isAOverdue) return 1;

      // Nhiệm vụ đã hoàn thành xuống cuối
      if (isACompleted && !isBCompleted) return 1;
      if (!isACompleted && isBCompleted) return -1;

      // Sắp xếp theo ngày đến hạn (sớm hơn lên trước)
      return a.dueDate.compareTo(b.dueDate);
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú & Nhiệm vụ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ghi chú'),
            Tab(text: 'Nhiệm vụ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Ghi chú
          displayNotes.isEmpty
              ? _buildEmptyState(theme, 'Không có ghi chú nào',
              'Các ghi chú về sức khỏe sẽ xuất hiện ở đây sau khi bạn ghi lại từ màn hình Theo dõi chỉ số.')
              : ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: displayNotes.length,
            itemBuilder: (context, index) {
              final String key = displayNotes.keys.elementAt(index);
              final String value = displayNotes.values.elementAt(index);
              final bool isEditing = _isEditingNote[key] ?? false;
              final TextEditingController controller =
              _noteControllers.containsKey(key)
                  ? _noteControllers[key]!
                  : TextEditingController(text: value);

              // Đảm bảo controller tồn tại và được khởi tạo đúng cách
              if (!_noteControllers.containsKey(key)) {
                _noteControllers[key] = controller;
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              key, // Key chính là tiêu đề của ghi chú
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Nút xóa ghi chú
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error.withOpacity(0.7),
                                size: 20),
                            onPressed: () => _deleteNote(key), // Gọi hàm xóa ghi chú
                            tooltip: 'Xóa ghi chú',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isEditing)
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Nhập ghi chú...',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () => _toggleEditNote(key, value),
                            ),
                          ),
                          maxLines: null, // Cho phép nhập nhiều dòng
                          onSubmitted: (newValue) =>
                              _toggleEditNote(key, value),
                        )
                      else
                        InkWell(
                          onTap: () => _toggleEditNote(key, value),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  value.isEmpty ? 'Chạm để thêm ghi chú...' : value,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                                    color: value.isEmpty ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                                  ),
                                ),
                              ),
                              Icon(Icons.edit_outlined,
                                  color: theme.iconTheme.color
                                      ?.withOpacity(0.7),
                                  size: 20),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),

          // Tab Nhiệm vụ
          _tasks.isEmpty
              ? _buildEmptyState(theme, 'Không có nhiệm vụ nào',
              'Thêm nhiệm vụ của bạn để theo dõi tiến độ.')
              : ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              final bool isOverdue =
                  task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
              final bool isCompleted = task.isCompleted;

              // Xác định màu sắc và biểu tượng dựa trên trạng thái
              Color cardColor = theme.cardColor;
              Color textColor = theme.textTheme.bodyLarge!.color!;
              String statusText = '';
              IconData statusIcon = Icons.check_circle_outline; // Default icon

              if (isCompleted) {
                cardColor = Colors.green.shade50;
                textColor = Colors.green.shade800;
                statusText = 'Hoàn thành';
                statusIcon = Icons.check_circle;
              } else if (isOverdue) {
                cardColor = Colors.red.shade50;
                textColor = Colors.red.shade800;
                statusText = 'Đã quá hạn';
                statusIcon = Icons.error_outline;
              } else {
                // Sắp đến hạn
                if (task.dueDate.difference(DateTime.now()).inHours < 24) {
                  cardColor = Colors.orange.shade50;
                  textColor = Colors.orange.shade800;
                  statusText = 'Sắp đến hạn';
                  statusIcon = Icons.warning_amber_rounded;
                } else {
                  // Bình thường
                  cardColor = theme.cardColor;
                  textColor = theme.textTheme.bodyLarge!.color!;
                  statusText = ''; // Không hiển thị gì nếu bình thường
                }
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isCompleted ? Colors.green.shade200 : (isOverdue ? Colors.red.shade200 : Colors.transparent),
                    width: isCompleted || isOverdue ? 1.5 : 0,
                  ),
                ),
                color: cardColor,
                child: Opacity(
                  opacity: isCompleted ? 0.7 : 1.0, // Giảm độ mờ nếu đã hoàn thành
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isCompleted,
                          onChanged: (bool? newValue) {
                            _toggleTaskCompletion(task.id);
                          },
                          activeColor: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.goal,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14,
                                      color: textColor.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('HH:mm - dd/MM/yyyy')
                                        .format(task.dueDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: textColor.withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  if (statusText.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Icon(statusIcon, size: 14, color: textColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusText,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Nút xóa nhiệm vụ (có thể ẩn nếu không cần)
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error.withOpacity(0.7),
                                size: 20),
                            onPressed: () => _deleteTask(task.id),
                            tooltip: 'Xóa nhiệm vụ',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
        onPressed: _addNewTask,
        tooltip: 'Thêm nhiệm vụ mới',
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_snippet_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}