// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Đảm bảo bạn có file home_screen.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/src/platform_flutter_local_notifications.dart'; // Bỏ comment nếu cần cho phiên bản cũ

// Khởi tạo plugin thông báo ở cấp độ top-level
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Hàm xử lý thông báo nền (Background Notification Handler)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // TODO: Implement your background notification handling logic here.
  print('Background notification tapped!');
  print('Payload: ${notificationResponse.payload}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Your app icon

  const DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      print('Foreground notification tapped!');
      print('Payload: ${notificationResponse.payload}');
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF009688); // Teal đậm vừa
    const Color secondaryColor = Color(0xFF80CBC4); // Teal nhạt
    const Color backgroundColor = Color(0xFFF7F9FC); // Nền xám rất nhạt
    const Color surfaceColor = Colors.white; // Bề mặt thẻ
    const Color textPrimaryColor = Color(0xFF1A2E35); // Xám đen cho chữ chính
    const Color textSecondaryColor = Color(0xFF5F6F74); // Xám vừa cho chữ phụ

    // Màu trạng thái (giữ nguyên như file gốc của bạn nếu muốn, hoặc tùy chỉnh)
    // Giả sử bạn muốn dùng màu từ ColorScheme cho tiện
    // final ColorScheme appColorScheme = ColorScheme.fromSeed(
    //   seedColor: primaryColor,
    //   // ... (các màu khác sẽ được tạo tự động hoặc bạn có thể ghi đè)
    // );
    // const Color statusNormalColor = appColorScheme.secondary; // Ví dụ
    // const Color statusIssueColor = appColorScheme.tertiary; // Ví dụ
    // const Color statusSevereColor = appColorScheme.error; // Ví dụ

    // Hoặc định nghĩa trực tiếp các màu trạng thái như cũ
    const Color statusNormalColor = Color(0xFF50E3C2); // Teal (giống secondary cũ của bạn)
    const Color statusIssueColor = Color(0xFFF8E71C); // Yellow/Amber (giống tertiary cũ)
    const Color statusSevereColor = Color(0xFFD0021B); // Red (giống error cũ)


    return MaterialApp(
      title: 'Health Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: statusNormalColor, // Màu 'Bình thường'
          onSecondary: textPrimaryColor,
          tertiary: statusIssueColor, // Màu 'Có vấn đề'
          onTertiary: textPrimaryColor,
          error: statusSevereColor, // Màu 'Nghiêm trọng'
          onError: Colors.white,
          background: backgroundColor,
          onBackground: textPrimaryColor,
          surface: surfaceColor,
          onSurface: textPrimaryColor,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0, // Bỏ shadow cho phẳng hơn, hiện đại hơn
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600, // Đậm vừa
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 24),
        ),

        cardTheme: CardTheme(
          elevation: 2, // Giảm độ nổi cho nhẹ nhàng
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Bo góc nhiều hơn
          ),
          color: surfaceColor,
          shadowColor: Colors.black.withOpacity(0.05), // Bóng mờ rất nhẹ
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Thêm margin ngang
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 1, // Giảm elevation
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor.withOpacity(0.7), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Nền trắng cho input
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Bỏ border mặc định
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: statusSevereColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: statusSevereColor, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          labelStyle: TextStyle(color: textSecondaryColor, fontSize: 15),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontStyle: FontStyle.italic),
        ),

        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: surfaceColor,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryColor),
          contentTextStyle: TextStyle(fontSize: 16, color: textSecondaryColor, height: 1.5),
          elevation: 4,
        ),

        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: textPrimaryColor),
          headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimaryColor),
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimaryColor),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryColor), // Giảm size cho title
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryColor),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimaryColor, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondaryColor, height: 1.4),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondaryColor, height: 1.3),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryColor),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.grey.shade600),
        ).apply(
          bodyColor: textPrimaryColor,
          displayColor: textPrimaryColor,
        ),

        iconTheme: IconThemeData(
          color: textSecondaryColor,
          size: 22.0, // Kích thước icon mặc định nhỏ hơn chút
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}