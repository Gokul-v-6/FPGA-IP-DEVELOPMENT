# SPI Master IP (Mode-0) – VSDSquadron FPGA
---

## SPI IP Information
This IP is a memory-mapped SPI Master controller (Mode-0) for VSDSquadron RISC-V SoC.It enables software running on the RISC-V core to communicate with external SPI peripherals using CPOL = 0 and CPHA = 0 timing.The SPI Master IP (Mode-0) is a memory-mapped hardware controller designed for the VSDSquadron RISC-V SoC.
It allows firmware running on the RISC-V processor to communicate with external SPI peripherals using SPI Mode-0 timing (CPOL = 0, CPHA = 0).

The IP is fully software-controlled and does not require any RTL modification by the user.
- Key Capabilities

  - SPI Master operation (single master)
  - Mode-0 timing (CPOL=0, CPHA=0)
  - 8-bit full-duplex data transfer
  - Single chip-select output
  - Memory-mapped control and status
  - Polling-based software interface
