# Designing And Integrating Memory Mapped IP
## Task Overview
This floder implements the Simple GPIO Output IP as a memory-mapped peripheral and integrates it into the existing RISC-V SoC.
- The GPIO IP Funcionality
  - One 32-bit register
  - Writing to the register updates an output signal
  - Reading the register returns the last written value
  - Uses the same bus signals already present in the SoC
---
## Address Mapping
| Component | Base Address | Offset | Description |
|----------|--------------|--------|-------------|
| GPIO IP  | `0x00400020` | `0x00` | GPIO Output Register |
---
## GPIO RTL
- File - [gpio_ip.v](sources/gpio_ip.v)
- Features
  - 32-bit gpio register 
  - Synchronous write using clock
  - Readback logic returning last written value
---

## SoC Integration
- The GPIO module is instantiated in [SoC](sources/riscv.v)
<img width="632" height="175" alt="Screenshot 2025-12-23 103438" src="https://github.com/user-attachments/assets/1b394e75-5e1d-406b-bc86-778b73f274fb" />
<img width="839" height="495" alt="Screenshot 2025-12-23 103357" src="https://github.com/user-attachments/assets/8e162ebe-8edc-498e-ad92-a2e7ea89e18f" />

The above images show the instantiated module in SoC

---
## Simulation
### [GPIO ]





 
