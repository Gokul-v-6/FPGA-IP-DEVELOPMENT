# SPI Master IP (Mode-0) – IP User Guide

## 1. IP Overview

The SPI Master IP (Mode-0) is a memory-mapped peripheral designed for the VSDSquadron RISC-V SoC.
It enables communication with external SPI-compatible devices using SPI Mode-0 timing.

### Typical Use Cases
- SPI sensors (IMU, temperature, ADC)
- SPI Flash memory
- DAC / ADC devices
- Expansion header peripherals

### Why Use This IP
- Provides deterministic SPI timing in hardware
- Reduces software complexity compared to bit-banging
- Simple register-based control model
- Plug-and-play integration with VSDSquadron SoC
---

## 2. Feature Summary

- SPI Master operation
- SPI Mode-0 (CPOL=0, CPHA=0)
- 8-bit full-duplex transfer
- Single slave select
- Programmable clock divider
- Polling-based status control

### Clock Assumptions
- Uses system clock `clk`
- SPI clock derived from programmable divider

### Limitations
- Only Mode-0 supported
- Single SPI slave
- No interrupts
- No FIFO support
---
---

## 3. Block Diagram

The following block diagram shows the logical structure of the SPI Master IP and its interaction with the RISC-V CPU and external SPI device.
<img width="251" height="661" alt="Untitled Diagram drawio (5)" src="https://github.com/user-attachments/assets/f8d3d64e-ef6d-43e8-b7c5-0e0e28ef033e" />


### Block Description
- **Register Decode**  
  Decodes memory-mapped accesses from the CPU and selects SPI registers.
- **Control Registers**  
  Hold enable, start, clock divider, and transmit data.
- **SPI Control FSM**  
  Generates SPI clock, controls chip-select, shifts data, and captures received bits.
- **SPI Signals**  
  Standard SPI Master signals connected to an external peripheral.

## Hardware Usage



