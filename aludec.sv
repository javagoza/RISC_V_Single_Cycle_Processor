`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 06/02/2025 09:27:45 PM
// Design Name: ALU Control Decoder for RISC-V processor
// Module Name: aludec
// Project Name: Single-Cycle RISC-V Processor
// Target Devices: FPGA,
// Tool Versions: Vivado
// Description:
//   This module generates the final 4-bit ALU control signal based on:
//   - ALUOp from the main decoder (identifies instruction type: R-type, I-type)
//   - funct3 field from the instruction
//   - funct7b5 (instruction[30]) for specific variations (e.g., SUB vs ADD, SRA vs SRL)
//   Supports all RV32I arithmetic, logical, and shift operations.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   ALUControl encoding:
//   0000: ADD
//   0001: SUB
//   0010: AND
//   0011: OR
//   0100: XOR
//   0101: SLT (Set Less Than - Signed)
//   0110: SLL (Shift Left Logical)
//   0111: SRL (Shift Right Logical)
//   1000: SRA (Shift Right Arithmetic)
//   1001: SLTU (Set Less Than Unsigned)
//////////////////////////////////////////////////////////////////////////////////

module aludec (
    input logic       opb5,     // opcode[5] - (often used for specific shift type distinctions, or not used depending on ALUOp decode strategy)
    input logic [2:0] funct3,   // funct3 field from instruction
    input logic       funct7b5, // funct7[5] from instruction (determines SUB for R-type, SRA for shifts)
    input logic [1:0] ALUOp,    // 2-bit ALU operation type from maindec
                                // 00: ADD (for Load/Store addr, LUI/AUIPC pass-through)
                                // 01: SUB (for Branch comparisons, BEQ/BNE/BLT/BGE/BLTU/BGEU)
                                // 10: R-type/I-type decode (arithmetic/logical/shifts)

    output logic [3:0] ALUControl // 4-bit control signal for the ALU
);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5; // TRUE for R-type subtract instruction

    always_comb begin
        ALUControl = 4'bXXXX; // Default to unknown (X) for safety

        case (ALUOp)
            2'b00: begin // ADD operation (for Loads/Stores address calculation, LUI/AUIPC implicitly use ADD)
                ALUControl = 4'b0000; // ALU performs ADD
            end
            2'b01: begin // SUB operation (for Branches where ALU computes rs1 - rs2)
                ALUControl = 4'b0001; // ALU performs SUB
            end
            2'b10: begin // R-type and I-type (arithmetic, logical, shifts) - further decode using funct3 and funct7b5
                case (funct3)
                    3'b000: if (RtypeSub)
                            ALUControl = 4'b0001; // sub
                    else
                             ALUControl = 4'b0000; // add, addi
                    3'b001: ALUControl = 4'b0110; // SLL / SLLI (Shift Left Logical)
                    3'b010: ALUControl = 4'b0101; // SLT / SLTI (Set Less Than - Signed)
                    3'b011: ALUControl = 4'b1001; // SLTU / SLTUI (Set Less Than Unsigned) 
                    3'b100: ALUControl = 4'b0100; // XOR / XORI 
                    3'b101: begin // SRL / SRLI (Shift Right Logical) or SRA / SRAI (Shift Right Arithmetic)
                        if (funct7b5) // funct7b5 = 1 indicates SRA (e.g., op=0110011/0010011, funct3=101, funct7=0100000)
                            ALUControl = 4'b1000; // SRA
                        else
                            ALUControl = 4'b0111; // SRL
                    end
                    3'b110: ALUControl = 4'b0011; // OR / ORI 
                    3'b111: ALUControl = 4'b0010; // AND / ANDI
                    default: ALUControl = 4'bXXXX; // Unrecognized funct3 for R/I-type operations
                endcase
            end
            default: ALUControl = 4'bXXXX; // Unrecognized ALUOp from maindec
        endcase
    end
endmodule