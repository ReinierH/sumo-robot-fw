#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdio.h>
#include <string.h>

#include "lib/irsensor.h"
#include "lib/avr_printf.h"

#ifdef DEBUG
static FILE mystdout = FDEV_SETUP_STREAM(usart_putchar_printf, NULL, _FDEV_SETUP_WRITE);
#define PRINTF printf
#endif


/* function prototypes */
void irsensor_left_handler(uint16_t value);
void irsensor_right_handler(uint16_t value);
void irsensor_front_handler(uint16_t value);

/* sensor instances  */

const irsensor_t irsensor_left = { 
    &irsensor_left_handler,
    NULL,
    NULL,
    NULL,
    2 
};

const irsensor_t irsensor_right = { 
    &irsensor_right_handler,
    NULL,
    NULL,
    NULL,
    0 
};

const irsensor_t irsensor_front = { 
    &irsensor_front_handler,
    NULL,
    NULL,
    NULL,
    1 
};

/* -------------- */

/* functions */
void irsensor_left_handler(uint16_t value) {
   //printf("left value: %d \n", value);
}

void irsensor_right_handler(uint16_t value) {
    printf("right value: %d \n", value);
}

void irsensor_front_handler(uint16_t value) {
    //printf("front value: %d \n", value);
}

/* -------------- */

enum { WAIT_FOR_SIG, FINDING_TARGET, ATTACK_TARGET } robot_state;

int main(void) {
    stdout = &mystdout;
    irsensor_init();

    irsensor_sensor_init(&irsensor_left);
    irsensor_sensor_init(&irsensor_right);
    irsensor_sensor_init(&irsensor_front);

    irsensor_enable();

    while(1) {
        uint8_t data[16];
        size_t size = 0;
/* robot state machine */
        switch (robot_state) {
            case (WAIT_FOR_SIG) : 
                //PRINTF("STATE - waiting for sig\n");
                /* if(irreceiver_get_data(data, size) > 0) { */
                /*     // parse data */
                    
                /*     robot_state = FINDING_TARGET; */
                /* } */
            break;

            case (FINDING_TARGET) :
            break;

            default:
            break;
        }
    }


    return 0;
}
