#ifndef TERM_US
#define TERM_US
#include <Arduino.h>
extern uint8_t us_trig;
extern uint8_t us_echo;

static unsigned int newPulseIn(const byte pin, const byte state);
void us_start(uint8_t TRIG, uint8_t ECHO);
float us_get_distance();

#endif
