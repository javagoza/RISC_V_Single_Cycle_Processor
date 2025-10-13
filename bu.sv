`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: javagoza
// 
// Create Date: 07/25/2025 03:03:51 PM
// Design Name: Branch Unit (BU)
// Module Name: bu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  Branch Unit (BU)
//  This module determines if a conditional branch instruction should be taken
//  based on the CPU's flags (Zero, Negative, Carry, Overflow) and the
//  'funct3' field of the branch instruction. It supports BEQ, BNE, BLT, BGE, BLTU, and BGEU.

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bu (
    input logic Branch,       // Control signal indicating if the current instruction is a branch
    input logic [3:0] Flags,  // Input flags from the ALU: {V, C, N, Z}
    input logic [2:0] funct3, // funct3 field from the branch instruction
    output logic BranchTaken  // Output: 1 if the branch condition is met and Branch is asserted, 0 otherwise
);

    // Decompose the 4-bit 'Flags' input into individual flag signals
    logic v; // Overflow flag
    logic c; // Carry Out flag
    logic n; // Negative flag
    logic z; // Zero flag

    // Internal signal to indicate if the branch condition itself is met
    logic cond;

    // Assign individual flags from the bundled 'Flags' input
    assign {v, c, n, z} = Flags;

    // The branch is 'taken' only if the instruction is a 'Branch' instruction
    // AND the specific branch 'cond'ition is met.
    assign BranchTaken = cond & Branch;

    // Combinational logic to evaluate the branch condition based on 'funct3'
    always_comb begin
        case (funct3)
            3'b000: cond = z;        // BEQ (Branch if Equal): Taken if Zero flag is set (result was zero)
            3'b001: cond = ~z;       // BNE (Branch if Not Equal): Taken if Zero flag is NOT set (result was non-zero)
            3'b100: cond = (n ^ v);  // BLT (Branch if Less Than - Signed):
                                     // Taken if (N XOR V) is 1. This correctly checks for signed less than:
                                     //  - If no overflow (V=0), then result is negative (N=1) implies a < b. (1 ^ 0 = 1)
                                     //  - If overflow (V=1) AND result is positive (N=0), then actual value was negative (a < b). (0 ^ 1 = 1)
                                     //  - Otherwise, not less than.
            3'b101: cond = ~(n ^ v); // BGE (Branch if Greater Than or Equal - Signed):
                                     // Taken if NOT (N XOR V) is 1. This is the inverse of BLT.
            3'b110: cond = ~c;       // BLTU (Branch if Less Than Unsigned):
                                     // Taken if Carry flag is NOT set.
                                     // For unsigned comparison (a < b), after (a - b), if no carry-out,
                                     // it means a < b (or a = b if z=1, but for < only, it's ~c and ~z).
                                     // RISC-V convention typically uses `~c` for BLTU based on `a < b` being `(unsigned)a - (unsigned)b` and no carry.
            3'b111: cond = c;        // BGEU (Branch if Greater Than or Equal Unsigned):
                                     // Taken if Carry flag is set.
                                     // For unsigned comparison (a >= b), after (a - b), if there is a carry-out,
                                     // it means a >= b.
            default: cond = 1'b0;    // Default case for undefined funct3 values, branch not taken.
        endcase
    end

endmodule
