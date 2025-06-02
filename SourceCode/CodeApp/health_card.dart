// health_card.dart
import 'package:flutter/material.dart';

class HealthCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final double safeMin, safeMax, issueMin, issueMax;
  final VoidCallback onNotePressed;
  final String? note;
  final IconData icon;

  const HealthCard({
    super.key,
    required this.title,
    required this.value,
    required this.safeMin,
    required this.safeMax,
    required this.issueMin,
    required this.issueMax,
    required this.onNotePressed,
    this.note,
    required this.icon,
  });

  String evaluateHealth(double? val, double safeMin, double safeMax,
      double issueMin, double issueMax) {
    if (val == null) return 'Không xác định';
    if (val < issueMin || val > issueMax) return 'Nghiêm trọng';
    if (val < safeMin || val > safeMax) return 'Có vấn đề';
    return 'Bình thường';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? doubleValue = (value is String)
        ? double.tryParse(value as String)
        : value?.toDouble();

    String status = evaluateHealth(doubleValue, safeMin, safeMax, issueMin, issueMax);
    Color statusColor;
    Color cardBorderColor;
    Color cardBackgroundColor;
    Color iconBackgroundColor;

    switch (status) {
      case 'Nghiêm trọng':
        statusColor = theme.colorScheme.error;
        cardBorderColor = theme.colorScheme.error.withOpacity(0.4);
        cardBackgroundColor = theme.colorScheme.error.withOpacity(0.08);
        iconBackgroundColor = theme.colorScheme.error.withOpacity(0.15);
        break;
      case 'Có vấn đề':
        statusColor = theme.colorScheme.tertiary;
        cardBorderColor = theme.colorScheme.tertiary.withOpacity(0.4);
        cardBackgroundColor = theme.colorScheme.tertiary.withOpacity(0.08);
        iconBackgroundColor = theme.colorScheme.tertiary.withOpacity(0.15);
        break;
      case 'Không xác định':
        statusColor = theme.colorScheme.onSurface.withOpacity(0.5);
        cardBorderColor = Colors.grey.shade300;
        cardBackgroundColor = Colors.grey.shade50;
        iconBackgroundColor = Colors.grey.shade200;
        break;
      default: // Bình thường
        statusColor = theme.colorScheme.secondary; // Sử dụng secondary cho 'Bình thường'
        cardBorderColor = theme.colorScheme.secondary.withOpacity(0.4);
        cardBackgroundColor = theme.colorScheme.secondary.withOpacity(0.08);
        iconBackgroundColor = theme.colorScheme.secondary.withOpacity(0.15);
        break;
    }

    String displayValue;
    if (value == null) {
      displayValue = "--";
    } else if (value is double) {
      displayValue = value.toStringAsFixed(1);
    } else {
      displayValue = value.toString();
    }

    return Card(
      elevation: 1.5, // Giảm elevation
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Bo góc nhiều hơn
        side: BorderSide(color: cardBorderColor, width: 1.5),
      ),
      child: InkWell(
        onTap: onNotePressed,
        borderRadius: BorderRadius.circular(18), // Phải giống card shape
        splashColor: statusColor.withOpacity(0.1),
        highlightColor: statusColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16), // Tăng padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều không gian
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: iconBackgroundColor,
                    child: Icon(icon, size: 20, color: statusColor),
                  ),
                  Flexible( // Cho phép title thu nhỏ nếu cần
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2, // Cho phép 2 dòng
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 10), // Bỏ SizedBox để MainAxisAlignment.spaceBetween làm việc
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayValue,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status, // Hiển thị trạng thái chữ
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // const SizedBox(height: 4),// Bỏ SizedBox
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'An toàn: $safeMin - $safeMax',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.edit_note_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            note!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              // Nút chỉnh sửa ghi chú, có thể bỏ nếu InkWell đã đủ
              // Align(
              //   alignment: Alignment.bottomRight,
              //   child: IconButton(
              //     icon: Icon(Icons.edit_outlined, color: theme.iconTheme.color?.withOpacity(0.7), size: 20),
              //     onPressed: onNotePressed,
              //     tooltip: 'Chỉnh sửa ghi chú',
              //     padding: EdgeInsets.zero,
              //     constraints: const BoxConstraints(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}