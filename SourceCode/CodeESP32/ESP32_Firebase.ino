#include <WiFi.h>
#include <FirebaseESP32.h>
#include <HardwareSerial.h>

// Định nghĩa chân UART2 cho ESP32
#define RX_PIN 16
#define TX_PIN 17

// Thông tin Wi-Fi
#define WIFI_SSID "Phong 204" // Thay bằng SSID Wi-Fi của bạn
#define WIFI_PASSWORD "sangthuc123" // Thay bằng mật khẩu Wi-Fi

// Thông tin Firebase
#define FIREBASE_HOST "https://doan1-930dd-default-rtdb.firebaseio.com" // Thay bằng Database URL thực tế
#define FIREBASE_AUTH "n56AtCfyhQ9PaiN9FnwJI4xw0fQ9abhXXv0CstO6" // Thay bằng Web API Key thực tế

// Khởi tạo Firebase
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;
String path = "/";

void setup() {
   // Khởi tạo Serial để hiển thị kết quả
   Serial.begin(115200);
   // Khởi tạo UART2 để giao tiếp với PIC16F877A
   Serial2.begin(9600, SERIAL_8N1, RX_PIN, TX_PIN);

   // Kết nối Wi-Fi
   WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
   Serial.print("Đang kết nối Wi-Fi...");
   while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
   }
   Serial.println("Đã kết nối!");

   // Cấu hình Firebase
   config.host = FIREBASE_HOST; // Sử dụng database_url thay vì host
   config.signer.tokens.legacy_token = FIREBASE_AUTH;
   Firebase.begin(&config, &auth);
   Firebase.reconnectWiFi(true);
   Serial.println("Đã kết nối Firebase!");
}

void loop() {
   if (Serial2.available()) {
      // Đọc chuỗi đến ký tự xuống dòng
      String data = "";
      while (Serial2.available()) {
         char c = Serial2.read();
         data += c;
         if (c == '\n') break;
      }
      data.trim();

      // Biến lưu giá trị cảm biến
      int temp = 0, hum = 0, hr = 0, spo2 = 0, weight = 0;
      bool hasData = false;

      // Phân tích chuỗi theo khoảng trắng
      int startIndex = 0;
      while (startIndex < data.length()) {
         int endIndex = data.indexOf(' ', startIndex);
         if (endIndex == -1) endIndex = data.length();
         String token = data.substring(startIndex, endIndex);
         int colonIndex = token.indexOf(':');
         if (colonIndex != -1) {
            String key = token.substring(0, colonIndex);
            int value = token.substring(colonIndex + 1).toInt();
            
            // Kiểm tra giá trị hợp lệ
            if (key == "T") {
               if (value >= 10 && value <= 50) { // Nhiệt độ hợp lý: 10–50°C
                  temp = value;
                  hasData = true;
               }
            } else if (key == "H") {
               if (value >= 10 && value <= 99) { // Độ ẩm hợp lý: 10–99%
                  hum = value;
                  hasData = true;
               }
            } else if (key == "HR") {
               if (value >= 30 && value <= 200) { // Nhịp tim hợp lý: 30–200 bpm
                  hr = value;
                  hasData = true;
               }
            } else if (key == "SPO2") {
               if (value >= 50 && value <= 100) { // SpO2 hợp lý: 50–100%
                  spo2 = value;
                  hasData = true;
               }
            } else if (key == "W") {
               if (value >= 0 && value <= 99999) { // Cân nặng: 0–99999g
                  weight = value;
                  hasData = true;
               }
            }
         }
         startIndex = endIndex + 1;
      }

      // Hiển thị và publish nếu có dữ liệu hợp lệ
      if (hasData) {
         // Hiển thị trên Serial Monitor
         if (temp != 0) Serial.printf("Nhiệt độ: %d C\n", temp);
         if (hum != 0) Serial.printf("Độ ẩm: %d%%\n", hum);
         if (hr != 0) Serial.printf("Nhịp tim: %d bpm\n", hr);
         if (spo2 != 0) Serial.printf("SpO2: %d%%\n", spo2);
         if (weight != 0) Serial.printf("Cân nặng: %d g\n", weight);
         Serial.println("-------------------");

         // Publish lên Firebase
         if (WiFi.status() == WL_CONNECTED) {
            if (temp != 0) {
               if (Firebase.setInt(fbdo, "/sensors/temperature", temp)) {
                  Serial.println("Đã gửi nhiệt độ lên Firebase!");
               } else {
                  Serial.println("Lỗi gửi nhiệt độ: " + fbdo.errorReason());
               }
            }
            if (hum != 0) {
               if (Firebase.setInt(fbdo, "/sensors/humidity", hum)) {
                  Serial.println("Đã gửi độ ẩm lên Firebase!");
               } else {
                  Serial.println("Lỗi gửi độ ẩm: " + fbdo.errorReason());
               }
            }
            if (hr != 0) {
               if (Firebase.setInt(fbdo, "/sensors/heart_rate", hr)) {
                  Serial.println("Đã gửi nhịp tim lên Firebase!");
               } else {
                  Serial.println("Lỗi gửi nhịp tim: " + fbdo.errorReason());
               }
            }
            if (spo2 != 0) {
               if (Firebase.setInt(fbdo, "/sensors/spo2", spo2)) {
                  Serial.println("Đã gửi SpO2 lên Firebase!");
               } else {
                  Serial.println("Lỗi gửi SpO2: " + fbdo.errorReason());
               }
            }
            if (weight != 0) {
               if (Firebase.setInt(fbdo, "/sensors/weight", weight)) {
                  Serial.println("Đã gửi cân nặng lên Firebase!");
               } else {
                  Serial.println("Lỗi gửi cân nặng: " + fbdo.errorReason());
               }
            }
         } else {
            Serial.println("Wi-Fi ngắt kết nối!");
            WiFi.reconnect();
         }
      }
   }
   delay(500); // Gửi mỗi 500ms để tránh quá tải Firebase
}