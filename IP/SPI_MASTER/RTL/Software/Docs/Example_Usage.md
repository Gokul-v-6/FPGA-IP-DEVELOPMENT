# SPI Master IP (Mode-0) – Example Usage, Validation & Notes

This document describes the SPI Master IP software programming model, provides ready-to-run example code using the VSDSquadron `io.h` interface, and lists validation steps, expected output, and known limitations.

---

## Software Programming Model

This SPI Master IP is controlled through **memory-mapped registers** using the VSDSquadron `io.h` interface.  
Software interacts with the IP using the provided read/write macros (`SPI_IN`, `SPI_OUT`) and does not require RTL inspection.

---

### Register Access Interface (io.h)

The SPI IP is mapped at the base address defined in `io.h`:

```c
#define SPI_BASE 0x401000
```
SPI register offsets:
```c
#define SPI_CTRL 0x00
#define SPI_TXDATA 0x04
#define SPI_RXDATA 0x08
#define SPI_STATUS 0x0C
```
Register access macros from io.h:
```c
#define SPI_IN(offset)         (*(volatile uint32_t*)(SPI_BASE + (offset)))
#define SPI_OUT(offset,val)    (*(volatile uint32_t*)(SPI_BASE + (offset)) = (val))
```
### 5.2 How Software Controls the IP

Software controls the SPI Master IP by writing and reading **memory-mapped registers** using the `io.h` macros:

- `SPI_OUT(offset, value)` → write a register  
- `SPI_IN(offset)` → read a register  

A single 8-bit SPI transaction is performed through the following register-level sequence:

#### Step-by-step Control Flow

1. **Enable SPI and configure SPI clock**
   - Set `CTRL.EN = 1` to enable the IP
   - Set `CTRL.CLKDIV` to define the SPI clock rate

   ```c
   SPI_OUT(SPI_CTRL, (1 << 0) | (clkdiv << 8));
   ```

2. **Clear DONE flag**
   - Clears any stale completion flag using W1C (Write-1-to-Clear)
   ```c
   SPI_OUT(SPI_STATUS, (1 << 1));
   ```

3. **Write transmit byte**
   - Write the 8-bit TX data into TXDATA register
   ```c
   SPI_OUT(SPI_TXDATA, tx_byte);
   ```

4. **Start the SPI transfer**
   - Set `CTRL.START = 1` while keeping EN and CLKDIV unchanged
    ```c
     SPI_OUT(SPI_CTRL, (1 << 0) | (clkdiv << 8) | (1 << 1));
     ```

5. **Poll STATUS until transfer completes**
    - Wait for STATUS.DONE = 1
  ```c
  while (!(SPI_IN(SPI_STATUS) & (1 << 1)));
  ```

6. **Read received byte**
    - Read RX byte from RXDATA register (lower 8 bits)
    ```c
    uint8_t rx_byte = (uint8_t)(SPI_IN(SPI_RXDATA) & 0xFF);
    ```
   
7. **Clear DONE flag**
    - Prepare IP for the next transfer
   ```c
   SPI_OUT(SPI_STATUS, (1 << 1));
   ```

### Typical Initialization Sequence
Recommended initialization sequence:
1. Configure divider + enable SPI:
   ```c
   SPI_OUT(SPI_CTRL, (1<<0) | (clkdiv<<8));
   ```

2. Clear stale completion flag:
   ```c
   SPI_OUT(SPI_STATUS, (1<<1));    // DONE clear (W1C)
   ```

---
### Polling vs Status Checking
This SPI Master IP uses a **polling-based control model** (no interrupts).  
Software must repeatedly check the STATUS register to determine when a transfer is complete.
---

#### Polling Method (Recommended)

After starting a transfer, software checks the STATUS flags:

- **BUSY (STATUS[0])**
  - `1` → transfer in progress
  - `0` → SPI idle

- **DONE (STATUS[1])**
  - `1` → transfer completed, RXDATA valid
  - Cleared by software using **W1C (Write-1-to-Clear)**

---

#### Example: Polling DONE

```c
// Start transfer
SPI_OUT(SPI_CTRL, (1 << 0) | (clkdiv << 8) | (1 << 1));

// Wait until DONE becomes 1
while (!(SPI_IN(SPI_STATUS) & (1 << 1)));
```

---
## Example Software
Below is a simple C Progam to Test the IP.
<details><summary>SPI_MASTER(Click To Expand)</summary>

```c
#include <stdint.h>
#include "io.h"

// UART print (unchanged)
void print_uart(const char *str) {
    while (*str) {
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, *str++);
    }
}

// Simple delay
void delay(int cycles) {
    volatile int i;
    for (i = 0; i < cycles; i++);
}

// Fast hex print (1 byte)
static inline void uart_hex8(uint8_t v) {
    const char lut[] = "0123456789ABCDEF";
    while (IO_IN(UART_CNTL));
    IO_OUT(UART_DATA, lut[(v >> 4) & 0xF]);
    while (IO_IN(UART_CNTL));
    IO_OUT(UART_DATA, lut[v & 0xF]);
}

void main() {
//can be commentedd out while simulation for faster simulation
    print_uart("\n--- SPI MASTER IP TEST ---\n");

    // Enable SPI, CLKDIV = 4
    SPI_OUT(SPI_CTRL, (1 << 0) | (4 << 8));

    while (1) {

        // Clear DONE
        SPI_OUT(SPI_STATUS, (1 << 1));

        // TX = 0xA5
        SPI_OUT(SPI_TXDATA, 0xA5);

        // Start transfer
        SPI_OUT(SPI_CTRL, (255<<8)|(1 << 0) | (1 << 1));

        // Wait for DONE
        while (!(SPI_IN(SPI_STATUS) & (1 << 1)));

        // Read RX
        uint8_t rx = SPI_IN(SPI_RXDATA);

        // Print: A5->XX
        uart_hex8(0xA5);
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, '-');
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, '>');
        uart_hex8(rx);
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, '\n');

        delay(200000);   // reduced delay
    }
}
  
```

