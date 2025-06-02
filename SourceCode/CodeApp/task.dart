// lib/models/task.dart
import 'package:flutter/material.dart';

class Task {
  final String id;
  String goal;
  DateTime createdAt;
  DateTime dueDate; // Ngày và giờ hoàn thành
  bool isCompleted;

  Task({
    required this.id,
    required this.goal,
    required this.createdAt,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Chuyển đổi từ Map sang Task object (để đọc từ Firebase nếu cần)
  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      goal: data['goal'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      dueDate: DateTime.parse(data['dueDate'] as String),
      isCompleted: data['isCompleted'] as bool? ?? false, // Đảm bảo giá trị mặc định
    );
  }

  // Chuyển đổi Task object sang Map (để lưu vào Firebase nếu cần)
  Map<String, dynamic> toMap() {
    return {
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Phương thức để cập nhật trạng thái hoàn thành
  void toggleComplete() {
    isCompleted = !isCompleted;
  }
}