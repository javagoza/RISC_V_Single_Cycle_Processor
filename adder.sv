`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Simple 32-bit Binary Adder
//              Performs unsigned/signed addition of two 32-bit operands
//              Used for address calculations and PC increment operations
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This is a combinational logic module - output changes immediately when inputs change
// Synthesis tools will implement this as an optimized carry-propagate adder
//////////////////////////////////////////////////////////////////////////////////

module adder(
    input logic [31:0] a,       // First 32-bit operand (addend)
    input logic [31:0] b,       // Second 32-bit operand (addend)  
    output logic [31:0] r       // 32-bit sum result (a + b)
                               // Note: Overflow beyond 32 bits is discarded
                               // Carry-out is not provided in this simple implementation
);
    
    // Combinational addition operation
    // The '+' operator performs binary addition with the following characteristics:
    // - Handles both signed and unsigned interpretation automatically
    // - Result width matches the wider operand (32 bits in this case)
    // - Overflow wraps around (modulo 2^32 arithmetic)
    // - Synthesis tools optimize this into efficient hardware adders
    assign r = a + b;
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Usage Examples in RISC-V Processor:
//
// PC increment adder:
// adder pc_plus4(.a(pc), .b(32'd4), .r(pc_next));
//
// Branch target calculation:
// adder branch_target(.a(pc), .b(branch_offset), .r(branch_addr));
//
// Load/Store address calculation:
// adder addr_calc(.a(rs1_data), .b(immediate), .r(mem_addr));
//
// General arithmetic (though ALU typically handles this):
// adder alu_add(.a(operand1), .b(operand2), .r(add_result));
//////////////////////////////////////////////////////////////////////////////////