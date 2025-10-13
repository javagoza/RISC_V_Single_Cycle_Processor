`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/25/2025 02:44:45 PM
// Design Name: ALU for RISC-V 32I
// Module Name: alu2 // Changed from alu2 to alu for consistency if main module name is alu
// Project Name: Single Cycle RISC-V Processor
// Target Devices: FPGA, ASIC
// Tool Versions: Vivado, Quartus, etc.
// Description:
//   This module implements a 32-bit Arithmetic Logic Unit (ALU)
//   for a single-cycle RISC-V RV32I architecture. It supports
//   common arithmetic and logical operations, as well as shift
//   operations and flag generation for branching.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   The 'alucontrol' input has been expanded to 4 bits to accommodate
//   the signed right arithmetic shift (SRA) operation.
//   'flags' output added to support conditional branches (e.g., BLT).
//   SLT result corrected to be 32-bit.
//
//////////////////////////////////////////////////////////////////////////////////


module alu (
    input logic [31:0] a,           // First operand
    input logic [31:0] b,           // Second operand
    input logic [3:0]  alucontrol,  // 4-bit control signal for ALU operation
    output logic [31:0] result,     // 32-bit result of the ALU operation
    output logic [3:0] flags        // Flags: {Overflow (V), Carry Out (C), Negative (N), Zero (Z)}
);

    // Internal wires for intermediate calculations
    logic [31:0] condinvb; // Conditional inversion of operand 'b' for subtraction
    logic [31:0] sum;      // Result of addition/subtraction (a + b) or (a - b)

    // Individual flag signals
    logic v;    // Overflow flag (signed arithmetic)
    logic c;    // Carry Out flag (unsigned arithmetic)
    logic n;    // Negative flag (MSB of result)
    logic z;    // Zero flag (result is all zeros)
    logic cout; // Carry out from the internal adder/subtractor

    // Control signal to identify add/subtract operations for precise flag generation
    // This will be true if alucontrol is 4'b0000 (ADD) or 4'b0001 (SUB).
    logic isAddSub;

    // Assign the individual flags to the 'flags' output bundle
    assign flags = {v, c, n, z};

    // Conditional inversion of operand 'b' for subtraction:
    // If alucontrol[0] is 1 (indicating subtraction, e.g., 4'b0001), 'b' is bitwise inverted (~b).
    // Otherwise (for addition, e.g., 4'b0000), 'b' remains unchanged.
    // This is part of the 2's complement subtraction (a - b = a + (~b + 1)).
    assign condinvb = alucontrol[0] ? ~b : b;

    // 32-bit adder/subtractor:
    // Calculates (a + condinvb + carry_in).
    // If alucontrol[0] is 1, it acts as a carry-in of 1 for subtraction (a + ~b + 1).
    // If alucontrol[0] is 0, it acts as a carry-in of 0 for addition (a + b + 0).
    assign {cout, sum} = a + condinvb + alucontrol[0];

    // Determine if the current operation is either ADD or SUB.
    // This is used to gate the Carry and Overflow flag generation, as they are
    // only meaningful for these arithmetic operations.
    assign isAddSub = (alucontrol == 4'b0000) || (alucontrol == 4'b0001);

    // Combinational logic for ALU operations based on 'alucontrol' input
    always_comb begin
        case (alucontrol)
            4'b0000: result = sum;                         // ADD: Result from the adder/subtractor (a + b)
            4'b0001: result = sum;                         // SUB: Result from the adder/subtractor (a - b)
            4'b0010: result = a & b;                       // AND: Bitwise AND operation
            4'b0011: result = a | b;                       // OR: Bitwise OR operation
            4'b0100: result = a ^ b;                       // XOR: Bitwise XOR operation
            4'b0101: result = sum[31] ^ v;                 // SLT (Set Less Than - Signed):
                                                           // Result is 1 if (a < b) signed, otherwise 0.
                                                           // The logic (sum[31] XOR v) correctly determines signed less than.
                                                           // Zero-extend this 1-bit result to 32 bits.
            4'b0110: result = a << b[4:0];                 // SLL (Shift Left Logical): Shifts 'a' left by b[4:0] bits, fills with zeros.
                                                           // Only the lower 5 bits of 'b' are used for shift amount (0 to 31).
            4'b0111: result = a >> b[4:0];                 // SRL (Shift Right Logical): Shifts 'a' right by b[4:0] bits, fills with zeros.
            4'b1000: result = $signed(a) >>> b[4:0];       // SRA (Shift Right Arithmetic): Shifts 'a' right by b[4:0] bits,
                                                           // propagates the sign bit (MSB of 'a'). Uses $signed cast for correct behavior.
            4'b1001: result = {31'b0, ~cout};              // SLTU (Set Less Than Unsigned)
                                                           // Derived from 'cout' (carry_out from a + ~b + 1)
                                                           // For unsigned: a < b if (a - b) results in no carry.
                                                           // This means `a <_u b` is true if `~cout` is true after `a + ~b + 1`.

            default: result = 32'bx;                       // Default case for undefined ALU control, outputs 'X' (unknown).
        endcase
    end

    // Flag generation for conditional branches and other status information

    // Zero Flag (Z): Set if the 'result' of the ALU operation is all zeros.
    assign z = (result == 32'b0);

    // Negative Flag (N): Set if the most significant bit (MSB) of the 'result' is 1.
    // This indicates a negative signed result.
    assign n = result[31];

    // Carry Out Flag (C):
    // For addition: 'cout' is the carry out from the MSB.
    // For subtraction: 'cout' represents 'borrow not' from the MSB.
    // This flag is relevant only for `isAddSub` operations in this context.
    // It's crucial for unsigned comparisons (BLTU/BGEU).
    assign c = cout & isAddSub;

    // Overflow Flag (V):
    // Detects signed overflow for addition and subtraction.
    // The expression for overflow (V) is derived from the signs of operands (a[31], b[31])
    // and the sign of the result (sum[31]).
    // (a[31] ^ b[31]) is 0 for operands of the same sign, 1 for different signs.
    // alucontrol[0] is 0 for ADD, 1 for SUB.
    //
    // Overflow occurs for ADD if: (a[31] == b[31]) AND (a[31] != sum[31])
    // Overflow occurs for SUB if: (a[31] != b[31]) AND (a[31] != sum[31])
    //
    // This can be concisely written as:
    // (operand signs are the 'same' for ADD, 'different' for SUB) AND (result sign differs from first operand sign)
    // The `~ (alucontrol[0] ^ a[31] ^ b[31])` part checks the first condition.
    // The `(a[31] ^ sum[31])` part checks the second condition.
    assign v = (~ (alucontrol[0] ^ a[31] ^ b[31])) & (a[31] ^ sum[31]) & isAddSub;

endmodule