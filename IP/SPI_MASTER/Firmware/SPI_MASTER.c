// --- Program to display multiples of a specified positive integer ---
#include <stdint.h>
#include "io.h"
#define NUM 3 // Specified integer

// Function to transmit message through UART
void print_uart(const char *str) {
    while (*str) {
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, *str++);
    }
}

// Simple delay function
void delay(int cycles) {
    volatile int i;
    for (i = 0; i < cycles; i++);
}

// Counter increment function
void inc(int* counter) {
    (*counter)++;
    if (*counter > 15) *counter = 0;
}
void main() {
//Uncomment these while flashing to fpga.
    //delay(500000)
    // print_uart("\n--- SPI MASTER IP TEST ---\n");    
    // print_uart("Mode-0 | 8-bit | Loopback Test\n");

    // Enable SPI, set CLKDIV = 4
    SPI_OUT(SPI_CTRL, (1 << 0) | (4 << 8));  // EN=1, CLKDIV=4

    while (1) {

        // Clear DONE (write-1-to-clear)
        SPI_OUT(SPI_STATUS, (1 << 1));

        // Load transmit data
        SPI_OUT(SPI_TXDATA, 0xA5);

        // Start transfer (EN must remain 1)
        SPI_OUT(SPI_CTRL, (1 << 0) | (1 << 1)); // EN + START

        // Poll DONE
        while (!(SPI_IN(SPI_STATUS) & (1 << 1)));

        // Read received data
        uint8_t rx = SPI_IN(SPI_RXDATA) & 0xFF;

  //Ucomment these while hardware implementaion.
        // Print result via UART
        // print_uart("TX: 0xA5  RX: 0x");
        // const char lut[] = "0123456789ABCDEF";
        // char hex[3];
        // hex[0] = lut[(rx >> 4) & 0xF];
        // hex[1] = lut[rx & 0xF];
        // hex[2] = '\0';
        // print_uart(hex);
        // print_uart("\n");

        delay(1000000);
    }
}
