//This file contains c program of bidirectional check
//direction- 0101
//data- 1111
#include <stdint.h>

#define IO_BASE       0x400000

// GPIO Registers 
#define IO_GPIO_DATA  0x04
#define IO_GPIO_DIR   0x24
#define IO_GPIO_READ  0x44

// UART Registers 
#define IO_UART_DAT   0x08
#define IO_UART_CNTL  0x10

// Access Macros
#define IO_IN(offset)     (*(volatile uint32_t*)(IO_BASE + (offset)))
#define IO_OUT(offset,val) (*(volatile uint32_t*)(IO_BASE + (offset)) = (val))

void delay(int cycles) {
    volatile int i;
    for (i = 0; i < cycles; i++);
}

// Function to halt execution and signal an error on LEDs
void fatal_error(int error_code) {
    while (1) {
        if (error_code == 1) {
            // Error 1: Direction Config Failed
            // Blink LED 0 slowly
            IO_OUT(IO_GPIO_DATA, 0x1);
            delay(800000);
            IO_OUT(IO_GPIO_DATA, 0x0);
            delay(800000);
        } else {
            // Error 2: Data Write/Read Verification Failed
            // Blink ALL LEDs very fast
            IO_OUT(IO_GPIO_DATA, 0xF);
            delay(100000);
            IO_OUT(IO_GPIO_DATA, 0x0);
            delay(100000);
        }
    }
}

void main() {
    // Set all 4 bits to OUTPUT (1)
    IO_OUT(IO_GPIO_DIR, 0x5);
    while (1) {
        IO_OUT(IO_GPIO_DATA, 0xF); 

        // Read from Readback Register to verify
        uint32_t val_read = IO_IN(IO_GPIO_READ);

    }
}
