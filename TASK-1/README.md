# Task-1 : Environmenrt setup and RISC-V reference validation

## ENVIRONMENT
Github Codespace(LINUX)

## RISC-V REFERENCE PROGRAM
- **Repository:** vsd-risc-v2
- **Program Path:** samples/
- The reference program was successfully compiled and excuted using spike
- **Output:** "Sum from 1 to 9 is 45"
 <img width="444" height="114" alt="Screenshot 2025-12-19 133111" src="https://github.com/user-attachments/assets/46a2ca44-7962-466f-a68b-3f87c9517f55" />

---
##  VSDFPGA LABS
- **Repository:** vsdfpga_labs
- **Lab:** basicRISCV Firmware build
- Generated riscv_logo.bram.hex successfully
- Risc-v_logo.c file
  <img width="1489" height="791" alt="Screenshot 2025-12-20 120204" src="https://github.com/user-attachments/assets/cb49786a-577f-420f-9312-e2f9acf522d3" />

- Bitstream generation and FPGA flashing skipped
<img width="1549" height="141" alt="Screenshot 2025-12-19 110656" src="https://github.com/user-attachments/assets/6b8ed38b-b51b-4603-87ca-b99f47ae7d18" />

---
## UNDERSTANDING CHECK
### 1. Where is the RISC-V program located in the vsd-riscv2 repository?
The reference program is located in the 'samples' folder within vsd-riscv2 repository

### 2. How is the program compiled and loaded into memory?
The program is compiled using 'riscv64-unknown-elf-gcc' toolchain and executed usind spike simulator.

### 3. How does the RISC-V core access memory and memory-mapped IO?
Risc-v core access memory via load and store operations using system bus.

### 4. Where would a new FPGA IP block logically integrate in this system?
The new FPGA IP block will be integrated to a memory mapped peripheral on system interconnect. The Risc-v processor will be able to communicate with this by access memory in a particular address range. 

## NOTE
- The complete workfloe is executed in Github Codespaces .Bitstream generation and FPGA flashing is skipped.
