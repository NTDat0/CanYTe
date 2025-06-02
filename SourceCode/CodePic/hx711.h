#ifndef HX711_H
#define HX711_H

#include <math.h> // Bao g?m thu vi?n math.h d? s? d?ng hàm fabs()

// HX711 Pin Definitions
#define HX711_DT_PIN PIN_A0
#define HX711_SCK_PIN PIN_A1

// Global variables for offset and scale
long OFFSET = 0;
double SCALE = 1.0; // Ð?t SCALE v? 1.0. Giá tr? này s? du?c tính toán l?i b?i hx711_calibrate()

// Ngu?ng nhi?u cho giá tr? RAW
#define HX711_RAW_NOISE_THRESHOLD 100

// Ngu?ng tr?ng lu?ng t?i da cho phép khi cân ? tr?ng thái không t?i
#define HX711_ABSOLUTE_ZERO_THRESHOLD 10.0f

// Ngu?ng giá tr? d? xác d?nh cân dã "g?n" 0g
#define HX711_NEAR_ZERO_THRESHOLD 10.0f

// S? lu?ng l?n d?c liên ti?p c?n thi?t d? xác nh?n tr?ng thái "0g ?n d?nh"
#define HX711_STABLE_ZERO_COUNT 30

// Ngu?ng d? thoát kh?i tr?ng thái 0g và b?t d?u do tr?ng lu?ng th?c t?.
#define HX711_OBJECT_DETECTION_THRESHOLD 20.0f

// Bi?n tr?ng thái c?a HX711
typedef enum {
    HX711_STATE_UNKNOWN,
    HX711_STATE_ZEROED,
    HX711_STATE_MEASURING,
    HX711_STATE_SETTLING_TO_ZERO
} hx711_status_t;

static hx711_status_t hx711_current_state = HX711_STATE_UNKNOWN;
static int8 zero_stability_counter = 0;

// Hàm d?c d? li?u thô t? HX711
unsigned int32 readCount(void) {
   unsigned int32 data = 0;
   unsigned int8 j;

   output_bit(HX711_SCK_PIN, 0);

   unsigned int16 timeout = 0;
   while (input(HX711_DT_PIN)) {
       delay_us(1);
       timeout++;
       if (timeout > 5000) return 0;
   }

   for (j = 0; j < 24; j++) {
      output_bit(HX711_SCK_PIN, 1);
      delay_us(1);
      data = data << 1;
      output_bit(HX711_SCK_PIN, 0);
      delay_us(1);
      if (input(HX711_DT_PIN)) {
         data++;
      }
   }

   output_bit(HX711_SCK_PIN, 1);
   delay_us(1);
   data = data ^ 0x800000;
   output_bit(HX711_SCK_PIN, 0);
   delay_us(1);

   return data;
}

// Hàm d?c giá tr? trung bình thô
int32 readAverage(void) {
   unsigned int32 sum = 0;
   int8 k;
   int8 valid_reads = 0;

   for (k = 0; k < 30; k++) {
      unsigned int32 current_read = readCount();
      if (current_read != 0) {
          sum += current_read;
          valid_reads++;
      }
      delay_us(50);
   }
   if (valid_reads > 0) {
       return sum / valid_reads;
   } else {
       return 0;
   }
}

// Hàm l?y giá tr? (thô - offset)
long hx711_get_value(int8 times) {
   long raw_value = readAverage();
   long delta = raw_value - OFFSET;

   // L?c nhi?u RAW r?t nh? (this block was empty, can be removed or used if needed)
   // if (delta < HX711_RAW_NOISE_THRESHOLD && delta > -HX711_RAW_NOISE_THRESHOLD) {
   // }
   return delta;
}

