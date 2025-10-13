`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 06/14/2025 06:09:59 PM
// Design Name: RISC-V Single-Cycle Processor Control Unit
// Module Name: controller
// Project Name: Single-Cycle RISC-V Processor
// Target Devices: FPGA
// Tool Versions: Vivado
// Description: RISC-V Single-Cycle Processor Control Unit
//              Decodes instruction opcodes and function fields to generate
//              control signals for the datapath. Implements a hierarchical
//              control structure with main decoder and ALU decoder.
//
// Dependencies:
//   - maindec (main decoder)
//   - aludec (ALU decoder)
//   - bu (Branch Unit - for conditional branch evaluation)
//   - lsu (Load Store Unit - for load and store size evaluation)
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - Supports RV32I base instruction set (
// - Two-level decode: main decoder for instruction type, ALU decoder for operations
// - Uses a dedicated Branch Unit (bu) module for all conditional branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
// - Uses a dedicated Load Store Unit (lsu) module for all store/loads (LB, LH, LW, LBU, LHU, SB, SH, SW)
//////////////////////////////////////////////////////////////////////////////////

module controller (
    // Instruction Decode Inputs
    input logic [6:0] op,            // Opcode field (instr[6:0]) - determines instruction type
    input logic [2:0] funct3,        // Function 3 field (instr[14:12]) - operation variant
    input logic funct7b5,            // Function 7 bit 5 (instr[30]) - ADD/SUB, SRA/SRL distinction
    input logic [3:0] ALUFlags,     // Input flags from the ALU: {V, C, N, Z}
    
    // Datapath Control Outputs
    output logic [2:0] ResultSrc,    // Write-back source select (ALU/Memory/PC+4/Immediate/PC+Immediate)
    output logic [1:0] PCSrc,              // PC source select (sequential/branch target/jump target)
    output logic ALUSrc,             // ALU operand B source (register/immediate)
    output logic RegWriteEn,         // Register file write enable
    output logic [2:0] ImmSrc,       // Immediate format select (I/S/B/J-type/U-type)
    output logic [3:0] ALUControl,   // ALU operation control
    output logic       MemWriteEn,   // To datapath (dmem.we): derived from LSU and Store
    output logic [1:0] MemSize,      // To datapath (loaddata/storedata): 00=Byte, 01=Half, 10=Word
    output logic       SignedLoad    // To datapath (loaddata): 1=Signed, 0=Unsigned
);

    logic       Load;   //  indicates if current instruction is a LOAD
    logic       Store;  // indicates if current instruction is a STORE
    
    // Internal Control Signals
    logic [1:0] ALUOp;   // ALU operation class from main decoder
    logic Branch;        // Branch instruction indicator (BEQ, BNE, BLT, etc.)
    logic BranchTaken;   // Output from the Branch Unit: 1 if branch condition is met
    logic Jump;          // Jump instruction indicator (JAL)
    logic JumpR;         // Jump instruction indicator (JALR)

    //=========================================================================
    // MAIN INSTRUCTION DECODER
    //=========================================================================

    // Primary instruction decoder - determines instruction class and basic control signals
    maindec md (
        .op(op),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegWriteEn(RegWriteEn),
        .Jump(Jump),
        .JumpR(JumpR),
        .ImmSrc(ImmSrc),
        .ALUOp(ALUOp)
    );

    // Determine if it's a load or store instruction based on opcode
    assign Load  = (op == 7'b0000011); // Load instructions (LB, LH, LW, LBU, LHU)
    assign Store = (op == 7'b0100011); // Store instructions (SB, SH, SW)


    //=========================================================================
    // ALU OPERATION DECODER
    //=========================================================================

    // Secondary decoder for ALU operations - refines ALU control based on function fields
    aludec ad (
        .opb5(op[5]),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    //=========================================================================
    // BRANCH UNIT INSTANTIATION
    //=========================================================================

    // The Branch Unit evaluates the ALU flags and funct3 to determine if a
    // conditional branch instruction should be taken.
    bu u_bu (
        .Branch(Branch),         // Input: Is the current instruction a branch? (from maindec)
        .Flags(ALUFlags),       // Input: ALU flags {V, C, N, Z}
        .funct3(funct3),         // Input: funct3 field to identify branch type
        .BranchTaken(BranchTaken)     // Output: Is the branch condition met?
    );

    //=========================================================================
    // LOAD/STORE UNIT (LSU) INSTANTIATION
    // Determines specific memory access properties (size, signedness)
    //=========================================================================
    lsu u_lsu (
        .funct3(funct3),
        .Load(Load),
        .Store(Store),
        .MemWriteEn(MemWriteEn),
        .MemSize(MemSize),
        .SignedLoad(SignedLoad)
    );

    //=========================================================================
    // PC SOURCE SELECTION LOGIC
    //=========================================================================

    // PC source selection logic - determines when to take branches or jumps
    assign PCSrc = {JumpR, (Branch & BranchTaken) | Jump};

endmodule
