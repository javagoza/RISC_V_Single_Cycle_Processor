`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: javagoza
// 
// Create Date: 06/01/2025 07:31:21 PM
// Description: RISC-V 32-Register File Implementation
//  Three-ported register file following RISC-V ISA specification:
//  - Two combinational read ports (A1/RD1, A2/RD2) for source operands
//  - One synchronous write port (A3/WD3/WE3) for destination register
//  - Register x0 hardwired to constant zero (RISC-V requirement)
//  - 32 registers total: x0 (hardwired 0) + x1-x31 (general purpose)
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This implements the architectural register file as specified in RISC-V ISA
// Register x0 always reads as 0 and writes to x0 are ignored
//////////////////////////////////////////////////////////////////////////////////

module regfile(
    input logic clk,                // Clock input - writes occur on positive edge
    input logic we3,                // Write enable for port 3 (active high)
                                   // When 0: no write occurs regardless of other inputs
                                   // When 1: write wd3 to register a3 on clock edge
    
    // Register addresses (5 bits each for 32 registers: 0-31)
    input logic [4:0] a1,          // Read port 1 address (rs1 in instruction)
    input logic [4:0] a2,          // Read port 2 address (rs2 in instruction)  
    input logic [4:0] a3,          // Write port address (rd in instruction)
    
    // Data ports
    input logic [31:0] wd3,        // Write data - value to store in register a3
    output logic [31:0] rd1,       // Read data 1 - contents of register a1
    output logic [31:0] rd2        // Read data 2 - contents of register a2
);
    
    // Register file storage - only 31 physical registers needed
    // Register 0 is hardwired to 0, so we only implement registers 1-31
    // Array indexing: rf[1] = x1, rf[2] = x2, ..., rf[31] = x31
    logic [31:0] rf[31:1];
    
    // Synchronous write logic - executes on positive clock edge
    always_ff @(posedge clk) begin
        // Write condition: write enable asserted AND not writing to x0
        // RISC-V specification: writes to x0 must be ignored
        if (we3 && a3 > 0) begin
            rf[a3] <= wd3;         // Store write data into addressed register
        end
        // Note: No write occurs if we3=0 or a3=0 (attempting to write x0)
    end
    
    // Combinational read logic - outputs change immediately with address changes
    // RISC-V x0 register behavior: always reads as zero
    assign rd1 = (a1 == 0) ? 32'b0 : rf[a1];  // Read port 1: x0 ? 0, others ? rf[a1]
    assign rd2 = (a2 == 0) ? 32'b0 : rf[a2];  // Read port 2: x0 ? 0, others ? rf[a2]
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
// RISC-V Register File Architecture Notes:
//
// Register Naming Convention:
// x0  = zero (hardwired constant 0)
// x1  = ra   (return address)
// x2  = sp   (stack pointer)
// x3  = gp   (global pointer)
// x4  = tp   (thread pointer)
// x5-x7, x28-x31 = temporaries
// x8  = fp/s0 (frame pointer/saved register)
// x9, x18-x27 = saved registers
// x10-x17 = function arguments/return values
//
// Usage in Processor Pipeline:
// - Read ports (rd1, rd2) provide source operands to ALU/functional units
// - Write port (wd3) receives results from ALU, memory, or PC+4
// - Addresses come from instruction fields: rs1?a1, rs2?a2, rd?a3
// - Write enable (we3) controlled by instruction decode (RegWrite signal)
//
// Key RISC-V Compliance Features:
// 1. x0 always reads as 0 (hardware enforced)
// 2. Writes to x0 are discarded (hardware enforced)
// 3. Dual read ports support two source operands simultaneously
// 4. Single write port with enable control
//////////////////////////////////////////////////////////////////////////////////