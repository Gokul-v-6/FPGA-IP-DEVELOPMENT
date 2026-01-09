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
---
## Integration Steps
1. Copy RTL from `rtl/SPI_MASTER.v` into your SoC RTL tree.
2. Instantiate the SPI module in `SOC module` in  `riscv.v` RTL.
3. SPI is selected when IO space is accessed and `mem_addr[12]==1`.
4. Connect SPI pins: `sclk`, `mosi`, `miso`, `cs_n`
---
## Documentation Location

All IP documentation is provided in the `docs/` folder.  

- [IP_User_Guide](docs/IP_User_Guide.md) - Describes what the IP does, supported SPI mode (Mode-0), features, clock/reset assumptions, and limitations.

- [Register_Map](docs/Register_Map.md) - Complete register table with offsets, bit fields, reset values, and read/write behavior.  This is the primary reference for writing firmware drivers.

- [Integration_Guide](docs/Integration_Guide.md) - Step-by-step instructions to integrate the SPI IP into VSDSquadron SoC (`soc_top.v`), including address decode rules and board-level pin connections.

- [Example_Usage](docs/Example_Usage.md) - Explains the software programming model and provides example C code for initialization and byte transfers.
---
## Test & Validation
1. Program FPGA with SoC + SPI IP integrated
2. Build and run `IP/SPI_MASTER/Firmware/SPI_MASTER.c`
3. Observe SPI activity:
   - `cs_n` asserted low during transfer
   - `sclk` toggles in Mode-0 timing
   - RX byte appears in RXDATA after DONE
