`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 06/02/2025 09:27:45 PM
// Design Name:
// Module Name: maindec
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Main Control Decoder for RISC-V processor
//              Generates all primary control signals based on instruction opcode
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module maindec(
    input logic [6:0] op,             // 7-bit opcode from instruction[6:0]

    // Data path control outputs
    output logic [2:0] ResultSrc,    // Result source selection:
                                     // 000: ALU result
                                     // 001: Memory read data (for loads)
                                     // 010: PC+4 (for JAL, JALR)
                                     // 011: Immediate value (for LUI)
                                     // 100: PC+Immediate value (for AUIPC)
    output logic Branch,             // Branch instruction flag (1 for BEQ/BNE, etc.)
    output logic ALUSrc,             // ALU source B selection:
                                     // 0: ReadData2 (from rs2)
                                     // 1: Immediate value (from ImmExtender)
    output logic RegWriteEn,         // Register write enable (1 to write result to rd)
    output logic Jump,               // Jump instruction flag (1 for JAL)
    output logic JumpR,              // Jump + Reg instruction flag (1 for JALR)

    // Immediate generation control
    output logic [2:0] ImmSrc,       // Immediate source format selection:
                                     // 000: I-type
                                     // 001: S-type
                                     // 010: B-type
                                     // 011: J-type
                                     // 100: U-type

    // ALU control
    output logic [1:0] ALUOp         // ALU operation type (passed to ALU Control unit):
                                     // 00: Addition (for Load/Store addr, LUI bypass)
                                     // 01: Subtraction (for Branch equality)
                                     // 10: R-type/I-type decode (for specific ALU function based on funct3/7)
);

    // Internal control signal vector - packed for easier assignment
    // Format: {RegWriteEn, ImmSrc[2:0], ALUSrc, ResultSrc[2:0], Branch, ALUOp[1:0], Jump}
    // Removed MemWrite bit from the packed vector
    logic [12:0] controls;

    // Adjust assignment to reflect the removed MemWrite bit
    assign {RegWriteEn, ImmSrc, ALUSrc,
            ResultSrc, Branch, ALUOp, Jump, JumpR} = controls;

    // Main instruction decode logic
    always_comb
        case(op)
            // Control bit assignments: RegWriteEn_ImmSrc_ALUSrc_ResultSrc_Branch_ALUOp_Jump_JumpR

            // LOAD  - I-type
            7'b0000011: controls = 13'b1_000_1_001_0_00_0_0;
            // RegWriteEn=1, ImmSrc=000, ALUSrc=1, ResultSrc=001, Branch=0, ALUOp=00, Jump=0, JumpR=0

            // STORE  - S-type
            7'b0100011: controls = 13'b0_001_1_xxx_0_00_0_0;
            // RegWriteEn=0, ImmSrc=001, ALUSrc=1, ResultSrc=xxx (don't care for stores), Branch=0, ALUOp=00, Jump=0, JumpR=0

            // R-TYPE ARITHMETIC
            7'b0110011: controls = 13'b1_xxx_0_000_0_10_0_0;
            // RegWriteEn=1, ImmSrc=xxx, ALUSrc=0, ResultSrc=000, Branch=0, ALUOp=10, Jump=0, JumpR=0

            // BRANCH - B-type
            7'b1100011: controls = 13'b0_010_0_xxx_1_01_0_0;
            // RegWriteEn=0, ImmSrc=010, ALUSrc=0, ResultSrc=xxx (don't care), Branch=1, ALUOp=01, Jump=0, JumpR=0

            // I-TYPE ARITHMETIC (addi, slti, etc.)
            7'b0010011: controls = 13'b1_000_1_000_0_10_0_0;
            // RegWriteEn=1, ImmSrc=000, ALUSrc=1, ResultSrc=000, Branch=0, ALUOp=10, Jump=0, JumpR=0

            // JUMP AND LINK (jal) - J-type
            7'b1101111: controls = 13'b1_011_x_010_0_00_1_0;
            // RegWriteEn=1, ImmSrc=011, ALUSrc=x, ResultSrc=010 (PC+4), Branch=0, ALUOp=00, Jump=1, JumpR=0

            // LUI (Load Upper Immediate) - U-type
            7'b0110111: controls = 13'b1_100_x_011_0_00_0_0;
            // RegWriteEn=1, ImmSrc=100, ALUSrc=x (ALU bypassed), ResultSrc=011 (Immediate), Branch=0, ALUOp=00, Jump=0, JumpR=0

            // AUIPC (add upper immediate to PC) - U-type
            7'b0010111: controls = 13'b1_100_x_100_0_00_0_0;
            // RegWriteEn=1, ImmSrc=100, ALUSrc=x (ALU bypassed), ResultSrc=100 (PC+Immediate), Branch=0, ALUOp=00, Jump=0, JumpR=0

            // JUMP AND LINK REGISTER (jalr) - I-type
            7'b1100111: controls = 13'b1_011_1_010_0_00_1_1;
            // RegWriteEn=1, ImmSrc=011, ALUSrc=1, ResultSrc=010 (PC+4), Branch=0, ALUOp=00, Jump=0, JumpR=1

            // reset - Ensure all control signals are well-defined at reset
            // Defaulting to a safe state, typically NOP behavior or halted.
            7'b0000000: controls = 13'b0_000_0_000_0_00_0_0; // NOP-like state (no write, no branch, no jump etc.)
            
            // DEFAULT CASE - Unimplemented instructions
            default: controls = 13'bx_xxx_x_xxx_x_xx_x_x;
            // All outputs undefined for unsupported opcodes (for synthesis, ensure no latches are inferred)
        endcase
endmodule
