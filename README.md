# RISC-V Single-Cycle Processor

A complete hardware description (HDL) implementation of a **32-bit RISC-V Single-Cycle Processor**. This project implements the core instruction set (RV32I) using **SystemVerilog** and is designed with a clear, modular architecture suitable for simulation and FPGA synthesis.

***

## Overview

This repository contains the RTL (Register-Transfer Level) design for a fundamental single-cycle CPU based on the **RISC-V Instruction Set Architecture (ISA)**. The single-cycle architecture executes every instruction in a single clock cycle, providing a clear and foundational understanding of CPU design principles.

### Key Features

* **ISA Support:** Implements the **RV32I Base Integer Instruction Set** (including R-type, I-type, S-type, B-type, U-type, and J-type instructions).
* **Architecture:** Classic **Single-Cycle Datapath** and **Control Unit** design.
* **Modularity:** Cleanly separated modules for major components (ALU, Register File, Memory, Controller, etc.).
* **Language:** Developed entirely in **SystemVerilog (.sv)**.
* **Testbenches:** Includes multiple testbenches (`testbench.sv`, `tb_all_riscv32i_is.sv`) and assembly memory files (`riscvtest.mem`) for functional verification.
* **FPGA Ready:** Contains a top-level module (`top_artys750.sv`) targeting implementation on a Xilinx **Artix-7 FPGA** (such as the Digilent Arty S7-50).

```mermaid
graph TD
    subgraph Control Unit
        ID(Main Decoder)
        ALUDec(ALU Decoder)
    end
    
    PC[Program Counter]
    IMem[Instruction Memory]
    RegFile[Register File]
    ALU[Arithmetic Logic Unit]
    DMem[Data Memory]
    Extend[Sign/Zero Extend]
    MuxPC(Mux)
    MuxALU(Mux)
    MuxWB(Mux)
    AdderPC(Adder +4)
    AdderBR(Adder Branch)
    
    
    %% Instruction Flow
    PC --> IMem
    IMem -- Instruction [31:0] --> ID
    IMem -- Instruction [31:25, 11:7] --> ALUDec
    
    %% Control Flow
    ID -- Control Signals --> RegFile
    ID -- Control Signals --> ALUDec
    ID -- Control Signals --> DMem
    ID -- PCSel, RegWEn, ALUSrc, MemWEn, MemToReg --> MuxPC, RegFile, MuxALU, DMem, MuxWB
    ALUDec -- ALUOp --> ALU
    
    %% Register Read
    IMem -- Instruction [19:15] --> RegFile
    IMem -- Instruction [24:20] --> RegFile
    RegFile -- Read Data 1 --> ALU
    RegFile -- Read Data 2 --> MuxALU
    
    %% Immediate
    IMem -- Instruction [31:7] --> Extend
    Extend -- Extended Immediate --> MuxALU
    Extend -- Extended Immediate (Branch/Jump) --> AdderBR
    
    %% ALU and Data Memory
    MuxALU -- Op2 --> ALU
    ALU -- Result --> MuxWB
    ALU -- Result Address --> DMem
    RegFile -- Read Data 2 --> DMem
    DMem -- Read Data --> MuxWB
    
    %% Register Write
    MuxWB -- Write Data --> RegFile
    IMem -- Instruction [11:7] --> RegFile
    
    %% PC Control
    PC --> AdderPC
    AdderPC -- PC+4 --> MuxPC
    
    %% Conditional Branch
    ALU -- Zero Flag --> AdderBR
    AdderBR -- Branch Target --> MuxPC
    
    MuxPC -- Next PC --> PC
    
    style PC fill:#bbf,stroke:#333,stroke-width:2px
    style IMem fill:#cfc,stroke:#333,stroke-width:2px
    style RegFile fill:#fcf,stroke:#333,stroke-width:2px
    style ALU fill:#ffc,stroke:#333,stroke-width:2px
    style DMem fill:#cfc,stroke:#333,stroke-width:2px
    style ID fill:#add,stroke:#333,stroke-width:2px
    style ALUDec fill:#add,stroke:#333,stroke-width:2px
    style MuxPC fill:#faa,stroke:#333,stroke-width:2px
    style MuxALU fill:#faa,stroke:#333,stroke-width:2px
    style MuxWB fill:#faa,stroke:#333,stroke-width:2px
    style AdderPC fill:#ddd,stroke:#333,stroke-width:2px
    style AdderBR fill:#ddd,stroke:#33
```
***

