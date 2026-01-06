# SPI MASTER IP - MODE 0
---
## 1. Introduction
This project implements a minimal SPI Master IP supporting 8-bit transfers in SPI Mode 0.
The SPI IP is memory-mapped and integrated into a simple RV32-based SoC along with GPIO
and UART peripherals.

The design focuses on clarity, correctness, and end-to-end validation from software
to hardware.

---
## 2. SPI Basics

SPI (Serial Peripheral Interface) is a synchronous serial communication protocol
commonly used to connect microcontrollers with peripherals such as sensors,
ADCs, DACs, and flash memory.

SPI uses four main signals:
- SCLK  : Serial Clock (driven by master)
- MOSI  : Master Out, Slave In
- MISO  : Master In, Slave Out
- CS_N  : Chip Select (active low)
<img width="1071" height="323" alt="image" src="https://github.com/user-attachments/assets/f004b708-a06c-4cac-ad85-15d8bd13f70d" />


SPI is a full-duplex protocol where data is shifted serially, one bit per clock cycle.

---
## 3. SPI Mode 0 Operation

SPI Mode 0 is defined by:
- CPOL = 0 → Clock idle state is LOW
- CPHA = 0 → Data is sampled on the rising edge of SCLK
  
<img width="1098" height="641" alt="image" src="https://github.com/user-attachments/assets/66a1b59c-a2c9-463c-b361-1df1cdb84500" />

In Mode 0:
- MOSI is driven on the falling edge of SCLK
- MISO is sampled on the rising edge of SCLK
- CS_N is asserted low at the start of the transfer and deasserted high at the end

The transfer length in this design is fixed at 8 bits.

---
## 4. RTL

---

## 5. Register Map

Base Address: 0x00401000

| Offset | Register | Description |
|------|--------|-------------|
| 0x00 | CTRL   | Enable, Start, Clock Divider |
| 0x04 | TXDATA | Transmit data (8-bit) |
| 0x08 | RXDATA | Received data (8-bit) |
| 0x0C | STATUS | BUSY, DONE flags |

CTRL Register:
- Bit 0 : EN (Enable SPI)
- Bit 1 : START (Start transfer)
- Bits [15:8] : CLKDIV (Clock divider)

STATUS Register:
- Bit 0 : BUSY
- Bit 1 : DONE (Write 1 to clear)

---
## 7. Address Decoding

Each peripheral in the SoC is allocated a dedicated 4 KB address window.

SPI Base Address:
0x00401000 – 0x00401FFF

Address decoding is performed using bits [31:12] of the address bus.
Internal register selection is done using address bits [3:2].


