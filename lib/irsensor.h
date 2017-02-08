#ifndef IRSENSOR_H
#define IRSENSOR_H

#include <avr/io.h>
#include <stdbool.h>
#include <inttypes.h>

typedef void (*sensor_handler_t) (uint16_t value);

typedef struct {
    sensor_handler_t handler;
    volatile uint8_t *ddr;
    volatile uint8_t *pin;
    volatile uint8_t *port; 
    volatile uint8_t iopin;
} irsensor_t;

// prototypes
void irsensor_sensor_init(const irsensor_t *sensor);
void irsensor_init(void);
void irsensor_enable(void);
void irsensor_disable(void);


#endif
