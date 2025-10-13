`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: javagoza
//
// Create Date: 06/14/2025 06:46:02 PM
// Design Name: RISC-V Single-Cycle Processor Top Wrapper
// Module Name: top
// Project Name: Single-Cycle RISC-V Processor
// Target Devices: FPGA
// Tool Versions: Vivado
// Description: Top-level module to instantiate the RISC-V single-cycle processor
//              and connect it to the instruction and data memories.
//
// Dependencies: riscvsingle, imem, dmem
//
// Revision:
//
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module top #(
    parameter string MEM_PROGRAM_FILE = "riscvtest2.mem",
    parameter RAM_CAPACITY = 256)
(
    input logic clk,
    input logic reset,
   
    output logic [31:0] debug_WriteData, 
    output logic [31:0] debug_DataAdr,  
    output logic debug_MemWrite          
);

    // Internal wires (as defined before)
    logic [31:0] PC;
    logic [31:0] Instr;
    logic [31:0] ALUResult;     
    logic [31:0] WriteData; 
    logic [31:0] ReadData;
    logic        MemWriteEn;  

    // Instantiate riscvsingle (use internal wire names for its connections)
    riscvsingle u_riscvsingle (
        .clk          (clk),
        .reset        (reset),
        .PC           (PC),
        .Instr        (Instr),
        .ALUResult    (ALUResult),
        .WriteData    (WriteData), 
        .ReadData     (ReadData),
        .MemWriteEn (MemWriteEn)
    );

    // Instantiate imem
    imem #(.MEM_PROGRAM_FILE(MEM_PROGRAM_FILE)) u_imem (
        .a     (PC),
        .rd    (Instr)
    );

    // Instantiate dmem
    dmem #(.CAPACITY(RAM_CAPACITY)) u_dmem (
        .clk (clk),
        .we  (MemWriteEn),
        .a   (ALUResult),
        .wd  (WriteData), 
        .rd  (ReadData)
    );

    // Connect internal signals to debug outputs of the top module
    assign debug_WriteData = WriteData;
    assign debug_DataAdr   = ALUResult;
    assign debug_MemWrite  = MemWriteEn;

endmodule