`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: javagoza
// 
// Create Date: 06/01/2025 08:01:12 PM
// Design Name: 
// Module Name: dmem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: RISC-V Data Memory Module
//              Synchronous read/write memory for load/store operations.
//              Supports word-aligned access with 32-bit data transfers.
//              Memory size: 256 words (1024 bytes) addressable from 0x000 to 0x3FC
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - Synchronous write on positive clock edge when write enable is asserted
// - Asynchronous read (combinational output)
// - No initialization - memory contents are undefined at startup
// - Used for RISC-V load/store instructions (LW, SW)
//////////////////////////////////////////////////////////////////////////////////

module dmem #(
    parameter CAPACITY = 1024 // bytes, 256 words x 32 bits
    )(
    input logic clk,               // Clock signal for synchronous write operations
    input logic we,                // Write enable (1 = write, 0 = read-only)
    input logic [31:0] a,          // Byte address for memory access
    input logic [31:0] wd,         // Write data (data to be stored)
    output logic [31:0] rd         // Read data (data retrieved from memory)
    );
    
    // Data memory array: 256 words × 32 bits each
    // Total capacity: 1024 bytes (0x400 bytes)
    // Each entry stores one 32-bit data word
    // Note: Memory contents are uninitialized (random values at startup)
    logic [31:0] RAM [CAPACITY - 1 :0];
    
    // Synchronous write logic - triggered on positive clock edge
    // Write occurs only when write enable (we) is asserted
    // Used by RISC-V store instructions (SW - Store Word)
    always_ff @(posedge clk) begin
        if (we) begin
            // Convert byte address to word index and store data
            RAM[a[31:2]] <= wd;
        end
    end
    
    // Asynchronous read logic - combinational output
    // Word-aligned memory access for RISC-V load/store operations
    // Input address 'a' is a byte address from ALU result
    // Convert byte address to word index by dropping 2 LSBs (divide by 4)
    //
    // Address mapping examples:
    // Byte Address | Word Index | Memory Location | Usage
    // -------------|------------|-----------------|-------
    // 0x00000000   |     0      | RAM[0]          | Stack base
    // 0x00000004   |     1      | RAM[1]          | Local variables
    // 0x00000008   |     2      | RAM[2]          | Arrays/structs
    // 0x000000FC   |    255     | RAM[1020]       | Stack top
    //
    // RISC-V load/store instructions that use this module:
    // - LW (Load Word): reads 32-bit value from memory to register
    // - SW (Store Word): writes 32-bit value from register to memory
    //
    // Note: Read operation is asynchronous (no clock dependency)
    // Data is available immediately after address changes
    assign rd = RAM[a[31:2]];
    
endmodule