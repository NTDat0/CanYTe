#include <16F877A.h>
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=8000000)
#use fast_io(D)
#use fast_io(C)
#use fast_io(B)
#use standard_io(A)

#include "lcd.h"
#include "max30102.h"
#include "dht11.h"
#include "hx711.h"
#include "uart.h"

// --- Timing Interval Constants (in number of 5ms ticks) ---
#define DHT11_INTERVAL_TICKS        100 // 100 * 5ms = 500ms
// #define HX711_INTERVAL_TICKS        20  // OLD: 20 * 5ms = 100ms
#define HX711_INTERVAL_TICKS        50  // NEW: 50 * 5ms = 250ms (Try this, or 40, 60)
#define DISPLAY_UART_INTERVAL_TICKS 50  // 50 * 5ms = 250ms

// --- Other Constants ---
#define WEIGHT_DEADBAND             2  // Ngu?ng ch?t cho c�n n?ng (gram)

// Kh?i lu?ng v?t m?u d� bi?t d? hi?u chu?n (b?n c?n d?t v?t n�y l�n c�n)
// �?T GI� TR? N�Y CHO TR?NG LU?NG M� B?N S? D�NG �? HI?U CHU?N
#define KNOWN_WEIGHT_FOR_CALIBRATION 31.0 // V� d?: 100.0 gram (d?m b?o ch�nh x�c)

// Bi?n c? d? ki?m so�t vi?c hi?u chu?n ch? ch?y m?t l?n
int1 calibrate_done = FALSE;

// Display number on LCD (support 2, 3, or 5 digits)
void display_number(int32 num, int8 pos, int8 digits) {
   if (num > 99 && digits == 2) num = 99; // Limit to 2 digits for T, H
   if (num > 999 && digits == 3) num = 999; // Limit to 3 digits for HR, SpO2
   if (num > 99999 && digits == 5) num = 99999; // Limit to 5 digits for weight

   LCD_SetPosition(pos);
   if (digits == 2) {
      LCD_PutChar(num / 10 + '0'); // Tens digit
      LCD_PutChar(num % 10 + '0'); // Units digit
   } else if (digits == 3) {
      if (num >= 100) {
         LCD_PutChar(num / 100 + '0');
         LCD_PutChar((num % 100) / 10 + '0');
         LCD_PutChar(num % 10 + '0');
      } else if (num >= 10) {
         LCD_PutChar(' ');
         LCD_PutChar(num / 10 + '0');
         LCD_PutChar(num % 10 + '0');
      } else {
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(num + '0');
      }
   } else if (digits == 5) {
      if (num >= 10000) {
         LCD_PutChar(num / 10000 + '0');
         LCD_PutChar((num % 10000) / 1000 + '0');
         LCD_PutChar((num % 1000) / 100 + '0');
         LCD_PutChar((num % 100) / 10 + '0');
         LCD_PutChar(num % 10 + '0');
      } else if (num >= 1000) {
         LCD_PutChar(' ');
         LCD_PutChar(num / 1000 + '0');
         LCD_PutChar((num % 1000) / 100 + '0');
         LCD_PutChar((num % 100) / 10 + '0');
         LCD_PutChar(num % 10 + '0');
      } else if (num >= 100) {
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(num / 100 + '0');
         LCD_PutChar((num % 100) / 10 + '0');
         LCD_PutChar(num % 10 + '0');
      } else if (num >= 10) {
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(num / 10 + '0');
         LCD_PutChar(num % 10 + '0');
      } else {
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(' ');
         LCD_PutChar(num + '0');
      }
   }
   delay_us(20);
}

