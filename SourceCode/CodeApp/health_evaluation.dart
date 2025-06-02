// health_evaluation.dart (Giữ nguyên như phiên bản trước)
String evaluateHealth(double? value, double safeMin, double safeMax, double issueMin, double issueMax) {
  if (value == null) return 'Không xác định';
  if (value < issueMin || value > issueMax) return 'Nghiêm trọng';
  if (value < safeMin || value > safeMax) return 'Có vấn đề';
  return 'Bình thường';
}

String getOverallHealthAssessment(Map<String, dynamic> healthData, Map<String, String> notes) { // Đảm bảo notes được truyền vào
  if (healthData.isEmpty) {
    return 'Dữ liệu sinh trắc không khả dụng. Vui lòng kiểm tra thiết bị đo hoặc kết nối với hệ thống giám sát sức khỏe.';
  }

  double? temp = healthData['temperature']?.toDouble();
  double? humidity = healthData['humidity']?.toDouble();
  double? heartRate = healthData['heart_rate']?.toDouble();
  double? spo2 = healthData['spo2']?.toDouble();
  double? weight = healthData['weight']?.toDouble();

  String notesSummary = notes.entries.where((e) => e.value.isNotEmpty).map((e) => '- ${e.key}: ${e.value}').join('\n');
  if (notesSummary.isNotEmpty) notesSummary = '\n\n**Ghi chú cá nhân của bạn:**\n$notesSummary';

  List<String> assessments = [];

  // Đánh giá SpO2
  if (spo2 != null) {
    if (spo2 < 90) {
      assessments.add('Nồng độ SpO2 quá thấp (${spo2.toStringAsFixed(1)}%). Đây là tình trạng nguy hiểm, cần được hỗ trợ y tế ngay lập tức.');
    } else if (spo2 < 95) {
      assessments.add('Nồng độ SpO2 thấp (${spo2.toStringAsFixed(1)}%). Có thể là dấu hiệu của vấn đề hô hấp, cần theo dõi và tham khảo ý kiến bác sĩ.');
    } else if (spo2 > 100) {
      assessments.add('Nồng độ SpO2 bất thường (${spo2.toStringAsFixed(1)}%). Mức oxy trong máu không thể vượt quá 100%, có thể thiết bị đo bị lỗi. Vui lòng kiểm tra lại.');
    }
  }

  // Đánh giá nhịp tim
  if (heartRate != null) {
    if (heartRate < 50) {
      assessments.add('Nhịp tim quá chậm (${heartRate.toStringAsFixed(0)} bpm). Có thể là nhịp tim chậm sinh lý ở vận động viên hoặc dấu hiệu của vấn đề sức khỏe. Nên tham khảo ý kiến bác sĩ.');
    } else if (heartRate > 100) {
      assessments.add('Nhịp tim quá nhanh (${heartRate.toStringAsFixed(0)} bpm). Có thể do căng thẳng, vận động hoặc bệnh lý. Cần theo dõi và thăm khám nếu kéo dài.');
    } else if (heartRate < 60 || heartRate > 90) {
      assessments.add('Nhịp tim (${heartRate.toStringAsFixed(0)} bpm) ngoài phạm vi lý tưởng (60-90 bpm khi nghỉ ngơi). Cần chú ý theo dõi.');
    }
  }

  // Đánh giá nhiệt độ môi trường
  if (temp != null) {
    // Ngưỡng nhiệt độ môi trường (thay đổi từ ngưỡng cơ thể)
    if (temp < 18) { // Quá lạnh
      assessments.add('Nhiệt độ môi trường quá thấp (${temp.toStringAsFixed(1)}°C). Có thể gây cảm lạnh, khô da hoặc ảnh hưởng đến hệ hô hấp. Nên điều chỉnh nhiệt độ phòng.');
    } else if (temp > 30) { // Quá nóng
      assessments.add('Nhiệt độ môi trường quá cao (${temp.toStringAsFixed(1)}°C). Có thể dẫn đến khó chịu, mất nước hoặc say nóng. Cần làm mát môi trường.');
    } else if (temp < 20 || temp > 28) { // Cần lưu ý
      assessments.add('Nhiệt độ môi trường (${temp.toStringAsFixed(1)}°C) ngoài mức thoải mái. Nên duy trì nhiệt độ trong khoảng 20-28°C để đảm bảo sức khỏe và sự thoải mái.');
    }
  }

  // Đánh giá độ ẩm môi trường
  if (humidity != null) {
    // Ngưỡng độ ẩm môi trường (thay đổi từ ngưỡng cơ thể)
    if (humidity < 30 || humidity > 70) { // Quá khô hoặc quá ẩm
      assessments.add('Độ ẩm môi trường ngoài ngưỡng khuyến nghị (${humidity.toStringAsFixed(1)}%). Có thể gây khô da, kích ứng đường hô hấp hoặc tạo điều kiện cho vi khuẩn/nấm mốc phát triển. Cần điều chỉnh môi trường ngay.');
    } else if (humidity < 40 || humidity > 60) { // Cần lưu ý
      assessments.add('Độ ẩm môi trường cần lưu ý (${humidity.toStringAsFixed(1)}%). Có thể ảnh hưởng đến sự thoải mái và sức khỏe hô hấp. Khuyến nghị sử dụng máy tạo độ ẩm hoặc thông gió.');
    }
  }

  // Đánh giá cân nặng
  if (weight != null) {
    if (weight < 40) {
      assessments.add('Cân nặng quá thấp (${weight.toStringAsFixed(1)} kg). Có thể cần tư vấn dinh dưỡng.');
    } else if (weight > 100) {
      assessments.add('Cân nặng quá cao (${weight.toStringAsFixed(1)} kg). Cần xem xét chế độ ăn và vận động.');
    } else if (weight < 45 || weight > 80) {
      assessments.add('Cân nặng (${weight.toStringAsFixed(1)} kg) ngoài phạm vi lý tưởng. Nên duy trì chế độ ăn và tập luyện hợp lý.');
    }
  }

  if (assessments.isEmpty) {
    return 'Tất cả các chỉ số của bạn đều ở mức bình thường. Hãy tiếp tục duy trì lối sống lành mạnh!';
  } else {
    return 'Dưới đây là một số đánh giá về sức khỏe của bạn:\n\n' +
        assessments.map((e) => '• $e').join('\n') + notesSummary;
  }
}