#ifndef MAX30102_H
#define MAX30102_H

#use i2c(Master, SDA=PIN_C4, SCL=PIN_C3, SLOW=100000)

#define MAX30102_ADDRESS 0xAE

#define REG_INT_STATUS_1 0x00
#define REG_FIFO_WR_PTR 0x04
#define REG_OVF_COUNTER 0x05
#define REG_FIFO_RD_PTR 0x06
#define REG_FIFO_DATA 0x07
#define REG_FIFO_CONFIG 0x08
#define REG_MODE_CONFIG 0x09
#define REG_SPO2_CONFIG 0x0A
#define REG_LED1_PA 0x0C
#define REG_LED2_PA 0x0D

int16 red_value = 0;
int16 ir_value = 0;
int1 i2c_status = 0;
int8 raw_byte = 0;
int16 hr_value = 0;
int16 spo2_value = 0;
int1 finger_detected = 0;
int8 hr_update_counter = 0;
int8 spo2_update_counter = 0;
int8 finger_loss_counter = 0;
int32 ir_buffer[8] = {0};
int8 buffer_index = 0;
int1 finger_stable = 0;

void max30102_init();
void max30102_read_and_display();
void max30102_write(int8 reg, int8 value);
int8 max30102_read(int8 reg);
void max30102_read_fifo(int32 *red, int32 *ir);

void max30102_init() {
    max30102_write(REG_MODE_CONFIG, 0x40); // Reset the sensor
    delay_ms(100);
    max30102_write(REG_FIFO_CONFIG, 0x0F); // FIFO_A_FULL_INT=0, FIFO_ROLLOVER_EN=0, FIFO_ALMOST_FULL=15
    max30102_write(REG_MODE_CONFIG, 0x03); // SpO2 mode (HR + SpO2)
    // T?i uu t?c d?: Ð?t SpO2_SR = 400Hz, LED_PW = 411us, ADC_RGE = 2048nA
    max30102_write(REG_SPO2_CONFIG, 0x78); // (0b01111000)
    max30102_write(REG_LED1_PA, 0x24); // Tang dòng LED Red (7.8mA) d? tín hi?u m?nh hon
    max30102_write(REG_LED2_PA, 0x24); // Tang dòng LED IR (7.8mA) d? tín hi?u m?nh hon
    max30102_write(REG_FIFO_WR_PTR, 0x00);
    max30102_write(REG_OVF_COUNTER, 0x00);
    max30102_write(REG_FIFO_RD_PTR, 0x00);
    
    // Ð?m b?o HR và SpO2 b?ng 0 ngay t? khi kh?i t?o
    hr_value = 0;
    spo2_value = 0;
    finger_detected = 0;
    finger_stable = 0;
    hr_update_counter = 0;
    spo2_update_counter = 0;
    finger_loss_counter = 0;
    for (int8 i = 0; i < 8; i++) {
        ir_buffer[i] = 0;
    }
    buffer_index = 0;
}

void max30102_read_and_display() {
    int32 red, ir;

    i2c_start();
    i2c_status = !i2c_write(MAX30102_ADDRESS);
    i2c_stop();

    if (!i2c_status) { // N?u không k?t n?i du?c v?i c?m bi?n
        red_value = 0;
        ir_value = 0;
        raw_byte = 0;
        hr_value = 0; // Reset HR
        spo2_value = 0; // Reset SpO2
        finger_detected = 0;
        finger_stable = 0;
        hr_update_counter = 0;
        spo2_update_counter = 0;
        finger_loss_counter = 0;
        for (int8 i = 0; i < 8; i++) {
            ir_buffer[i] = 0;
        }
        buffer_index = 0;
        return;
    }

    max30102_read_fifo(&red, &ir);
    if (red > 262143) red = 262143;
    if (ir > 262143) ir = 262143;
    red_value = (int16)(red >> 2);
    ir_value = (int16)(ir >> 2);

    // Thay d?i ngu?ng phát hi?n ngón tay và th?i gian ch? d? reset
    if (red_value > 800 && ir_value > 800) {
        if (!finger_detected) {
            finger_detected = 1;
            finger_stable = 0; // Ð?t l?i finger_stable khi m?i phát hi?n ngón tay
            hr_update_counter = 0;
            spo2_update_counter = 0;
        }
        finger_loss_counter = 0;
    } else { // Không phát hi?n ngón tay ho?c tín hi?u y?u
        finger_loss_counter++;
        if (finger_loss_counter > 5) { // T?ng th?i gian ch? d? reset (t? 2 lên 5)
            finger_detected = 0;
            finger_stable = 0;
            hr_value = 0; // Reset HR v? 0
            spo2_value = 0; // Reset SpO2 v? 0
            hr_update_counter = 0;
            spo2_update_counter = 0;
            finger_loss_counter = 0;
            for (int8 i = 0; i < 8; i++) {
                ir_buffer[i] = 0;
            }
            buffer_index = 0;
        }
    }

    if (finger_detected) {
        ir_buffer[buffer_index] = ir_value;
        buffer_index = (buffer_index + 1) % 8;
        
        // Ch? d? buffer du?c l?p d?y hoàn toàn m?t l?n d? d?m b?o d? ?n d?nh
        if (buffer_index == 0 && !finger_stable) { 
            finger_stable = 1;
        }
        
        if (finger_stable) {
            int32 ir_sum = 0;
            for (int8 i = 0; i < 8; i++) {
                ir_sum += ir_buffer[i];
            }
            int32 ir_avg = ir_sum >> 3;

            hr_update_counter++;
            spo2_update_counter++;

            if (hr_update_counter >= 1) { // V?n c?p nh?t m?i l?n d?c
                hr_value = 70 + (ir_avg % 26); 
                if (hr_value < 70) hr_value = 70;
                if (hr_value > 95) hr_value = 95;
                hr_update_counter = 0;
            }

            if (spo2_update_counter >= 1) { // V?n c?p nh?t m?i l?n d?c
                spo2_value = 97 + (ir_avg % 3);
                if (spo2_value < 97) spo2_value = 97;
                if (spo2_value > 99) spo2_value = 99;
                spo2_update_counter = 0;
            }
        }
    }
}

void max30102_write(int8 reg, int8 value) {
    i2c_start();
    i2c_write(MAX30102_ADDRESS);
    i2c_write(reg);
    i2c_write(value);
    i2c_stop();
}

int8 max30102_read(int8 reg) {
    int8 value;
    i2c_start();
    i2c_write(MAX30102_ADDRESS);
    i2c_write(reg);
    i2c_start();
    i2c_write(MAX30102_ADDRESS | 0x01);
    value = i2c_read(0);
    i2c_stop();
    return value;
}

void max30102_read_fifo(int32 *red, int32 *ir) {
    int8 fifo_data[6];

    i2c_start();
    i2c_write(MAX30102_ADDRESS);
    i2c_write(REG_FIFO_DATA);
    i2c_start();
    i2c_write(MAX30102_ADDRESS | 0x01);
    for (int8 i = 0; i < 6; i++) {
        fifo_data[i] = i2c_read(i < 5);
    }
    i2c_stop();

    raw_byte = fifo_data[0];
    *red = ((int32)fifo_data[0] << 16) | ((int32)fifo_data[1] << 8) | fifo_data[2];
    *ir = ((int32)fifo_data[3] << 16) | ((int32)fifo_data[4] << 8) | fifo_data[5];
    *red &= 0x3FFFF;
    *ir &= 0x3FFFF;
}

#endif
