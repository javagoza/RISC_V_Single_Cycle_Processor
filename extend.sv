`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/01/2025 08:39:03 PM
// Design Name: RISC-V Immediate Extension Unit
// Module Name: extend
// Project Name: Single-Cycle RISC-V Processor
// Target Devices: FPGA, ASIC
// Tool Versions: Vivado, Quartus, etc.
// Description: This module handles immediate value extraction and sign extension
//              for various RISC-V instruction formats (I, S, B, J, U-type).
//              It converts the instruction's immediate fields into a 32-bit
//              sign-extended value suitable for ALU operations or PC updates.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created (Initial version)
// Revision 0.02 - Corrected B-type and J-type immediate parsing based on
//                 RV32I specification (which later proved to be functionally
//                 equivalent to the more compact initial forms).
// Revision 0.03 - Expanded immsrc to 3 bits and added U-type immediate handling.
//                 Confirmed correctness of B-type and J-type compact forms.
// Additional Comments:
// - All signed immediates (I, S, B, J) are sign-extended from their MSB.
// - Branch (B-type) and Jump (J-type) immediates implicitly have their LSB (bit 0)
//   as '0' because they are PC-relative and 2-byte aligned.
// - U-type immediate (LUI, AUIPC) is zero-extended in its lower 12 bits,
//   as its value is already located in the upper 20 bits of the 32-bit immediate.
//////////////////////////////////////////////////////////////////////////////////

module extend(
    input logic [31:7] instr,    // Instruction bits relevant for immediate extraction (excluding opcode and rd/rs1)
    input logic [2:0] immsrc,     // Immediate source selector (determines instruction format: 000=I, 001=S, 010=B, 011=J, 100=U)
    output logic [31:0] immext    // 32-bit sign-extended or zero-padded immediate value
);

    // Combinational logic to extract and extend immediate values based on the immsrc control signal.
    always_comb begin
        case(immsrc)
            // I-type immediate (e.g., ADDI, LW, JALR)
            // Format: imm[11:0] = instr[31:20]
            // Sign-extend 12-bit immediate (instr[31] is the sign bit) to 32 bits.
            // Needs 20 bits of sign extension (32 - 12 = 20).
            3'b000: immext = {{20{instr[31]}}, instr[31:20]};

            // S-type immediate (stores: SW, SH, SB)
            // Format: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            // Reconstruct the 12-bit immediate and sign-extend.
            // Needs 20 bits of sign extension (32 - 12 = 20).
            3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type immediate (branches: BEQ, BNE, BLT, BGE, etc.)
            // Format: imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25], imm[4:1]=instr[11:8], imm[0]=0
            // Reconstruct the 13-bit immediate (including implicit 0) and sign-extend.
            // Needs 19 bits of sign extension (32 - 13 = 19).
            // The {{20{instr[31]}}} cleverly handles both sign extension and placing instr[31] at immext[12].
            3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

            // J-type immediate (JAL)
            // Format: imm[20]=instr[31], imm[19:12]=instr[19:12], imm[11]=instr[20], imm[10:1]=instr[30:21], imm[0]=0
            // Reconstruct the 21-bit immediate (including implicit 0) and sign-extend.
            // Needs 11 bits of sign extension (32 - 21 = 11).
            // The {{12{instr[31]}}} cleverly handles both sign extension and placing instr[31] at immext[20].
            3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

            // U-type immediate (LUI, AUIPC)
            // Format: imm[31:12]=instr[31:12], imm[11:0]=0
            // Direct placement of 20-bit immediate in upper bits, lower 12 bits are zero.
            // No sign extension needed as it's effectively a 32-bit value.
            3'b100: immext = {instr[31:12], 12'b0};

            // Default case for any unrecognized immsrc value (should not occur with correct control logic)
            default: immext = 32'bx; // Drive unknown state for debugging
        endcase
    end
endmodule