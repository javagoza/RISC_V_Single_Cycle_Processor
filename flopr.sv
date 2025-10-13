`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2025 08:08:22 PM
// Design Name: 
// Module Name: flopr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Resettable Flip-Flop - Parameterized width D flip-flop with 
//              asynchronous active-high reset capability
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This is a fundamental building block used throughout digital designs
// for state storage, pipeline registers, and sequential logic elements
//////////////////////////////////////////////////////////////////////////////////

module flopr #(
    parameter WIDTH = 8         // Parameterized width - default 8 bits
                               // Can be instantiated with any desired width
                               // e.g., flopr #(32) for 32-bit register
)(
    input logic clk,                    // Clock input - triggers on positive edge
    input logic reset,                  // Asynchronous reset - active high
                                       // When asserted, immediately sets output to 0
                                       // regardless of clock state
    input logic [WIDTH-1:0] d,         // Data input - value to be stored on next clock edge
    output logic [WIDTH-1:0] q         // Data output - current stored value
);
    
    // Asynchronous reset, synchronous load flip-flop implementation
    // Uses both clock and reset in sensitivity list for proper async reset behavior
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            // Asynchronous reset: immediately clear output regardless of clock
            // This happens as soon as reset goes high, not waiting for clock edge
            q <= {WIDTH{1'b0}};         // Clear all bits to 0 (more explicit than just 0)
        end else begin
            // Synchronous operation: on positive clock edge, load new data
            // This only occurs when reset is not asserted
            q <= d;                     // Transfer input to output on clock edge
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Usage Examples:
//
// 8-bit register (default):
// flopr reg8(.clk(clk), .reset(rst), .d(data_in), .q(data_out));
//
// 32-bit program counter:
// flopr #(32) pc(.clk(clk), .reset(rst), .d(pc_next), .q(pc_current));
//
// 1-bit state register:
// flopr #(1) state_reg(.clk(clk), .reset(rst), .d(next_state), .q(current_state));
//////////////////////////////////////////////////////////////////////////////////