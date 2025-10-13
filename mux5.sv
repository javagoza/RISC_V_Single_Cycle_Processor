`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/14/2025 06:05:37 PM
// Design Name:
// Module Name: mux5
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Parameterized 5-to-1 Multiplexer
//              Selects one of five input data sources based on a 3-bit select signal.
//              Commonly used in processor datapaths for operand selection,
//              result forwarding, and control path multiplexing.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created 
// Additional Comments:
// - Default WIDTH parameter of 8 bits can be overridden during instantiation
// - Select encoding: 000 -> d0, 001 -> d1, 010 -> d2, 011 -> d3, , 100 -> d4
//////////////////////////////////////////////////////////////////////////////////

module mux5 #(parameter WIDTH = 8) ( 
    input logic [WIDTH-1:0] d0,    // Data input 0 (selected when s = 2'b000)
    input logic [WIDTH-1:0] d1,    // Data input 1 (selected when s = 2'b001)
    input logic [WIDTH-1:0] d2,    // Data input 2 (selected when s = 2'b010)
    input logic [WIDTH-1:0] d3,    // Data input 3 (selected when s = 2'b011) 
    input logic [WIDTH-1:0] d4,    // Data input 4 (selected when s = 2'b100)
    input logic [2:0] s,           // 3-bit select signal (for 5 inputs)
    output logic [WIDTH-1:0] y     // Output - selected input data
    );

    // 5-to-1 multiplexer using nested conditional assignment
    // Truth table:
    // s[2] s[1] s[0] | y
    // ---+----+----
    //  0    0    0   | d0
    //  0    0    1   | d1
    //  0    1    0   | d2
    //  0    1    1   | d3
    //  1    0    0   | d4
    
    always_comb begin
        case(s)
            3'b000: y = d0;
            3'b001: y = d1;
            3'b010: y = d2;
            3'b011: y = d3;
            3'b100: y = d4;
            default: y = 'x; // Handle undefined selects, or d0 for synthesis safety
        endcase
    end

endmodule