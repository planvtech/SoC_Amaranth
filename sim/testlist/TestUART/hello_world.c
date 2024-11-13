#include <stdint.h>
#include <stdio.h>
#include "uart.h"

int hello_world()
{
    uart_set_cfg(0, 27);
    uart_send("Hello World", 12);
    uart_wait_tx_done();
    return 0;
}