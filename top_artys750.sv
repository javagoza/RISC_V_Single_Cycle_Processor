`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/22/2025 04:42:20 PM
// Design Name:
// Module Name: top_artys750
// Project Name: RISC-V Single-Cycle Processor System for Arty S7-50
// Target Devices: Xilinx Spartan-7
// Tool Versions: Vivado
// Description: Top-level wrapper for the RISC-V processor system
//              Connects the internal 'top' module to FPGA pins and manages clocking.
//
// Dependencies: top (RISC-V system main module)
//
// Revision:
// Revision 0.01 - File Created (Original by user)
// Revision 0.02 - Corrected port declarations to be external outputs for monitoring.
//                 Used named port connections for clarity.
// Revision 0.03 - Removed WriteData_out, DataAdr_out, and MemWrite_out as external I/O ports.
//                 They are now internal signals for observation within this module.
//////////////////////////////////////////////////////////////////////////////////

module top_artys750(
    input logic CLK100MHZ,   // Board's 100 MHz crystal oscillator input pin   
        // External Output for LEDs (to make the design non-empty for synthesis)
    // Connecting a small part of your internal state to external pins.
    output logic [9:0] led, // Example output to drive 4 LEDs for status/debugging
    input logic [3:0] btn 
);


    logic sys_reset;     // Synchronized reset for the RISC-V system
    logic [31:0] counter;
    
    assign led[0] = counter[24];

   

    
   always_ff @(posedge CLK100MHZ) begin
        if ( btn[0]) begin // If MMCM not locked OR reset button pressed
            counter <= 32'b0; 
        end else begin
            counter <= counter + 1; // Deassert system reset
        end
    end

    // Internal signals for monitoring purposes
    // These signals are connected from the 'top' module and can be observed
    // within this 'top_artys750' module for debugging, but are not exposed
    // directly as FPGA pins.
    logic [31:0] WriteData_internal; // Data written to memory by processor
    logic [31:0] DataAdr_internal;   // Address accessed by processor data memory
    logic MemWrite_internal;         // Data memory write enable from processor

    // Instantiate the main processor system module (the 'top' module from before)
    // Connects the external inputs of top_artys750 to the ports of the 'top' module.
    // The previously external outputs are now connected to internal signals.
    top riscv_system_inst (
        .clk(counter[24]),      // Connect top_artys750's clock input to top's 100MHz clock input
        .reset(btn[0]),  // Connect top_artys750's reset input to top's reset button input

        .debug_WriteData(WriteData_internal),  // Connect top's WriteData output to internal signal
        .debug_DataAdr(DataAdr_internal),      // Connect top's DataAdr output to internal signal
        .debug_MemWrite(MemWrite_internal)     // Connect top's MemWrite output to internal signal
    );

    // If you need to observe these signals on physical pins (e.g., LEDs)
    // you would need to assign them to new output ports declared here,
    // and then connect those new ports to physical pins in your XDC.
    // For example:
    // output logic [3:0] LED_WriteData;
    // assign LED_WriteData = WriteData_internal[3:0]; // connect lower 4 bits to LEDs
    // Assign internal signals to external output port(s) for observation.
    // This makes the design "non-empty" for the synthesis tools.
    assign led[9:1] = WriteData_internal[8:0]; // Connect lower 4 bits of WriteData to LEDs
endmodule