void main() {
   set_tris_d(0x00); // LCD on PORTD (output)
   set_tris_c(0b00011000); // PORTC for I2C (RC3, RC4 as input for I2C)
   set_tris_b(0xFF); // PORTB as input (for DHT11)
   set_tris_a(0x01); // A0 as input for HX711 DT, A1 as output for HX711 SCK

   // Initialize modules
   LCD_Init();
   delay_ms(50);
   max30102_init(); // Kh?i t?o MAX30102 v� reset c�c gi� tr?
   uart_init(); // Gi? s? h�m n�y t?n t?i v� ho?t d?ng

   // Skip initial HX711 readings for stability
   for (int i = 0; i < 5; i++) {
      readCount(); // H�m t? hx711.h
      delay_ms(10);
   }
   // Initial tare
   hx711_tare(1);
   delay_ms(100); // Ch? tare ?n d?nh hon m?t ch�t

   // Display static labels with units (c�ch hi?n th? ban d?u c?a b?n)
   LCD_SetPosition(LINE_1);
   LCD_PutChar('T'); LCD_PutChar(':'); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar('C'); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar('H'); LCD_PutChar(':'); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar('%');
   LCD_SetPosition(LINE_2);
   LCD_PutChar('H'); LCD_PutChar('R'); LCD_PutChar(':'); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar('b'); LCD_PutChar('p'); LCD_PutChar('m');
   LCD_SetPosition(LINE_3);
   LCD_PutChar('S'); LCD_PutChar('p'); LCD_PutChar('O'); LCD_PutChar('2'); LCD_PutChar(':'); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar('%');
   LCD_SetPosition(LINE_4);
   LCD_PutChar('W'); LCD_PutChar('e'); LCD_PutChar('i'); LCD_PutChar('g'); LCD_PutChar('h'); LCD_PutChar('t'); LCD_PutChar(':'); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar(' '); LCD_PutChar('g');

   // Independent timing counters
   int16 max30102_counter = 0;
   int16 dht11_counter = 0;
   int16 hx711_counter = 0;
   int16 display_counter = 0;

   unsigned int8 temp = 0;
   unsigned int8 hum = 0;
   int32 weight_grams = 0;
   // Assuming hr_value and spo2_value are global, declared in max30102.c/h
   // extern unsigned int16 hr_value;
   // extern unsigned int8 spo2_value;


   while (TRUE) {
      // --- Qu� tr�nh hi?u chu?n HX711 (ch? ch?y m?t l?n sau khi kh?i d?ng) ---
      if (!calibrate_done) {
         hx711_tare(1); // Bu?c 1: Tare c�n khi kh�ng c� g� tr�n d�
         delay_ms(2000); // Ch? 2 gi�y d? c�n ?n d?nh sau khi tare
         
         // Ch? m?t kho?ng th?i gian d? d? ngu?i d�ng d?t v?t m?u l�n
         // KH�NG C� TH�NG B�O TR�N LCD, b?n ph?i t? d?t v?t m?u.
         // �?M B?O B?N �?T V?T KNOWN_WEIGHT_FOR_CALIBRATION TRU?C KHI H?T TH?I GIAN N�Y
         delay_ms(5000); // V� d?: ch? 5 gi�y

         hx711_calibrate(KNOWN_WEIGHT_FOR_CALIBRATION); // Bu?c 2: Hi?u chu?n v?i v?t m?u d� bi?t
         delay_ms(1000); // Ch? 1 gi�y sau khi hi?u chu?n
         
         calibrate_done = TRUE; // �?t c? d? ch? ch?y m?t l?n
      }

      // MAX30102 - �?c m?i 5ms (max30102_counter % 1)
      if (max30102_counter == 0) {
         max30102_read_and_display();
      }
      max30102_counter = (max30102_counter + 1) % 1;

      // DHT11
      if (dht11_counter == 0) {
         dht11_read(&temp, &hum);
      }
      dht11_counter = (dht11_counter + 1) % DHT11_INTERVAL_TICKS;

      // HX711
      if (hx711_counter == 0) {
         float current_weight_float = hx711_get_units(1); // The '1' argument is unused in hx711.h
         // Round to nearest integer gram for display. Add 0.5 before casting for proper rounding.
         if (current_weight_float >= 0) {
            weight_grams = (int32)(current_weight_float + 0.5f);
         } else {
            // Your hx711.h already attempts to make corrected_weight >= 0.
            // This handles any potential case where it might still be slightly negative.
            weight_grams = (int32)(current_weight_float - 0.5f); // Proper rounding for negative numbers
         }
         // Ensure weight_grams does not go negative if hx711.h logic didn't catch it perfectly.
         // Or if you strictly want non-negative display:
         if (weight_grams < 0) {
            weight_grams = 0;
         }
      }
      hx711_counter = (hx711_counter + 1) % HX711_INTERVAL_TICKS;

      // Display update and UART transmission
      if (display_counter == 0) {
         display_number(temp, LINE_1 + 2, 2);
         display_number(hum, LINE_1 + 11, 2);
         display_number(hr_value, LINE_2 + 3, 3);
         display_number(spo2_value, LINE_3 + 5, 3);
         display_number(weight_grams, LINE_4 + 7, 5);
         uart_send_data(temp, hum, hr_value, spo2_value, weight_grams);
      }
      display_counter = (display_counter + 1) % DISPLAY_UART_INTERVAL_TICKS;

      delay_ms(5); // Base 5ms cycle
   }
}
