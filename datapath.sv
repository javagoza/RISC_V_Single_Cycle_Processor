`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 06/14/2025 05:59:58 PM
// Design Name: RISC-V Single-Cycle Processor Datapath
// Module Name: datapath
// Project Name: Single-Cycle RISC-V Processor
// Target Devices: FPGA, ASIC
// Tool Versions: Vivado, Quartus, etc.
// Description: RISC-V Single-Cycle Processor Datapath
//              Implements the data flow and computation paths for a basic
//              RISC-V processor supporting RV32I base instruction set.
//              Includes PC logic, register file, ALU, and result selection.
//
// Dependencies: flopr, adder, mux2, mux5, regfile, extend, alu, loaddata
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - Single-cycle implementation (one instruction per clock cycle)
// - Supports R-type, I-type, S-type, B-type, U-type and J-type instructions
// - Control signals provided by external control unit
// - ALU updated to provide full flag set {V,C,N,Z} for branch unit.
//
//////////////////////////////////////////////////////////////////////////////////

module datapath (
    // Clock and Reset
    input logic clk,             // System clock
    input logic reset,           // Synchronous reset (active high)

    // Control Inputs from Control Unit
    input logic [2:0] ResultSrc, // Result source select (000=ALU, 001=Memory,
                                 // 010=PC+4, 011=Immediate Extender, 100=PC+Immediate)
    input logic [1:0] PCSrc,     // PC source select (00=PC+4, 01=PC+Imm for branches/jumps, 10=PC+rs+Imm)
    input logic ALUSrc,          // ALU operand B select (0=rs2, 1=immediate)
    input logic RegWriteEn,      // Register file write enable
    input logic [2:0] ImmSrc,    // Immediate format select (I/S/B/J-type/U-Type)
    input logic [3:0] ALUControl, // ALU operation control (CHANGED TO 4 BITS as per ALU module)
    input logic [1:0] MemSize, // Memory access size (00=Byte, 01=Half, 10=Word) from controller (LSU)
    input logic SignedLoad,    // For loads: 1=Signed, 0=Unsigned from controller (LSU)

    // Memory Interface
    input logic [31:0] Instr,    // Current instruction from instruction memory
    input logic [31:0] ReadData,   // Data read from memory (load operations)


    // Status Outputs to Control Unit (NOW BUNDLED)
    output logic [3:0] ALUFlags, // ALU flags: {Overflow (V), Carry Out (C), Negative (N), Zero (Z)}
    output logic [31:0] PC,      // Program Counter (instruction address)
    output logic [31:0] ALUResult, // ALU result (memory address for load/store)
    output logic [31:0] WriteData // Data to write to memory (store operations) - This is rs2 from regfile
);

    // Internal Datapath Signals
    logic [31:0] PCNext;          // Next PC value (PC+4 or branch target)
    logic [31:0] PCPlus4;         // PC + 4 (sequential instruction address)
    logic [31:0] PCTarget;        // Branch/jump target address (PC + immediate)
    logic [31:0] ImmExt;          // Sign-extended immediate value
    logic [31:0] SrcA;            // ALU operand A (always rs1 data)
    logic [31:0] SrcB;            // ALU operand B (rs2 data or immediate)
    logic [31:0] RegWriteData;    // Final data to write back to the register file

    // --- WIRES FOR LOAD/STORE DATA PROCESSING ---
    logic [31:0] LoadDataProcessed; // Final processed data for all load types
    logic [31:0] rs2;          // Raw data from rs2 register (input to storedata module)

   
    //=========================================================================
    // PROGRAM COUNTER (PC) LOGIC
    //=========================================================================

    // PC register - stores current instruction address
    // Updates on each clock cycle with next PC value
    flopr #(32) pcreg (
        .clk(clk),
        .reset(reset),
        .d(PCNext),              // Input: next PC value
        .q(PC)                   // Output: current PC value
    );

    // Calculate PC+4 for sequential instruction execution
    // All RISC-V instructions are 4 bytes, so increment PC by 4
    adder pcadd4 (
        .a(PC),                  // Current PC
        .b(32'd4),               // Constant 4
        .r(PCPlus4)              // Result: PC+4
    );

    // Calculate branch/jump target address
    // Target = PC + sign-extended immediate offset
    // Used for: BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR
    adder pcaddbranch (
        .a(PC),                  // Current PC (base address)
        .b(ImmExt),              // Sign-extended immediate offset
        .r(PCTarget)             // Result: branch/jump target
    );

    // Select next PC value
    // Normal execution: PCNext = PC+4
    // Branch taken or jump: PCNext = PCTarget
    mux3 #(32) pcmux (
        .d0(PCPlus4),            // Sequential next instruction
        .d1(PCTarget),           // Branch/jump target
        .d2(ALUResult),          // jarl target
        .s(PCSrc),               // Control: 0=sequential, 1=branch/jump
        .y(PCNext)               // Selected next PC
    );

    //=========================================================================
    // REGISTER FILE LOGIC
    //=========================================================================

    // 32-entry register file (x0-x31)
    // Two read ports (rs1, rs2) and one write port (rd)
    regfile rf (
        .clk(clk),
        .we3(RegWriteEn),        // Write enable from control unit
        .a1(Instr[19:15]),       // rs1 address (source register 1)
        .a2(Instr[24:20]),       // rs2 address (source register 2)
        .a3(Instr[11:7]),        // rd address (destination register)
        .wd3(RegWriteData),     // Write data (result to store in rd)
        .rd1(SrcA),              // Read data 1 (rs1 contents)
        .rd2(rs2)                // Connect to internal wire for raw rs2 data 
    );

    // Immediate extension unit
    // Extracts and sign-extends immediate values from different instruction formats
    extend ext (
        .instr(Instr[31:7]),     // Instruction bits containing immediate
        .immsrc(ImmSrc),         // Format select (I/S/B/J-type/U-type)
        .immext(ImmExt)          // 32-bit sign-extended immediate
    );

    //=========================================================================
    // ALU (ARITHMETIC LOGIC UNIT) LOGIC
    //=========================================================================

    // ALU source B multiplexer
    // Selects second ALU operand: register data (R-type) or immediate (I-type)
    // R-type instructions: ADD, SUB, AND, OR, XOR, SLT, SLL, SRL, SRA use rs2 data
    // I-type instructions: ADDI, ANDI, ORI, XORI, SLTI, SLLI, SRLI, SRAI use immediate
    mux2 #(32) srcbmux (
        .d0(rs2),               // rs2 data (for R-type instructions like R-type arithmetic, shifts)
        .d1(ImmExt),             // Sign-extended immediate (for I-type arithmetic, loads)
        .s(ALUSrc),              // Control: 0=register, 1=immediate
        .y(SrcB)                 // Selected ALU operand B
    );

    // Main ALU - performs arithmetic and logical operations
    // **CHANGED**: alu module now outputs a bundled 'flags' instead of just 'zero'.
    alu alu_inst ( // Renamed to alu_inst to avoid name collision with module name
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl), // Now a 4-bit signal from controller
        .result(ALUResult),      // ALU computation result (e.g., memory address for loads/stores)
        .flags(ALUFlags)        // Connects the new 4-bit flags output from ALU to the datapath output
    );
    
    //=========================================================================
    // MEMORY DATA PROCESSING FOR LOAD INSTRUCTIONS
    //=========================================================================
    // Extracts and sign/zero-extends bytes/halfwords from ReadData.
    loaddata ld (
        .Mem   (ReadData),        // Raw 32-bit data from dmem
        .MemLsbs(ALUResult[1:0]), // Lower 2 bits of the effective address
        .MemSize (MemSize), // From controller (LSU)
        .SignedLoad  (SignedLoad),  // From controller (LSU)
        .OutputData  (LoadDataProcessed) // Output to resultmux for write-back
    );

    //=========================================================================
    // MEMORY DATA PROCESSING FOR STORE INSTRUCTIONS
    //=========================================================================
    // Performs read-modify-write for SB and SH, or passes data for SW.
    storedata sd (
        .Mem       (ReadData),         // Raw 32-bit data from dmem (for modification)
        .rs2       (rs2),         // Data from rs2 register (value to store)
        .MemLsbs   (ALUResult[1:0]),   // Lower 2 bits of the effective address
        .MemSize   (MemSize),  // From controller (LSU)
        .OutputData(WriteData)         // Final 32-bit data to write to dmem.wd
    );

    //=========================================================================
    // RESULT SELECTION LOGIC
    //=========================================================================

    // Write-back data multiplexer
    // Selects data to write back to destination register (rd)
    // 000: ALU result (R-type, I-type arithmetic/logical)
    // 001: Data processed from memory (load instructions: LB, LH, LW, LBU, LHU)
    // 010: PC+4 (jump instructions: JAL, JALR - return address)
    // 011: ImmExt (for LUI, AUIPC)
    // 100: PCTarget (for JALR with special immediate/base reg, though typically handled by PC+4 + Imm)
    // Note: The meaning of ImmExt and PCTarget here depends on how your ResultSrc is defined for LUI/AUIPC/JALR
    mux5 #(32) resultmux (
        .d0(ALUResult),          // ALU computation result (e.g., for R-type, I-type arithmetic)
        .d1(LoadDataProcessed),  // Data loaded from memory (after byte/halfword processing)
        .d2(PCPlus4),            // Return address (PC+4) for JAL
        .d3(ImmExt),             // Immediate Extender output (for LUI, AUIPC potentially)
        .d4(PCTarget),           // PC + immediate (for JALR return address if desired, or PC target)
        .s(ResultSrc),           // Result source select from control unit
        .y(RegWriteData)         // Selected write-back data to the register file
    );

endmodule