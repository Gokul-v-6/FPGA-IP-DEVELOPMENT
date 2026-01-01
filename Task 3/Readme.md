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
- File - [Gpio_ip.v](srcs/gpio_ip.v)
- Features
  - 32-bit gpio data register
  - Directional control => 1 - output, 0 - input.
  - Read Register - Reads data if pin is output, input value is pin is input. 
  - Synchronous write using clock
- Signal description
  
| Signal |  |
|----------|--------------|
| `clk`  | System clock(40Mhz) | 
| `rst`  | reset |
| `sel`  | is IO & mem_wordaddr[IO_gpio_bit], check if accessed mem address is Gpio_ip  | 
| `wdata`  | write data |
| `rdata`  | read data |
| `read_en`  | read enable |
| `write_en`  | write enable |
| `offset`  | mem_wordaddr[4:3] |
| `gpio_pins`  | Wired to external Gpio_pins |

---

## SoC Integration
- The GPIO module is instantiated in [SoC](srcs/riscv.v)
 <img width="420" height="188" alt="image" src="https://github.com/user-attachments/assets/6f7166de-e4e5-4a0b-99f8-d2792473cc05" />
 <img width="707" height="295" alt="Screenshot 2026-01-01 201705" src="https://github.com/user-attachments/assets/57d1f38a-7796-4df0-9ecd-baf146b5e448" />
 
The above images show the instantiated module in SoC

- Changes from Task 2
  - LEDS is made from output reg to inout for Bidirectional flow.
  - Direction register added in Gpio_ip and mapped to a memory address. 
  - Readback logic.

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
  





 

