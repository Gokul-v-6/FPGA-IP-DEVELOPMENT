# Designing And Integrating Memory Mapped IP
## Task Overview
This folder implements the Simple GPIO bidirectional IP as a memory-mapped peripheral and integrates it into the existing RISC-V SoC.
- The GPIO IP Funcionality
  - One 32-bit register
  - Writing to the register updates an output signal
  - Reading the register returns the last written value
  - Uses the same bus signals already present in the SoC
---
## Address Mapping
| Component | Base Address | Offset | Description |
|----------|--------------|--------|-------------|
| GPIO IP  | `0x00400000` | `0x04` | GPIO data Register |
| GPIO IP  | `0x00400000` | `0x24` | GPIO direction Register |
| GPIO IP  | `0x00400000` | `0x44` | GPIO read Register |

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
### [GPIO](sim/gpio_ip_sim.v)
<img width="1352" height="323" alt="Screenshot 2025-12-23 113612" src="https://github.com/user-attachments/assets/00284e29-3629-4cda-b706-a28dd4d9731a" />

The above simulation shows data being successfully written into GPIO register when data is written to `0x004000020` address.

### SOC
- Assembly File - [gpio_test](gpio_test.S)
- The above file is converted to hex file and simulated using [SoC test bench](sim/tb_soc.v).
<img width="1308" height="303" alt="Screenshot 2025-12-23 131307" src="https://github.com/user-attachments/assets/f45f1223-cfb9-433b-ba3a-b0909db174db" />

The above image shows successful write operation to GPIO register which writes into LEDs register that is mapped to LEDS present on FPGA board. 

---

## Hardware Implementation
Environment Setup - Followed [Datasheet](datasheet.pdf) to setup local environment for flashing fpga
<img width="1338" height="1011" alt="Screenshot 2025-12-23 222615" src="https://github.com/user-attachments/assets/3d274cd0-d391-4b3e-b720-e9d2decaf627" />

![IMG20251223223513](https://github.com/user-attachments/assets/440c95c7-8655-4c60-8f19-be1aef1262bb)
---
## Key Learning
- Understood how SoC communicates with peripherals using address mapped IO.
- Adress Decoding and peripheral integration.
- Tool usage and flow control.
  





 

