`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2025 06:04:45 PM
// Design Name: 
// Module Name: mux2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 2-to-1 Multiplexer (Data Selector)
//              Parameterized width multiplexer that selects between two inputs
//              based on a single control signal
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This is a fundamental building block used extensively in processor datapaths
// for routing data between different sources based on control signals
//////////////////////////////////////////////////////////////////////////////////

module mux2 #(
    parameter WIDTH = 8         // Parameterized data width - default 8 bits
                               // Can be instantiated with any desired width
                               // e.g., mux2 #(32) for 32-bit data paths
)(
    input logic [WIDTH-1:0] d0, // Data input 0 - selected when s = 0
    input logic [WIDTH-1:0] d1, // Data input 1 - selected when s = 1
    input logic s,              // Select signal (control input)
                               // 0: output = d0
                               // 1: output = d1
    output logic [WIDTH-1:0] y  // Output - selected input data
);
    
    // Combinational multiplexer logic using conditional operator
    // This is the most concise and readable way to implement a 2:1 mux
    // The conditional operator (? :) works as: condition ? true_value : false_value
    assign y = s ? d1 : d0;

 
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Usage Examples in RISC-V Processor:
//
// ALU source selection (register vs immediate):
// mux2 #(32) alu_src_mux(.d0(rs2), .d1(immediate), .s(ALUSrc), .y(alu_b));
//
// Result source selection (ALU vs memory):
// mux2 #(32) result_mux(.d0(alu_result), .d1(mem_data), .s(ResultSrc[0]), .y(result));
//
// PC source selection (PC+4 vs branch target):
// mux2 #(32) pc_mux(.d0(pc_plus4), .d1(pc_target), .s(PCSrc), .y(pc_next));
//
// Register file write data (result vs PC+4 for JAL):
// mux2 #(32) wd_mux(.d0(result), .d1(pc_plus4), .s(Jump), .y(write_data));
//
// Single-bit control signal selection:
// mux2 #(1) ctrl_mux(.d0(1'b0), .d1(BranchTaken), .s(Branch), .y(pc_src));
//////////////////////////////////////////////////////////////////////////////////