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
### [GPIO](sim/gpio_ip_sim.v)
<img width="1352" height="323" alt="Screenshot 2025-12-23 113612" src="https://github.com/user-attachments/assets/00284e29-3629-4cda-b706-a28dd4d9731a" />

The above simulation shows data being successfully written into GPIO register when data is written to `0x004000020` address.

### SOC
- Assembly File - [gpio_test](gpio_test.S)
- The above file is converted to hex file and simulated using [SoC test bench](sim/tb_soc.v)
<img width="1308" height="303" alt="Screenshot 2025-12-23 131307" src="https://github.com/user-attachments/assets/f45f1223-cfb9-433b-ba3a-b0909db174db" />

The above image shows that GPIO data is written to LEDS register. 





 
