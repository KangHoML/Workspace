/* Copyright 2019 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#if defined(ARDUINO) && !defined(ARDUINO_SFE_EDGE)
#define ARDUINO_EXCLUDE_CODE
#endif  // defined(ARDUINO) && !defined(ARDUINO_SFE_EDGE)

#ifndef ARDUINO_EXCLUDE_CODE

#include "detection_responder.h"

#include "am_bsp.h"

// This implementation will light up LEDs on the board in response to the
// inference results.
void RespondToDetection(tflite::ErrorReporter* error_reporter,
                        int8_t plastic_score, int8_t no_plastic_score) {
  static bool is_initialized = false;
  if (!is_initialized) {
    // Setup LED's as outputs.  Leave red LED alone since that's an error
    // indicator for sparkfun_edge in image_provider.
    am_devices_led_init((am_bsp_psLEDs + AM_BSP_LED_BLUE));
    am_devices_led_init((am_bsp_psLEDs + AM_BSP_LED_GREEN));
    am_devices_led_init((am_bsp_psLEDs + AM_BSP_LED_YELLOW));
    is_initialized = true;
  }

  // Toggle the blue LED every time an inference is performed.
  am_devices_led_toggle(am_bsp_psLEDs, AM_BSP_LED_BLUE);

  // Turn on the green LED if a person was detected.  Turn on the yellow LED
  // otherwise.
  am_devices_led_off(am_bsp_psLEDs, AM_BSP_LED_YELLOW);
  am_devices_led_off(am_bsp_psLEDs, AM_BSP_LED_GREEN);
  if (plastic_score > no_plastic_score) {
    am_devices_led_on(am_bsp_psLEDs, AM_BSP_LED_GREEN);
  } else {
    am_devices_led_on(am_bsp_psLEDs, AM_BSP_LED_YELLOW);
  }

  TF_LITE_REPORT_ERROR(error_reporter, "Plastic score: %d No plastic score: %d",
                       plastic_score, no_plastic_score);
}

#endif  // ARDUINO_EXCLUDE_CODE
