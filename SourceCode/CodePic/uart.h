#ifndef UART_H
#define UART_H

#include <16F877A.h>
#include <string.h>

#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7, stream=UART_STREAM)

void uart_init() {
   // UART du?c kh?i t?o b?i #use rs232
}

void uart_send_string(char *str) {
   while (*str) {
      putc(*str, UART_STREAM);
      delay_us(200); // Tang d? tr? d? d?m b?o g?i hoàn ch?nh
      str++;
   }
}

void uart_send_data(unsigned int8 temp, unsigned int8 hum, int32 hr_value, int32 spo2_value, int32 weight_grams) {
   char buffer[64]; // B? d?m d? l?n
   int1 has_data = 0;
   int pos = 0;

   buffer[0] = '\0';

   // Xây d?ng chu?i v?i m?t l?nh sprintf
   if (temp != 0 || hum != 0 || hr_value != 0 || spo2_value != 0 || weight_grams != 0) {
      if (temp != 0) {
         pos += sprintf(buffer + pos, "T:%u ", (unsigned int)temp);
         has_data = 1;
      }
      if (hum != 0) {
         pos += sprintf(buffer + pos, "H:%u ", (unsigned int)hum);
         has_data = 1;
      }
      if (hr_value != 0) {
         pos += sprintf(buffer + pos, "HR:%ld ", hr_value);
         has_data = 1;
      }
      if (spo2_value != 0) {
         pos += sprintf(buffer + pos, "SPO2:%ld ", spo2_value);
         has_data = 1;
      }
      if (weight_grams != 0) {
         pos += sprintf(buffer + pos, "W:%ld", weight_grams);
         has_data = 1;
      }
      if (has_data) {
         pos += sprintf(buffer + pos, "\n");
      }
   }

   // G?i chu?i n?u có d? li?u
   if (has_data) {
      uart_send_string(buffer);
   }
}

#endif
