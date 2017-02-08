#include <stdio.h>
#include <avr/interrupt.h>

#include "irsensor.h"

#define MAX_ADC_PINS    8u
#define MAX_DIG_PINS    8u

static const irsensor_t *analog_sensor_list[MAX_ADC_PINS];
static uint8_t analog_list_size = 0;

static irsensor_t *digital_sensor_list[MAX_DIG_PINS];

ISR(TIMER0_COMPA_vect) {
    uint8_t i = 0;
    for(i = 0; i < analog_list_size; i++) {
        const irsensor_t *sensor = analog_sensor_list[i];
        // clear mux and set first adc pin mux 
        ADMUX &= 0xF0; 
        ADMUX |= sensor->iopin;
        // start single-conversion
        ADCSRA |= _BV(ADSC);
        // wait for the conversion to be completed 
        while(!(ADCSRA & _BV(ADIF)));

        sensor->handler(ADC);
    }
}

ISR(PCINT0_vect) {
}

ISR(PCINT1_vect) {
}

ISR(PCINT2_vect) {
}

void irsensor_init(void) {
    // AVCC reference
    ADMUX |= _BV(REFS0);
    // enable adc and set presc to 128
    ADCSRA |= _BV(ADEN) | 0x07;
    // CTC-mode
    TCCR0A = _BV(WGM01);
    // enable output compare a int 
    TIMSK0 |= _BV(OCIE0A);
    // set output compare a value
    OCR0A = 250;
}

void irsensor_sensor_init(const irsensor_t *sensor) {
    // analog or digital sensor?
    if(!sensor->ddr) {
        cli();
        analog_sensor_list[analog_list_size] = sensor;
        analog_list_size++;
        sei();
    } 
}

void irsensor_enable(void) {
    // 64/16 = 4us * 250ocra = 1ms, enable clock
    TCCR0B |= _BV(CS01) | _BV(CS00);
}
void irsensor_disable(void) {
    // 64/16 = 4us * 250ocra = 1ms, enable clock
    TCCR0B &= ~(_BV(CS01) | _BV(CS00));
}

