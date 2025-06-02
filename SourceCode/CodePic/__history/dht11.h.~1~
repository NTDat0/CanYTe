#ifndef DHT11_H
#define DHT11_H

#define DHT11_PIN PIN_B1

// Hàm g?i tín hi?u kh?i d?ng d?n DHT11
void dht11_start() {
   set_tris_b(0x00); // Ğ?t RB1 làm output
   output_low(DHT11_PIN);
   delay_ms(20); // Tín hi?u th?p 20ms
   output_high(DHT11_PIN);
   delay_us(40); // Tín hi?u cao 40us
   set_tris_b(0x03); // Ğ?t RB1 làm input (gi? RB0 làm input cho HX711)
}

// Hàm d?c d? li?u t? DHT11
unsigned int8 dht11_read(unsigned int8 *temperature, unsigned int8 *humidity) {
   unsigned int8 data[5] = {0, 0, 0, 0, 0};
   unsigned int16 timeout;
   int i, j;
   
   // G?i tín hi?u kh?i d?ng
   dht11_start();
   
   // Ch? ph?n h?i t? DHT11 (m?c th?p 80us, sau dó m?c cao 80us)
   timeout = 0;
   while(input(DHT11_PIN)) { // Ch? m?c th?p
      delay_us(1);
      timeout++;
      if(timeout > 500) return 0; // Timeout
   }
   
   timeout = 0;
   while(!input(DHT11_PIN)) { // Ch? m?c cao
      delay_us(1);
      timeout++;
      if(timeout > 500) return 0; // Timeout
   }
   
   timeout = 0;
   while(input(DHT11_PIN)) { // Ch? k?t thúc m?c cao
      delay_us(1);
      timeout++;
      if(timeout > 500) return 0; // Timeout
   }
   
   // Ğ?c 40 bit d? li?u (5 byte)
   for(i = 0; i < 5; i++) {
      for(j = 0; j < 8; j++) {
         timeout = 0;
         while(!input(DHT11_PIN)) { // Ch? tín hi?u cao
            delay_us(1);
            timeout++;
            if(timeout > 500) return 0;
         }
         
         delay_us(40); // Ği?m gi?a 26us (bit 0) và 70us (bit 1)
         if(input(DHT11_PIN)) {
            data[i] |= (1 << (7 - j)); // Bit 1
         }
         
         timeout = 0;
         while(input(DHT11_PIN)) { // Ch? tín hi?u th?p
            delay_us(1);
            timeout++;
            if(timeout > 500) return 0;
         }
      }
   }
   
   // Ki?m tra checksum
   if(data[4] != (data[0] + data[1] + data[2] + data[3])) {
      return 0; // Checksum sai
   }
   
   // Ki?m tra d? li?u có h?p l? không
   if(data[0] == 0 && data[2] == 0) {
      return 0; // D? li?u không h?p l? (d? ?m và nhi?t d? d?u là 0)
   }
   
   // Ki?m tra và gi?i h?n giá tr? nhi?t d? và d? ?m
   if(data[2] > 80) { // Nhi?t d? t?i da h?p lı là 80°C
      data[2] = 80;
   }
   if(data[0] > 100) { // Ğ? ?m t?i da h?p lı là 100%
      data[0] = 100;
   }
   
   *humidity = data[0];    // Ğ? ?m
   *temperature = data[2]; // Nhi?t d?
   return 1; // Thành công
}

#endif
