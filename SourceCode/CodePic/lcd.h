#ifndef __LCD_H
#define __LCD_H

#define LCD_RS PIN_D2
#define LCD_EN PIN_D3
#define LCD_D4 PIN_D4
#define LCD_D5 PIN_D5
#define LCD_D6 PIN_D6
#define LCD_D7 PIN_D7

#define LINE_1 0x80
#define LINE_2 0xC0
#define LINE_3 0x90
#define LINE_4 0xD0
#define CLEAR_SCR 0x01

#separate void LCD_Init(void);
#separate void LCD_SetPosition(unsigned int pos);
#separate void LCD_PutChar(unsigned int c);
#separate void LCD_PutCmd(unsigned int cmd);
#separate void LCD_PulseEnable(void);
#separate void LCD_SetData(unsigned int data);

#separate void LCD_Init(void) {
   LCD_SetData(0x00);
   delay_ms(200);
   output_low(LCD_RS);
   LCD_SetData(0x03);
   LCD_PulseEnable();
   LCD_PulseEnable();
   LCD_PulseEnable();
   LCD_SetData(0x02);
   LCD_PulseEnable();
   LCD_PutCmd(0x2C); // 4-bit, 2-line, 5x8 dots
   LCD_PutCmd(0x0C); // Display on, cursor off
   LCD_PutCmd(0x06); // Entry mode: increment, no shift
   LCD_PutCmd(CLEAR_SCR); // Clear display
}

#separate void LCD_SetPosition(unsigned int pos) {
   LCD_PutCmd(pos & 0xFF);
}

#separate void LCD_PutChar(unsigned int c) {
   output_high(LCD_RS);
   LCD_PutCmd(c);
   output_low(LCD_RS);
}

#separate void LCD_PutCmd(unsigned int cmd) {
   LCD_SetData((cmd >> 4) & 0x0F);
   LCD_PulseEnable();
   LCD_SetData(cmd & 0x0F);
   LCD_PulseEnable();
}

#separate void LCD_PulseEnable(void) {
   output_high(LCD_EN);
   delay_us(1);
   output_low(LCD_EN);
   delay_ms(1);
}

#separate void LCD_SetData(unsigned int data) {
   output_bit(LCD_D4, data & 0x01);
   output_bit(LCD_D5, data & 0x02);
   output_bit(LCD_D6, data & 0x04);
   output_bit(LCD_D7, data & 0x08);
}

#endif
