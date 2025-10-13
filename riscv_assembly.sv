// riscv_assembly.sv
// This file is designed to be included within a SystemVerilog module.

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   Your Company
// Engineer:  Your Name
//
// Create Date: 07/26/2025 10:03:47 PM
// Design Name:
// Module Name: riscv_assembly (conceptual, this is an include file)
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
// A simple assembler for RiscV written in SystemVerilog.
// See table page 104 of RiscV instruction manual.
// Bruno Levy, March 2022 (converted to SV 2025)
//
// Dependencies: Requires 'logic [31:0] MEM [0:N];'
// and 'int memPC;' to be
//               declared in the including module.
// Revision:
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////

// **`ifdef` and `ifndef` Compiler Directives**
// `ifdef` (if defined) and `ifndef` (if not defined) are compiler directives for
// conditional compilation. They check if a macro has been defined and include or
// exclude a block of code based on the result.
//
// - **Usage**: They are typically used to enable or disable sections of code for
//   different compilation modes, such as for verification/benchmarking or for
//   synthesis.
//
// - **Example (`ifdef BENCH`)**: The code within `ifdef BENCH` is only compiled
//   if the `BENCH` macro is defined. This allows for including simulation-specific
//   code (e.g., debug messages, error checks) that is not part of the final hardware.
//
// - **Example (`ifdef GET_ASM_LABELS`)**: This is used for a two-pass assembly process.
//   In the first pass, `GET_ASM_LABELS` is defined to calculate the addresses of
//   labels. In the second pass, it's undefined, and the final machine code is
//   generated with the correct offsets.

/*
 * Machine code will be generated in MEM,
 * starting from address 0 (can be changed below,
 * initial value of memPC).
 *
 * Example Usage in a top-level SystemVerilog module (e.g., top.sv):
 *
 * module top();
 * logic [31:0] MEM [0:255]; // Declare MEM array
 * int memPC;                // Declare program counter for assembly
 *
 * `include "riscv_assembly.sv" // Include this file
 *
 * int L0_ = 8; // Example: Initialize labels based on initial simulation run
 *
 * initial begin
 * memPC = 0; // Initialize memPC
 * ADD(x1,x0,x0);
 * ADDI(x2,x0,32);
 * Label(L0_); ADDI(x1,x1,1);
 * BNE(x1, x2, LabelRef(L0_));
 * EBREAK();
 * endASM();
 * end
 * endmodule
 *
 * NOTE: LUI, AUIPC take as argument pre-shifted constant, unlike in GNU assembly
 */

// Global variable for program counter, must be declared in the including module
// Example: int memPC;
// Example: initial memPC = 0; // Or assign directly here: int memPC = 0;
// (Vivado will treat this as initial assignment)

/***************************************************************************/

/*
 * Register names.
 * Makes assembly code more legible (without it,
 * one does not make the difference between immediate values and
 * register ids).
 */

localparam int x0 = 0, x1 = 1, x2 = 2, x3 = 3, x4 = 4, x5 = 5, x6 = 6, x7 = 7;
localparam int x8 = 8, x9 = 9, x10=10, x11=11, x12=12, x13=13, x14=14, x15=15;
localparam int x16=16, x17=17, x18=18, x19=19, x20=20, x21=21, x22=22, x23=23;
localparam int x24=24, x25=25, x26=26, x27=27, x28=28, x29=29, x30=30, x31=31;
// This localparam represents the machine code for a NOP (No-Operation) instruction.
// A NOP is a pseudo-instruction that expands to 'ADD x0, x0, x0', effectively doing nothing.
localparam logic [31:0] NOP_CODEOP = 32'b0000000_00000_00000_000_00000_0110011;

/***************************************************************************/

/*
 * R-Type instructions.
 * rd <- rs1 OP rs2
 */

