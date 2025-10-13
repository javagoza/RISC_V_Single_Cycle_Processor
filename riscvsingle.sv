`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 06/01/2025 08:01:12 PM
// Design Name: RISC-V Single-Cycle Processor
// Module Name: riscvsingle
// Project Name: Single-Cycle RISC-V Processor
// Target Devices: FPGA
// Tool Versions: Vivado
// Description: Processor module for a single-cycle RISC-V processor.
//              Instantiates the datapath, controller
//              connecting all control and data signals.
//
// Dependencies: datapath, controller, imem, dmem
//
// Revision:
// Additional Comments:
// - Single-cycle implementation for RV32I base instruction set.
// - Assumes imem and dmem modules are defined elsewhere.
//////////////////////////////////////////////////////////////////////////////////

module riscvsingle (
    input logic clk,
    input logic reset,
    output logic [31:0] PC,
    input logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input logic [31:0] ReadData,
    output logic MemWriteEn 
);
    // Signals from Datapath to Controller
    logic [3:0] ALUFlags;      // ALU flags for branch evaluation

    // Signals from Controller to Datapath
    logic [2:0] ResultSrc;      // Result source for register write-back
    logic [1:0] PCSrc;          // PC source for next instruction address
    logic       ALUSrc;         // ALU operand B source
    logic       RegWriteEn;     // Register file write enable
    logic [2:0] ImmSrc;         // Immediate format select
    logic [3:0] ALUControl;     // ALU operation control
    logic [1:0] MemSize;        // Memory access size (from LSU)
    logic       SignedLoad;     // Signed/unsigned flag for loads (from LSU)

    // Signals between Datapath and Memories
    logic [31:0] PC;            // Program Counter output (instruction address)
    logic [31:0] Instr;         // Instruction read from IMEM
    logic [31:0] ALUResult;     // ALU result (memory address for loads/stores)
    logic [31:0] WriteData;     // Data to write to DMEM (processed by storedata)
    logic [31:0] ReadData;      // Data read from DMEM

    // Instruction Decode Inputs for Controller (from Instr)
    logic [6:0] op;             // Opcode field (Instr[6:0])
    logic [2:0] funct3;         // Funct3 field (Instr[14:12])
    logic       funct7b5;       // Funct7 bit 5 (Instr[30])

    //=========================================================================
    // INSTANTIATION OF CORE COMPONENTS
    //=========================================================================

    // Extract instruction fields for the controller
    assign op       = Instr[6:0];
    assign funct3   = Instr[14:12];
    assign funct7b5 = Instr[30]; // For R-type SUB/SRA distinction


    // 3. Controller Unit
    // Generates control signals for the datapath based on instruction fields and ALU flags
    controller u_controller (
        .op             (op),
        .funct3         (funct3),
        .funct7b5       (funct7b5),
        .ALUFlags      (ALUFlags),
        .ResultSrc      (ResultSrc),
        .PCSrc          (PCSrc),
        .ALUSrc         (ALUSrc),
        .RegWriteEn     (RegWriteEn),
        .ImmSrc         (ImmSrc),
        .ALUControl     (ALUControl),
        .MemWriteEn   (MemWriteEn),
        .MemSize(MemSize),
        .SignedLoad (SignedLoad)
    );


    // 4. Datapath Unit
    // Executes instructions based on control signals and performs data transfers
    datapath u_datapath (
        .clk            (clk),
        .reset          (reset),
        .ResultSrc      (ResultSrc),
        .PCSrc          (PCSrc),
        .ALUSrc         (ALUSrc),
        .RegWriteEn     (RegWriteEn),
        .ImmSrc         (ImmSrc),
        .ALUControl     (ALUControl),
        .MemSize(MemSize),
        .SignedLoad (SignedLoad),
        .ALUFlags      (ALUFlags), // Output to controller for branch logic
        .PC             (PC),        // PC output to IMEM
        .Instr          (Instr),     // Instruction input from IMEM
        .ALUResult      (ALUResult), // ALU result output to DMEM (address)
        .WriteData      (WriteData), // Write data output to DMEM
        .ReadData       (ReadData)   // Read data input from DMEM
    );

endmodule
