`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: javagoza
// 
// Create Date: 06/01/2025 07:47:28 PM
// Design Name: 
// Module Name: imem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: RISC-V Instruction Memory Module
//              Read-only memory containing program instructions.
//              Supports word-aligned access with 32-bit instruction fetch.
//              Memory size: 64 words (256 bytes) addressable from 0x000 to 0x0FC
// 
// Dependencies: riscvtest.mem - Memory initialization file containing hex values
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - Memory is initialized from external hex file at simulation start
// - Assumes little-endian byte ordering for multi-byte instructions
// - Address space: 0x00000000 to 0x000003FC (1024 × 4-byte words)
//////////////////////////////////////////////////////////////////////////////////

module imem #(
    parameter string MEM_PROGRAM_FILE = "riscvtest2.mem",
    parameter CAPACITY = 1024 // words x 32 bits
)(
    input logic [31:0] a,          // Byte address from PC (Program Counter)
    output logic [31:0] rd         // 32-bit instruction data output
    );
    
    // Instruction memory array: 1024 words × 32 bits each
    // Total capacity: 1024 bytes (0x400 bytes)
    // Each entry stores one 32-bit RISC-V instruction
    logic [31:0] RAM [CAPACITY -1 :0];
    
    // Initialize memory contents from hex file at simulation start
    // File format: Each line contains 8 hex digits representing one 32-bit word
    // Example file content:
    //   00000013  // NOP instruction (addi x0, x0, 0)
    //   00100093  // addi x1, x0, 1
    //   ...
    initial begin
        $readmemh(MEM_PROGRAM_FILE, RAM); 
    end
    
    // Word-aligned memory access logic
    // RISC-V instructions are 4-byte aligned, so addresses are multiples of 4
    // Input address 'a' is a byte address (e.g., 0x00, 0x04, 0x08, ...)
    // Convert byte address to word index by dropping 2 LSBs (divide by 4)
    //
    // Address mapping examples:
    // Byte Address | Word Index | Memory Location
    // -------------|------------|----------------
    // 0x00000000   |     0      | RAM[0]
    // 0x00000004   |     1      | RAM[1] 
    // 0x00000008   |     2      | RAM[2]
    // 0x000000FC   |    63      | RAM[63]
    //
    // Note: Bits [1:0] of address are ignored (assumed to be 00 for word alignment)
    assign rd = RAM[a[31:2]];
    
endmodule