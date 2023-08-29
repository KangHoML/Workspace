#include "term_us.h"

uint8_t us_trig = -1;
uint8_t us_echo = -1;

#define WAIT_FOR_PIN_STATE(state) \
  while(digitalRead(pin) != (state)) { \
    if (micros() - timestamp > 1000000L) { \
      return 0; \
    } \
  }

static unsigned int newPulseIn(const byte pin, const byte state) {
  unsigned long timestamp = micros();
  WAIT_FOR_PIN_STATE(!state);
  WAIT_FOR_PIN_STATE(state);
  timestamp = micros();
  WAIT_FOR_PIN_STATE(!state);
  return micros() - timestamp;
}

void us_start(uint8_t TRIG, uint8_t ECHO) { 
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);
  us_trig = TRIG;
  us_echo = ECHO;
}

float us_get_distance() {
  digitalWrite(us_trig, LOW);
  delayMicroseconds(2);
  digitalWrite(us_trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(us_trig, LOW);
  unsigned long duration = newPulseIn(us_echo, HIGH);
  float distance = ((float)(340 * duration) / 10000) / 2;
  return distance;
}