</details>

Include address mapping file
<details>
  <summary>IO.h</summary>

  ```c
  #include <stdint.h>

#define IO_BASE       0x400000

// GPIO Registers 
#define GPIO_DATA  0x04
#define GPIO_DIR   0x24
#define GPIO_READ  0x44

// UART Registers 
#define UART_DATA  0x08
#define UART_CNTL  0x10

// Access Macros
#define IO_IN(offset)     (*(volatile uint32_t*)(IO_BASE + (offset)))
#define IO_OUT(offset,val) (*(volatile uint32_t*)(IO_BASE + (offset)) = (val))

//spi registers
#define SPI_BASE    0x401000
#define SPI_CTRL 0x00
#define SPI_TXDATA 0x04
#define SPI_RXDATA 0x08
#define SPI_STATUS 0x0C

#define SPI_IN(offset)     (*(volatile uint32_t*)(SPI_BASE + (offset)))
#define SPI_OUT(offset,val) (*(volatile uint32_t*)(SPI_BASE + (offset)) = (val))
  ```
</details>

---
## Validation and Expected Output
## Expected Output
If the PIN Connections are made according to installation guide. The user should observe the output

- `cs_n` asserts **LOW** at the beginning of every transfer  
- `sclk` toggles for **8 clock pulses** per transaction (SPI Mode-0). It will a frequency of 23.5 KHz since system clock frequency is 12 MHz
- `mosi` transmits the byte `0xA5` (MSB first)
- `miso` is sampled to form RXDATA
- `cs_n` deasserts **HIGH** after transfer completion
- The above program keeps running in a loop.

Demo:

https://github.com/user-attachments/assets/76d0f0ca-df4a-4956-872e-497101cf76c7


#### LED POSITION
From Left
  - 1 - cs_n
  - 2 - mosi
  - 3 - sclk
SCLK Frequency - 23.5 KHz

MOSI - 0xA5

We can observe cs_n going high when reset pressed

## Expected UART Output
The Uart should print. 
--- SPI MASTER IP TEST (MODE-0) ---

A5->XX

A5->XX

A5->XX

Getting the above output in terminal indicates that transfer is done ,i.e, `done` register is asserted.

---
## Common Failure Symptoms
### Common Failure Symptoms

| Symptom | Likely Cause | Recommended Fix |
|--------|--------------|-----------------|
| No UART output | UART wiring/baud mismatch | Check UART TX pin mapping + baud rate |
| `sclk` not toggling | SPI not enabled | Ensure `CTRL.EN = 1` |
| `cs_n` never goes LOW | SPI select / address decode issue | Verify SPI_BASE = `0x401000` and `sel = isIO & mem_addr[12]` |
| DONE never sets | clock/reset issue | Confirm system clock running and reset released |
| RX always `0x00` / `0xFF` | MISO floating/unwired | Connect MISO properly and ensure common GND |
| Wrong RX values | Mode mismatch | Ensure slave is configured for SPI Mode-0 |
| Corrupted transfers | SPI clock too fast | Increase CLKDIV value |

---

## Known Limitations & Notes

Commercial limitations and design notes for this SPI IP:

- **No interrupt support** (polling-only operation)
- **Single-channel SPI master** (one slave select `cs_n`)
- **SPI Mode-0 only** (CPOL=0, CPHA=0)
- **Single-byte transfer per START**
  - Each transaction transfers exactly 8 bits
- **No FIFO buffering**
  - TXDATA and RXDATA store one byte only
- **Clock assumption**
  - SPI timing depends on system clock (`clk`) from VSDSquadron SoC
  - SPI clock = function of `CLKDIV` and system clock frequency
- **Board requirement**
  - External SPI peripheral must share a common ground with VSDSquadron FPGA

---
## GPIO IP Testing
Below is the C program to test GPIO IP. 
<details><summary>GPIO_IP.c</summary>
   
```c
#include <stdint.h>
#include "io.h"

// UART print
void print_uart(const char *str) {
    while (*str) {
        while (IO_IN(UART_CNTL));
        IO_OUT(UART_DATA, *str++);
    }
}

// Delay
void delay(int cycles) {
    volatile int i;
    for (i = 0; i < cycles; i++);
}

int main() {

    print_uart("\n--- GPIO LED COUNT TEST ---\n");

    // Set GPIO[3:0] as output (4 LEDs)
    // If your LED width is 5, you can set 0x1F
    IO_OUT(GPIO_DIR, 0x1F);

    while (1) {
        for (uint32_t count = 1; count <= 15; count++) {

            // Output count on LEDs (lower 4 bits)
            IO_OUT(GPIO_DATA, count & 0x0F);

            delay(300000);
        }
    }
}
```

</details>
This programs counts from 0 to 15 then resets back to 0. Direction of all pins are choosen to be output for verification. Then can be used as digital inputs pins also by manipulating direction register.

### Gpio Pin connection
| PIN  | FUNCTION |
| --- | --- |
| 38 | Digital GPIO 0 |
| 43 | Digital GPIO 1 |
| 45 | Digital GPIO 2 |
| 47 | Digital GPIO 3 |
| 6 | Digital GPIO 4 |