## Technology Stack

| Component | Description |
| :--- | :--- |
| **HDL** | **SystemVerilog (.sv)** |
| **ISA** | **RISC-V (RV32I)** |
| **Simulation** | Any standard SystemVerilog simulator (e.g., Icarus Verilog, ModelSim/QuestaSim, Vivado Simulator) |
| **Synthesis Target** | Xilinx FPGAs (specifically includes a top file for **Artix-7**) |

***

## Architecture and Components

The processor design is divided into highly modular SystemVerilog files, corresponding to the classic components of a single-cycle CPU.

| File | Component | Description |
| :--- | :--- | :--- |
| `riscvsingle.sv` | **Top Module** | Instantiates the Datapath and Control Unit to form the complete processor. |
| `datapath.sv` | **Datapath** | Handles data flow, containing the Register File, ALU, MUXes, and extend logic. |
| `controller.sv` | **Control Unit** | Generates all necessary control signals based on the instruction opcode. |
| `maindec.sv` | **Main Decoder** | Decodes the instruction opcode to set control signals. |
| `aludec.sv` | **ALU Decoder** | Decodes the Function Code (funct3/funct7) to determine the ALU operation. |
| `alu.sv` | **Arithmetic Logic Unit** | Performs arithmetic and logical operations. |
| `regfile.sv` | **Register File** | Stores the 32 general-purpose 32-bit registers (x0-x31). |
| `imem.sv` | **Instruction Memory** | Stores program instructions. Initialized from `.mem` files. |
| `dmem.sv` | **Data Memory** | Used for load and store operations. |
| `extend.sv` | **Sign/Zero Extender** | Extends immediate values according to instruction type. |
| `tb_*.sv` | **Testbenches** | Verification modules for running instruction tests. |

***

## Getting Started

### Prerequisites

You need a SystemVerilog simulator installed on your system.

* **Recommended:** **Icarus Verilog** (Free/Open Source) or commercial tools like **ModelSim/QuestaSim** or **Xilinx Vivado Simulator**.

### Cloning the Repository

1.  Clone the repository to your local machine:
    ```bash
    git clone [https://github.com/javagoza/RISC_V_Single_Cycle_Processor.git](https://github.com/javagoza/RISC_V_Single_Cycle_Processor.git)
    cd RISC_V_Single_Cycle_Processor
    ```

### Simulation

To run a simulation and verify the processor's functionality, you will typically compile all `.sv` files and run one of the testbenches.

**Example using Icarus Verilog (iverilog):**

1.  **Compile the design and a testbench (e.g., `testbench.sv`):**
    ```bash
    iverilog -o riscv_sim *.sv 
    ```
    *This command compiles all `.sv` files into an executable named `riscv_sim`.*

2.  **Run the simulation:**
    ```bash
    vvp riscv_sim
    ```

The testbench will load instructions from a `.mem` file (like `riscvtest.mem`), execute them, and print the results or check for success/failure.

### FPGA Synthesis

The design includes a top-level file (`top_artys750.sv`) for synthesis.

1.  **Tool Flow:** Use a synthesis tool like **Xilinx Vivado**.
2.  **Create Project:** Create a new project in Vivado targeting the **Artix-7** family (or your specific board).
3.  **Add Sources:** Add all `.sv` files in the repository as design sources.
4.  **Set Top Module:** Set the top-level entity to `top_artys750` (or `riscvsingle` if testing without FPGA I/O).
5.  **Synthesize and Implement:** Run the standard synthesis, implementation, and bitstream generation flow.

***

## Testing

The repository provides several test files to ensure correct operation:

* **`riscvtest.mem`:** A memory image containing encoded RISC-V instructions (machine code).
* **`tb_all_riscv32i_is.sv`:** A comprehensive testbench designed to check the execution of instructions across the entire RV32I base set.

Refer to the testbench files for specific signals to monitor during waveform analysis.

***

## Author

* **javagoza** - [https://github.com/javagoza](https://github.com/javagoza)
