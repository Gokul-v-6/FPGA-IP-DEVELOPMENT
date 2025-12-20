# Task-1 : Environmenrt setup and RISC-V reference validation

## ENVIRONMENT
Github Codespace(LINUX)
Local(WSL ,Ubantu)

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
- Risc-v_logo.c
<img width="1489" height="791" alt="Screenshot 2025-12-20 120204" src="https://github.com/user-attachments/assets/d9eb70c0-ae70-4ef2-8842-fdc4109437ae" />

- Compiling riscv_logo file and converting it to a hex file for preloading BRAM with instruction for FPGA implementaion.
<img width="1549" height="300" alt="Screenshot 2025-12-19 110656" src="https://github.com/user-attachments/assets/6b8ed38b-b51b-4603-87ca-b99f47ae7d18" />

- Output of riscv_logo.c
  
  <img width="1514" height="929" alt="Screenshot 2025-12-20 130118" src="https://github.com/user-attachments/assets/0f17b42d-e27b-49c9-a8f3-7325aad93588" />
- The above program is compiled in riscv-elf-gcc and executed using spike.
  

---
## UNDERSTANDING CHECK
### 1. Where is the RISC-V program located in the vsd-riscv2 repository?
The reference program is located in the `samples` folder within vsd-riscv2 repository

### 2. How is the program compiled and loaded into memory?
The program is compiled using `riscv64-unknown-elf-gcc` toolchain and executed usind spike simulator.

### 3. How does the RISC-V core access memory and memory-mapped IO?
Risc-v core access memory via load and store operations using system bus.

### 4. Where would a new FPGA IP block logically integrate in this system?
The new FPGA IP block will be integrated to a memory mapped peripheral on system interconnect. The Risc-v processor will be able to communicate with this by access memory in a particular address range.

---

## Local Machine Preparation
- Cloned `vsd-riscv2` and `vsdfpga_labs` repository locally
<img width="897" height="320" alt="Screenshot 2025-12-20 181638" src="https://github.com/user-attachments/assets/0c049ba6-2a7c-4fca-8288-a7eabf41f5de" />

- Packages installed:
  - riscv64-unknown-elf-gcc
  - spike simulator
- Above packages are installed with reference to:
  https://raw.githubusercontent.com/vsdip/vsd-riscv2/refs/heads/main/.devcontainer/Dockerfile
- Output from reference program(Sum to 9 numbers)
  <img width="1913" height="200" alt="Screenshot 2025-12-20 160159" src="https://github.com/user-attachments/assets/61fdfc7a-04eb-47ae-a79a-9e21f352d28a" />
- Compiling `riscv_logo` locally using riscv64-unknown-elf-gcc compiler and executing using spike simulator
- <img width="1478" height="324" alt="Screenshot 2025-12-20 184303" src="https://github.com/user-attachments/assets/d2786202-c6a5-4e01-805a-6870e13c7f2b" />
- Output
 <img width="881" height="345" alt="Screenshot 2025-12-20 184015" src="https://github.com/user-attachments/assets/14913baa-d9eb-4880-a6b9-9363c5309caf" />

---


## NOTE
- The complete workflow is executed in Github Codespaces .Bitstream generation and FPGA flashing is skipped.