// This task constructs and writes a generic 32-bit RISC-V R-Type instruction to memory.
// It takes all the instruction fields (opcode, rd, rs1, rs2, funct3, funct7) as inputs.
// It is the base task for all R-Type operations.
task automatic RType(
    input logic [6:0] opcode,
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [2:0] funct3,
    input logic [6:0] funct7
);
// MEM must be declared in the module that includes this file
// Example: logic [31:0] MEM [0:255];
// Concatenates the instruction fields in the correct RISC-V R-Type format and writes it to memory.
// memPC is a byte address, so it's divided by 4 to get the word address for the MEM array.
MEM[memPC / 4] = {funct7, rs2, rs1, funct3, rd, opcode};
// memPC[31:2] is equivalent to memPC / 4 for word-aligned addresses
// Increments the program counter to the next instruction address (4 bytes).
memPC = memPC + 4;
endtask : RType

// Helper task to generate a RISC-V ADD instruction.
// It calls `RType` with the fixed opcode, funct3, and funct7 fields for ADD.
task automatic ADD(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b000, 7'b0000000);
endtask : ADD

// Helper task to generate a RISC-V SUB (subtract) instruction.
// It calls `RType` with the fixed fields for SUB, which differ from ADD in the funct7 field.
task automatic SUB(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b000, 7'b0100000);
endtask : SUB

// Helper task to generate a RISC-V SLL (shift left logical) instruction.
task automatic SLL(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b001, 7'b0000000);
endtask : SLL

// Helper task to generate a RISC-V SLT (set on less than, signed) instruction.
task automatic SLT(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b010, 7'b0000000);
endtask : SLT

// Helper task to generate a RISC-V SLTU (set on less than, unsigned) instruction.
task automatic SLTU(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b011, 7'b0000000);
endtask : SLTU

// Helper task to generate a RISC-V XOR (exclusive OR) instruction.
task automatic XOR(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b100, 7'b0000000);
endtask : XOR

// Helper task to generate a RISC-V SRL (shift right logical) instruction.
task automatic SRL(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b101, 7'b0000000);
endtask : SRL

// Helper task to generate a RISC-V SRA (shift right arithmetic) instruction.
// The funct7 field differentiates SRA from SRL.
task automatic SRA(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b101, 7'b0100000);
endtask : SRA

// Helper task to generate a RISC-V OR (bitwise OR) instruction.
task automatic OR(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b110, 7'b0000000);
endtask : OR

// Helper task to generate a RISC-V AND (bitwise AND) instruction.
task automatic AND(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [4:0] rs2
);
RType(7'b0110011, rd, rs1, rs2, 3'b111, 7'b0000000);
endtask : AND

/***************************************************************************/

/*
 * I-Type instructions.
 * rd <- rs1 OP imm
 */

// This task constructs and writes a generic 32-bit RISC-V I-Type instruction to memory.
// It takes the instruction fields (opcode, rd, rs1, imm, funct3) as inputs.
// It is the base task for all I-Type operations.
task automatic IType(
    input logic [6:0]  opcode,
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm,
    input logic [2:0]  funct3
);
// Concatenates the instruction fields in the correct RISC-V I-Type format and writes it to memory.
// Note that only the lower 12 bits of the immediate value are used.
MEM[memPC / 4] = {imm[11:0], rs1, funct3, rd, opcode};
// Increments the program counter to the next instruction address.
memPC = memPC + 4;
endtask : IType

// Helper task to generate a RISC-V ADDI (add immediate) instruction.
task automatic ADDI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0010011, rd, rs1, imm, 3'b000);
endtask : ADDI

// Helper task to generate a RISC-V SLTI (set on less than immediate, signed) instruction.
task automatic SLTI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0010011, rd, rs1, imm, 3'b010);
endtask : SLTI

// Helper task to generate a RISC-V SLTIU (set on less than immediate, unsigned) instruction.
task automatic SLTIU(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0010011, rd, rs1, imm, 3'b011);
endtask : SLTIU

// Helper task to generate a RISC-V XORI (exclusive OR immediate) instruction.
task automatic XORI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0010011, rd, rs1, imm, 3'b100);
endtask : XORI

// Helper task to generate a RISC-V ORI (bitwise OR immediate) instruction.
task automatic ORI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0010011, rd, rs1, imm, 3'b110);
endtask : ORI

// Helper task to generate a RISC-V ANDI (bitwise AND immediate) instruction.
task automatic ANDI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0010011, rd, rs1, imm, 3'b111);
endtask : ANDI

// The three shifts, SLLI, SRLI, SRAI, are a special case of I-Type instructions
// that use an R-Type format. The immediate value (shift amount) is encoded
// in the rs2 field.

// This task generates a 32-bit RISC-V SLLI (shift left logical immediate) instruction.
// It calls `RType` with the opcode and funct3 for SLLI, and uses `imm[4:0]` as the shift amount in the rs2 field.
task automatic SLLI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
RType(7'b0010011, rd, rs1, imm[4:0], 3'b001, 7'b0000000);
endtask : SLLI

// This task generates a 32-bit RISC-V SRLI (shift right logical immediate) instruction.
// It calls `RType` with the opcode and funct3 for SRLI, and uses `imm[4:0]` as the shift amount.
task automatic SRLI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
RType(7'b0010011, rd, rs1, imm[4:0], 3'b101, 7'b0000000);
endtask : SRLI

// This task generates a 32-bit RISC-V SRAI (shift right arithmetic immediate) instruction.
// The funct7 field differentiates SRAI from SRLI. It uses `imm[4:0]` for the shift amount.
task automatic SRAI(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
RType(7'b0010011, rd, rs1, imm[4:0], 3'b101, 7'b0100000);
endtask : SRAI

/***************************************************************************/

/*
 * Jumps (JAL and JALR)
 */

// This task constructs and writes a generic 32-bit RISC-V J-Type instruction (for JAL).
// It takes the opcode, destination register, and a 32-bit immediate value as inputs.
task automatic JType(
    input logic [6:0]  opcode,
    input logic [4:0]  rd,
    input logic [31:0] imm
);
// Concatenates the immediate value's bits in a scrambled order specific to the J-Type format.
MEM[memPC / 4] = {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
// Increments the program counter.
memPC = memPC + 4;
endtask : JType

// Helper task to generate a RISC-V JAL (jump and link) instruction.
// It calls `JType` with the opcode for JAL and the specified register and immediate value.
task automatic JAL(
    input logic [4:0] rd,
    input logic [31:0] imm
);
JType(7'b1101111, rd, imm);
endtask : JAL

// JALR is encoded in the I-Type format, so it uses the IType task as a base.
// Helper task to generate a RISC-V JALR (jump and link register) instruction.
task automatic JALR(
    input logic [4:0] rd,
    input logic [4:0] rs1,
    input logic [31:0] imm
);
IType(7'b1100111, rd, rs1, imm, 3'b000);
endtask : JALR

/***************************************************************************/

/*
 * Branch instructions.
 */

// This task constructs and writes a generic 32-bit RISC-V B-Type (branch) instruction.
// It takes the opcode, two source registers, an immediate value, and a funct3 field.
task automatic BType(
    input logic [6:0]  opcode,
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm,
    input logic [2:0]  funct3
);
// Concatenates the instruction fields, with the immediate value split and
// rearranged according to the B-Type format.
MEM[memPC / 4] = {imm[12],imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
// Increments the program counter.
memPC = memPC + 4;
endtask : BType

// Helper task to generate a RISC-V BEQ (branch if equal) instruction.
task automatic BEQ(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
BType(7'b1100011, rs1, rs2, imm, 3'b000);
endtask : BEQ

// Helper task to generate a RISC-V BNE (branch if not equal) instruction.
task automatic BNE(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
BType(7'b1100011, rs1, rs2, imm, 3'b001);
endtask : BNE

// Helper task to generate a RISC-V BLT (branch if less than, signed) instruction.
task automatic BLT(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
BType(7'b1100011, rs1, rs2, imm, 3'b100);
endtask : BLT

// Helper task to generate a RISC-V BGE (branch if greater than or equal, signed) instruction.
task automatic BGE(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
BType(7'b1100011, rs1, rs2, imm, 3'b101);
endtask : BGE

// Helper task to generate a RISC-V BLTU (branch if less than, unsigned) instruction.
task automatic BLTU(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
BType(7'b1100011, rs1, rs2, imm, 3'b110);
endtask : BLTU

// Helper task to generate a RISC-V BGEU (branch if greater than or equal, unsigned) instruction.
task automatic BGEU(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
BType(7'b1100011, rs1, rs2, imm, 3'b111);
endtask : BGEU

/***************************************************************************/

/*
 * LUI and AUIPC (U-Type instructions)
 */

// This task constructs and writes a generic 32-bit RISC-V U-Type instruction to memory.
// It takes the opcode, destination register, and a 32-bit immediate value as inputs.
task automatic UType(
    input logic [6:0]  opcode,
    input logic [4:0]  rd,
    input logic [31:0] imm
);
// Concatenates the upper 20 bits of the immediate value with the rd and opcode fields.
MEM[memPC / 4] = {imm[31:12], rd, opcode};
// Increments the program counter.
memPC = memPC + 4;
endtask : UType

// Helper task to generate a RISC-V LUI (load upper immediate) instruction.
task automatic LUI(
    input logic [4:0]  rd,
    input logic [31:0] imm
);
UType(7'b0110111, rd, imm << 12);
endtask : LUI

// Helper task to generate a RISC-V AUIPC (add upper immediate to program counter) instruction.
task automatic AUIPC(
    input logic [4:0]  rd,
    input logic [31:0] imm
);
UType(7'b0010111, rd, imm << 12);
endtask : AUIPC

/***************************************************************************/

/*
 * Load instructions
 */

// This task generates a RISC-V LB (load byte) instruction.
// It uses the base IType task with the specific fields for LB.
task automatic LB(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0000011, rd, rs1, imm, 3'b000);
endtask : LB

// This task generates a RISC-V LH (load halfword) instruction.
task automatic LH(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0000011, rd, rs1, imm, 3'b001);
endtask : LH

// This task generates a RISC-V LW (load word) instruction.
task automatic LW(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0000011, rd, rs1, imm, 3'b010);
endtask : LW

// This task generates a RISC-V LBU (load byte unsigned) instruction.
task automatic LBU(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0000011, rd, rs1, imm, 3'b100);
endtask : LBU

// This task generates a RISC-V LHU (load halfword unsigned) instruction.
task automatic LHU(
    input logic [4:0]  rd,
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
IType(7'b0000011, rd, rs1, imm, 3'b101);
endtask : LHU

/***************************************************************************/

/*
 * Store instructions
 */

// This task constructs and writes a generic 32-bit RISC-V S-Type (store) instruction.
// It takes the opcode, two source registers, an immediate value, and a funct3 field.
task automatic SType(
    input logic [6:0]  opcode,
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm,
    input logic [2:0]  funct3
);
// Concatenates the instruction fields, with the immediate value split and
// the two source registers swapped to match the standard assembly syntax.
MEM[memPC / 4] = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
// Increments the program counter.
memPC = memPC + 4;
endtask : SType

// Note: in SB, SH, SW, rs1 and rs2 are swapped, to match assembly code:
// for instance:
//    rs2    rs1
//  sw ra, 0(sp)

// This task generates a RISC-V SB (store byte) instruction.
// Note the swapping of rs1 and rs2 to match the assembly code.
task automatic SB(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
SType(7'b0100011, rs2, rs1, imm, 3'b000);
endtask : SB

// This task generates a RISC-V SH (store halfword) instruction.
// Note the swapping of rs1 and rs2.
task automatic SH(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
SType(7'b0100011, rs2, rs1, imm, 3'b001);
endtask : SH

// This task generates a RISC-V SW (store word) instruction.
// Note the swapping of rs1 and rs2.
task automatic SW(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
SType(7'b0100011, rs2, rs1, imm, 3'b010);
endtask : SW

/***************************************************************************/

/*
 * SYSTEM instructions
 */

// This task generates a RISC-V FENCE instruction, used to order memory operations.
// It takes `pred` (predecessor) and `succ` (successor) as inputs.
task automatic FENCE(
    input logic [3:0] pred,
    input logic [3:0] succ
);
// Concatenates the specific fields to form the FENCE instruction.
MEM[memPC / 4] = {4'b0000, pred, succ, 5'b00000, 3'b000, 5'b00000, 7'b1110011};
// Increments the program counter.
memPC = memPC + 4;
endtask : FENCE

// This task generates a RISC-V FENCE.I instruction, for ordering instruction fetches.
// It uses default values for the FENCE fields.
task automatic FENCE_I();
    MEM[memPC / 4] = {4'b0000, 4'b0000, 4'b0000, 5'b00000, 3'b001, 5'b00000, 7'b1110011};
memPC = memPC + 4;
endtask : FENCE_I

// This task generates a RISC-V ECALL (Environment Call) instruction.
// ECALL is used to make a request to the execution environment.
task automatic ECALL();
    MEM[memPC / 4] = {12'b000000000000, 5'b00000, 3'b000, 5'b00000, 7'b1110011};
memPC = memPC + 4;
endtask : ECALL

// This task generates a RISC-V EBREAK (Environment Break) instruction.
// EBREAK is used to return control to a debugging environment.
task automatic EBREAK();
    MEM[memPC / 4] = {12'b000000000001, 5'b00000, 3'b000, 5'b00000, 7'b1110011};
memPC = memPC + 4;
endtask : EBREAK

// This task generates a RISC-V CSRRW (Control and Status Register Read and Write) instruction.
// It writes a value to a CSR and returns the old value.
task automatic CSRRW(
    input logic [4:0] rd,
    input logic [11:0] csr,
    input logic [4:0] rs1
);
// Concatenates the CSR address, source register, funct3, destination register, and opcode.
MEM[memPC / 4] = {csr, rs1, 3'b001, rd, 7'b1110011};
memPC = memPC + 4;
endtask : CSRRW

// This task generates a RISC-V CSRRS (Control and Status Register Read and Set) instruction.
// It performs a bitwise OR with the CSR value and returns the old value.
task automatic CSRRS(
    input logic [4:0] rd,
    input logic [11:0] csr,
    input logic [4:0] rs1
);
MEM[memPC / 4] = {csr, rs1, 3'b010, rd, 7'b1110011};
memPC = memPC + 4;
endtask : CSRRS

// This task generates a RISC-V CSRRC (Control and Status Register Read and Clear) instruction.
// It performs a bitwise AND with the inverted mask and returns the old value.
task automatic CSRRC(
    input logic [4:0] rd,
    input logic [11:0] csr,
    input logic [4:0] rs1
);
MEM[memPC / 4] = {csr, rs1, 3'b011, rd, 7'b1110011};
memPC = memPC + 4;
endtask : CSRRC

// This task generates a RISC-V CSRRWI (CSR Read and Write Immediate) instruction.
// It writes a zimm[4:0] to a CSR and returns the old value.
task automatic CSRRWI(
    input logic [4:0] rd,
    input logic [11:0] csr,
    input logic [31:0] imm
);
MEM[memPC / 4] = {csr, imm[4:0], 3'b101, rd, 7'b1110011};
memPC = memPC + 4;
endtask : CSRRWI

// This task generates a RISC-V CSRRSI (CSR Read and Set Immediate) instruction.
// It performs a bitwise OR with a zimm[4:0] and returns the old value.
task automatic CSRRSI(
    input logic [4:0] rd,
    input logic [11:0] csr,
    input logic [31:0] imm
);
MEM[memPC / 4] = {csr, imm[4:0], 3'b110, rd, 7'b1110011};
memPC = memPC + 4;
endtask : CSRRSI

// This task generates a RISC-V CSRRCI (CSR Read and Clear Immediate) instruction.
// It performs a bitwise AND with the inverted zimm[4:0] mask and returns the old value.
task automatic CSRRCI(
    input logic [4:0] rd,
    input logic [11:0] csr,
    input logic [31:0] imm
);
MEM[memPC / 4] = {csr, imm[4:0], 3'b111, rd, 7'b1110011};
memPC = memPC + 4;
endtask : CSRRCI

/***************************************************************************/

/*
 * Labels.
 * Example of usage:
 *
 * ADD(x1,x0,x0);
 * Label(L0_); ADDI(x1,x1,1);
 * JAL(x0, LabelRef(L0_));
 */

// Flag to track if any assembly errors have occurred.
// Use logic for single-bit flags
logic ASMerror = 0;

// This task sets a label at the current memory program counter (`memPC`).
// It is used to mark a specific instruction location for jumps and branches.
// It performs checks during simulation to ensure the label is correctly initialized.
task automatic Label(
    inout int L // Use 'int' for the label, 'inout' is correct for its usage
);
begin
`ifdef BENCH
    // Check if the label variable has an uninitialized value ('x').
    if(L === 'hx) begin // Check for X value in SystemVerilog
        $error("Missing label initialization for label at PC: %0d", memPC); // Using $error
        ASMerror = 1;
    // Check if the label's value matches the current program counter.
    end else if(L != memPC) begin
        $error("Incorrect label initialization: Expected %0d, Got %0d for label at PC: %0d", memPC, L, memPC); // Using $error
        ASMerror = 1;
    end
    // Provides informational message during simulation, showing the label's PC.
    $info("Label set at PC: %0d", memPC); // Using $info
`endif
end
endtask : Label

// This function calculates the relative offset for a branch or jump to a label.
// It takes the label's program counter as input.
function automatic logic [31:0] LabelRef(
    input int L // Use 'int' for input
);
begin
`ifdef BENCH
    // Check for references to uninitialized labels.
    if(L === 'hx) begin
        $error("Reference to uninitialized label: %0d", L); // Using $error
        ASMerror = 1;
    end
`endif
    // Calculates the offset by subtracting the current `memPC` from the label's PC.
    return L - memPC; // Use return keyword
end
endfunction : LabelRef

// This task marks the end of the assembly code generation block.
// It is used in the testbench to check for assembly errors and to finish the simulation.
task automatic endASM();
begin
`ifdef GET_ASM_LABELS
    // If the GET_ASM_LABELS macro is defined, the simulation finishes after label calculation.
    $finish();
`endif
`ifdef BENCH
    // If the BENCH macro is defined and errors were detected, a fatal error is triggered.
    if(ASMerror) $fatal(1, "Assembly errors detected. Exiting simulation."); // Using $fatal for unrecoverable errors
`endif
end
endtask : endASM


/****************************************************************************/

/*
 * RISC-V ABI register names.
 */

// These localparams map the ABI (Application Binary Interface) names to the
// corresponding register numbers (x0-x31), making the code more readable.
localparam int zero = x0;
localparam int ra   = x1;
localparam int sp   = x2;
localparam int gp   = x3;
localparam int tp   = x4;
localparam int t0   = x5;
localparam int t1   = x6;
localparam int t2   = x7;
localparam int fp   = x8;
localparam int s0   = x8;
localparam int s1   = x9;
localparam int a0   = x10;
localparam int a1   = x11;
localparam int a2   = x12;
localparam int a3   = x13;
localparam int a4   = x14;
localparam int a5   = x15;
localparam int a6   = x16;
localparam int a7   = x17;
localparam int s2   = x18;
localparam int s3   = x19;
localparam int s4   = x20;
localparam int s5   = x21;
localparam int s6   = x22;
localparam int s7   = x23;
localparam int s8   = x24;
localparam int s9   = x25;
localparam int s10  = x26;
localparam int s11  = x27;
localparam int t3   = x28;
localparam int t4   = x29;
localparam int t5   = x30;
localparam int t6   = x31;

/*
 * RISC-V pseudo-instructions
 */

// This pseudo-instruction task generates a NOP (No-Operation) instruction.
// A NOP is a physical instruction that does nothing. It is a convenience task.
task automatic NOP();
    begin
        ADD(x0,x0,x0);
    end
endtask : NOP

// This task generates a pseudo-instruction for loading an immediate value (`LI`).
// It handles different cases to use the most efficient instruction(s) for the value.
// See https://stackoverflow.com/questions/50742420/
// risc-v-build-32-bit-constants-with-lui-and-addi
// It adjusts the immediate value passed to LUI to cancel sign expansion done by ADDI.
task automatic LI(
    input logic [4:0]  rd,
    input logic [31:0] imm
);
begin
    // If the immediate value is 0, use a simple ADD instruction.
    if(imm == 0) begin
        ADD(rd,zero,zero);
    // If the value fits within 12 bits (I-Type format), use ADDI.
    end else if($signed(imm) >= -2048 && $signed(imm) < 2048) begin
        ADDI(rd,zero,imm);
    // Otherwise, use LUI followed by ADDI to load the full 32-bit constant.
    end else begin
        LUI(rd,imm + (imm[11] << 12));
        // cancel sign expansion
        if(imm[11:0] != 0) begin
            ADDI(rd,rd,imm[11:0]);
        end
    end
end
endtask : LI

// This pseudo-instruction task generates a CALL. It is a convenience task
// that expands to an AUIPC followed by a JALR to perform a function call.
task automatic CALL(
    input logic [31:0] offset
);
begin
    // AUIPC loads the upper bits of the address into a temporary register (x6).
    AUIPC(x6, offset);
    // JALR performs the jump to the final address and saves the return address in x1.
    JALR(x1, x6, offset[11:0]);
end
endtask : CALL

// This pseudo-instruction task generates a RET (return) instruction.
// It is a convenience task that expands to a JALR with the return address in x1.
task automatic RET();
begin
    // Jumps to the address in the return address register (x1) with a zero offset.
    // The return address is not saved (rd=x0).
    JALR(x0,x1,0);
end
endtask : RET

// This pseudo-instruction task generates an MV (move) instruction.
// It is a convenience task that expands to an ADD with a zero source register.
task automatic MV(
    input logic [4:0]  rd,
    input logic [4:0]  rs1
);
begin
    // Moves the value from rs1 to rd by adding it to the zero register.
    ADD(rd,rs1,zero);
end
endtask : MV

// This pseudo-instruction task generates a J (jump) instruction.
// It is a convenience task that expands to a JAL with the zero register as rd.
task automatic J(
    input logic [31:0] imm
);
begin
    // TODO: far targets - This comment indicates that this task may not handle long jumps correctly.
    // Jumps to the immediate address without saving a return address (rd=zero).
    JAL(zero,imm);
end
endtask : J

// This pseudo-instruction task generates a JR (jump register) instruction.
// It is a convenience task that expands to a JALR with the zero register as rd.
task automatic JR(
    input logic [4:0]  rs1,
    input logic [31:0] imm // FIX: Removed the duplicated 'logic' keyword here
);
begin
    // Jumps to the address in `rs1` with an immediate offset, without saving a return address.
    JALR(zero,rs1,imm);
end
endtask : JR

// This pseudo-instruction task generates a BEQZ (branch if equal to zero) instruction.
// It is a convenience task that expands to a BEQ with a zero source register.
task automatic BEQZ(
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
begin
    // Compares `rs1` with the zero register (x0).
    BEQ(rs1,x0,imm);
end
endtask : BEQZ

// This pseudo-instruction task generates a BNEZ (branch if not equal to zero) instruction.
// It is a convenience task that expands to a BNE with a zero source register.
task automatic BNEZ(
    input logic [4:0]  rs1,
    input logic [31:0] imm
);
begin
    // Compares `rs1` with the zero register (x0).
    BNE(rs1,x0,imm);
end
endtask : BNEZ

// This pseudo-instruction task generates a BGT (branch if greater than, signed) instruction.
// It is a convenience task that expands to a BLT with the source registers swapped.
task automatic BGT(
    input logic [4:0]  rs1,
    input logic [4:0]  rs2,
    input logic [31:0] imm
);
begin
    // A > B is the same as B < A.
    BLT(rs2,rs1,imm);
end
endtask : BGT

// This task is used to insert a 32-bit word of data directly into memory.
task automatic DATAW(
    input logic [31:0] w
);
begin
    // Writes the entire 32-bit word to the current memory location.
    MEM[memPC / 4] = w;
    // Increments the program counter by 4 bytes.
    memPC = memPC+4;
end
endtask : DATAW

// This task is used to insert 4 bytes of data directly into memory.
task automatic DATAB(
    input logic [7:0] b1,
    input logic [7:0] b2,
    input logic [7:0] b3,
    input logic [7:0] b4
);
begin
    // Writes each byte to its correct position within the 32-bit word.
    MEM[memPC / 4][ 7: 0] = b1;
    MEM[memPC / 4][15: 8] = b2;
    MEM[memPC / 4][23:16] = b3;
    MEM[memPC / 4][31:24] = b4;
    // Increments the program counter by 4 bytes.
    memPC = memPC+4;
end
endtask : DATAB


/****************************************************************************/
