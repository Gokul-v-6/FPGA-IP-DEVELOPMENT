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
| UART_DATA | `0x00400000` | `0x08` | |
| UART_CONTROL| `0x00400000` | `0x10` | Stores busy bit |

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
| `sel`  | isIO & mem_wordaddr[IO_gpio_bit], check if accessed mem address is Gpio_ip  | 
| `wdata`  | write data |
| `rdata`  | read data |
| `read_en`  | read enable |
| `write_en`  | write enable |
| `offset`  | mem_wordaddr[4:3] |
| `gpio_pins`  | Wired to external Gpio_pins |

---

## How CPU Communicates With IP 

### Address Decoding
<img width="713" height="28" alt="image" src="https://github.com/user-attachments/assets/e168ae06-9675-441a-bafd-d44a26b66903" />

- When CPU access memory address `0x00400000` , mem_addre[22]=1 , isIO signal goes high implying a IO devices are accessed.
- `sel`- isIO & mem_wordaddr[IO_gpio_bit],  For indicating Gpio pins are used.

### Bidirectional Flow
<img width="439" height="33" alt="image" src="https://github.com/user-attachments/assets/83821362-95fc-47e6-969e-e7bce13f36ba" />

Gpio pins are assigned the value in Data or Z based on Direction control . Incase the pin is assigned Z , input drives that pin.

### Readback logic
<img width="554" height="273" alt="image" src="https://github.com/user-attachments/assets/5402a5da-20e1-4d0f-9d66-74602582616e" />

Gpio pins are wired to readback register . when read_en is asserted and memory location `0x00400044` is read ,it read backs gpio pins.  

---  
## SoC Integration
- The GPIO module is instantiated in [SoC](srcs/riscv.v)
 <img width="420" height="188" alt="image" src="https://github.com/user-attachments/assets/6f7166de-e4e5-4a0b-99f8-d2792473cc05" />
 <img width="707" height="295" alt="Screenshot 2026-01-01 201705" src="https://github.com/user-attachments/assets/57d1f38a-7796-4df0-9ecd-baf146b5e448" />
 
The above images show the instantiated module in SoC

- Changes from Task 2
  - LEDS is changed from output reg to inout for Bidirectional flow.
  - Direction register added in Gpio_ip and mapped to a memory address. 
  - Readback logic.

---



## Simulation
### [GPIO](sim/Gpio_test.v)
<img width="1355" height="391" alt="Screenshot 2026-01-01 195739" src="https://github.com/user-attachments/assets/832420f4-25b7-44dc-93ff-719d8ab4ab52" />

- Observation
  - Direction[4:0] - 11111(All are output).
      - Readback register = LEDS = Data register.
  - Direction[4:0] - 00000 (All are inputs).
      - Readback Resgister = LEDS = Z, This shows that LEDS are now acting as inputs .

---
### SOC
- C File - [gpio_test](sim/Gpio_task3.c)
- Test bench in task 2 was reused.
<img width="1298" height="289" alt="Screenshot 2026-01-01 193213" src="https://github.com/user-attachments/assets/b313be81-cf0d-4f19-8826-a32461c7ea05" />

The above image shows successful simulation of Bidirectional GPIO Ip on SoC.


---
## Key Learning
- Understood how SoC communicates with peripherals using address mapped IO.
- Bidirectional flow control.
- Adress Decoding and peripheral integration.
- Tool usage and flow control.
  





 