// Hàm chính d? l?y tr?ng lu?ng tính b?ng gram
float hx711_get_units(int8 times) {
   float weight_after_scale;
   float raw_value_after_offset = (float)hx711_get_value(times); // Get raw value minus offset

   if (SCALE == 0) { // Prevent division by zero if SCALE is not yet calibrated
       // If not calibrated, unsure what state to be in. Default to unknown or error.
       hx711_current_state = HX711_STATE_UNKNOWN;
       return 0.0f;
   }
   weight_after_scale = raw_value_after_offset / SCALE; // Initial scaling

   // --- Non-linearity Correction ---
   // This correction assumes calibration was done with a specific weight (e.g., 31.0g).
   // The factor is derived from your experimental data (e.g., 133g read as 116g -> 133/116 approx 1.146).
   // IMPORTANT: CALIBRATION_POINT_WEIGHT here MUST match KNOWN_WEIGHT_FOR_CALIBRATION in main.c
   const float CALIBRATION_POINT_WEIGHT = 31.0f;
   const float CORRECTION_FACTOR = 1.144f; // Tune this factor if needed based on more tests

   float corrected_weight = weight_after_scale; // Start with the initially scaled weight

   // Apply correction only if the initially scaled weight is discernibly above the calibration point.
   // The +0.5f is a small margin to avoid incorrectly adjusting weights very close to the
   // calibration point due to noise or minor fluctuations.
   if (weight_after_scale > (CALIBRATION_POINT_WEIGHT + 0.5f)) {
       corrected_weight = weight_after_scale * CORRECTION_FACTOR;
   }
   // --- End Non-linearity Correction ---

   // Handle negative values:
   // 1. If the weight is a small negative fluctuation around zero, clamp it to 0.
   // 2. If the weight is significantly negative (beyond NEAR_ZERO_THRESHOLD), also clamp to 0.
   //    This assumes the scale is not intended to display large negative weights.
   if (corrected_weight < 0) {
       if (fabs(corrected_weight) < HX711_NEAR_ZERO_THRESHOLD) {
           corrected_weight = 0.0f; // Small negative fluctuation
       } else {
           corrected_weight = 0.0f; // Larger negative value, also clamp to 0
       }
   }

   // State machine logic using 'corrected_weight' for decisions
   switch (hx711_current_state) {
       case HX711_STATE_UNKNOWN:
           zero_stability_counter = 0;
           hx711_current_state = HX711_STATE_SETTLING_TO_ZERO;
           return 0.0f; // Return 0 immediately on first unknown state

       case HX711_STATE_ZEROED: // Scale is considered stable at 0g
           // If a significant weight is detected, switch to measuring
           if (fabs(corrected_weight) >= HX711_OBJECT_DETECTION_THRESHOLD) {
               hx711_current_state = HX711_STATE_MEASURING;
               zero_stability_counter = 0; // Reset stability counter
               return corrected_weight;
           } else {
               return 0.0f; // Stay zeroed, display 0
           }

       case HX711_STATE_MEASURING: // Scale is actively measuring
           // If the weight drops near zero, start settling towards a stable zero
           if (fabs(corrected_weight) < HX711_NEAR_ZERO_THRESHOLD) {
               zero_stability_counter = 0; // Reset/start settling counter
               hx711_current_state = HX711_STATE_SETTLING_TO_ZERO;
               // Display the small current weight as it settles down
               return corrected_weight;
           } else {
               // Still measuring a significant weight
               return corrected_weight;
           }

       case HX711_STATE_SETTLING_TO_ZERO: // Scale is trying to stabilize at 0g
           // If weight remains near zero
           if (fabs(corrected_weight) < HX711_NEAR_ZERO_THRESHOLD) {
               zero_stability_counter++;
               // If stable near zero for long enough, perform an auto-tare and lock to zero
               if (zero_stability_counter >= HX711_STABLE_ZERO_COUNT) {
                   OFFSET = readAverage(); // Auto-tare by updating offset
                   hx711_current_state = HX711_STATE_ZEROED;
                   zero_stability_counter = 0; // Reset counter
                   return 0.0f; // Confirmed zero
               } else {
                   // Still settling, display 0 to avoid flickering small values
                   return 0.0f;
               }
           }
           // If a significant object is placed *during* settling, switch back to measuring
           else if (fabs(corrected_weight) >= HX711_OBJECT_DETECTION_THRESHOLD) {
               hx711_current_state = HX711_STATE_MEASURING;
               zero_stability_counter = 0; // Reset counter
               return corrected_weight;
           }
           // If weight fluctuated out of near-zero but isn't a new object (e.g., minor drift/disturbance)
           else {
               zero_stability_counter = 0; // Reset settling counter as it's not stable near zero
               hx711_current_state = HX711_STATE_MEASURING; // Go back to measuring mode
               return corrected_weight; // Display the current reading
           }

       default: // Should not happen
           hx711_current_state = HX711_STATE_UNKNOWN;
           return 0.0f;
   }
}

// Hàm tare (d?t tr?ng lu?ng hi?n t?i v? 0)
void hx711_tare(int8 times) {
   OFFSET = readAverage();
   hx711_current_state = HX711_STATE_ZEROED; // Set state to zeroed and locked
   zero_stability_counter = 0; // Reset stability counter
}

// Hàm d?t h? s? scale th? công
void hx711_set_scale(double scale) {
   SCALE = scale;
}

// Hàm hi?u chu?n HX711 v?i tr?ng lu?ng dã bi?t
void hx711_calibrate(float known_weight) {
   if (known_weight <= 0) return; // Cannot calibrate with zero or negative weight

   // OFFSET should have been set by a previous call to hx711_tare() with an empty scale
   long raw_value_with_weight = readAverage();
   long delta_raw = raw_value_with_weight - OFFSET; // Raw reading corresponding to known_weight

   if (delta_raw != 0) { // Avoid division by zero
      SCALE = (double)delta_raw / known_weight;
   } else {
      // Error: delta_raw is zero, cannot calculate scale.
      // Maybe the known_weight is too small or OFFSET is wrong.
      // SCALE remains unchanged or could be set to an error indicator if needed.
   }
   // After calibration, the scale might not be in ZEROED state if weight is still on.
   // The next call to hx711_get_units() will determine the state.
   // Or, we could force it to MEASURING if known_weight > 0
   if (known_weight > 0 && delta_raw != 0) {
       hx711_current_state = HX711_STATE_MEASURING; // Assume still measuring the calibration weight
   }
}

#endif // HX711_H
