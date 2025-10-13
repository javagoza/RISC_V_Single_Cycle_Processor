`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/14/2025
// Design Name:
// Module Name: loaddata
// Project Name: Single-Cycle RISC-V Processor
// Target Devices:
// Tool Versions:
// Description: Module to process data for load operations (LB, LH, LW, LBU, LHU).
//              Extracts and sign/zero-extends bytes/half-words.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module loaddata (
    input logic [31:0] Mem,      // Raw 32-bit data from memory (from dmem.rd)
    input logic [1:0]  MemLsbs,   // Lower 2 bits of the effective address (from ALUResult[1:0])
    input logic [1:0]  MemSize,    // 00=Byte, 01=Half, 10=Word (from LSU)
    input logic        SignedLoad,     // 1=Signed (LB, LH), 0=Unsigned (LBU, LHU) or Word (LW) (from LSU)
    output logic [31:0] OutputData     // Extracted and extended data for write-back
);

    // Internal wires for extracted data
    logic [7:0]  extracted_byte;
    logic [15:0] extracted_halfword;

    always_comb begin
        extracted_byte   = '0; // Default
        extracted_halfword = '0; // Default
        OutputData   = '0; // Default

        // Extract byte/halfword based on address LSBs
        case (MemLsbs)
            2'b00: begin // Word aligned or byte 0
                extracted_byte   = Mem[7:0];
                extracted_halfword = Mem[15:0];
            end
            2'b01: begin // Byte 1
                extracted_byte   = Mem[15:8];
                // Half-word is not aligned for extraction here,
                // as LH/LHU would typically align to 0xX..X0 or 0xX..X2
            end
            2'b10: begin // Half-word aligned or byte 2
                extracted_byte   = Mem[23:16];
                extracted_halfword = Mem[31:16];
            end
            2'b11: begin // Byte 3
                extracted_byte   = Mem[31:24];
                // Half-word is not aligned
            end
        endcase

        // Perform final processing based on access size and signed/unsigned
        case (MemSize)
            2'b00: begin // Byte access (LB, LBU)
                if (SignedLoad) begin // LB
                    OutputData = {{24{extracted_byte[7]}}, extracted_byte}; // Sign-extend
                end else begin // LBU
                    OutputData = {24'b0, extracted_byte}; // Zero-extend
                end
            end
            2'b01: begin // Half-word access (LH, LHU)
                if (SignedLoad) begin // LH
                    OutputData = {{16{extracted_halfword[15]}}, extracted_halfword}; // Sign-extend
                end else begin // LHU
                    OutputData = {16'b0, extracted_halfword}; // Zero-extend
                end
            end
            2'b10: begin // Word access (LW)
                OutputData = Mem; // No extraction/extension needed
            end
            default: OutputData = '0; // Should not happen for valid load instruction
        endcase
    end

endmodule

//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 07/24/2025 09:48:38 PM
//// Design Name: 
//// Module Name: loaddata
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


//// loaddata.sv
//// This module extracts and extends the correct data (byte, halfword, word)
//// from the raw 32-bit memory read data based on the load instruction type (funct3)
//// and the byte/halfword offset within the word.

//module loaddata(
//    input logic [31:0] Mem,    // Raw 32-bit word read from Data Memory
//    input logic [1:0]  MemLsbs, // Lower 2 bits of the effective memory address (ALUResult[1:0])
//    input logic [2:0]  funct3,           // funct3 field from the instruction register

//    output logic [31:0] OutputData    // The final 32-bit data to write to the register file
//);

//    always_comb begin
//        OutputData = Mem; // Default to unknown for safety (should be covered by case)

//        case (funct3)
//            // LB: Load Byte, sign-extended (funct3 = 3'b000)
//            3'b000: begin
//                case (MemLsbs) // Select the byte based on address offset
//                    2'b00: OutputData = {{24{Mem[7]}}, Mem[7:0]};   // Byte 0 (lowest byte)
//                    2'b01: OutputData = {{24{Mem[15]}}, Mem[15:8]}; // Byte 1
//                    2'b10: OutputData = {{24{Mem[23]}}, Mem[23:16]}; // Byte 2
//                    2'b11: OutputData = {{24{Mem[31]}}, Mem[31:24]}; // Byte 3 (highest byte)
//                endcase
//            end

//            // LH: Load Halfword, sign-extended (funct3 = 3'b001)
//            3'b001: begin
//                // Select the halfword based on address bit 1 (halfwords are 2-byte aligned)
//                case (MemLsbs[1])
//                    1'b0: OutputData = {{16{Mem[15]}}, Mem[15:0]}; // Halfword 0 (bits 15:0)
//                    1'b1: OutputData = {{16{Mem[31]}}, Mem[31:16]}; // Halfword 1 (bits 31:16)
//                endcase
//            end

//            // LW: Load Word (funct3 = 3'b010)
//            // No extension or extraction needed; just pass the raw 32-bit data
//            3'b010: OutputData = Mem;

//            // LBU: Load Byte Unsigned, zero-extended (funct3 = 3'b100)
//            3'b100: begin
//                case (MemLsbs)
//                    2'b00: OutputData = {24'b0, Mem[7:0]};   // Zero-extend byte 0
//                    2'b01: OutputData = {24'b0, Mem[15:8]}; // Zero-extend byte 1
//                    2'b10: OutputData = {24'b0, Mem[23:16]}; // Zero-extend byte 2
//                    2'b11: OutputData = {24'b0, Mem[31:24]}; // Zero-extend byte 3
//                endcase
//            end

//            // LHU: Load Halfword Unsigned, zero-extended (funct3 = 3'b101)
//            3'b101: begin
//                case (MemLsbs[1])
//                    1'b0: OutputData = {16'b0, Mem[15:0]}; // Zero-extend halfword 0
//                    1'b1: OutputData = {16'b0, Mem[31:16]}; // Zero-extend halfword 1
//                endcase
//            end

//            // Default case: for unsupported funct3 or non-load instructions, output unknown.
//            // This case should ideally not be reached if the maindec correctly asserts ResultSrc=001 only for valid load instructions.
//            default: OutputData = Mem;
//        endcase
//    end
//endmodule
