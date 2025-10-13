`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/07/26
// Design Name:
// Module Name: storedata
// Project Name: Single-Cycle RISC-V Processor
// Target Devices:
// Tool Versions:
// Description: Module to process data for store operations (SB, SH, SW).
//              Performs read-modify-write for byte and half-word stores.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

module storedata (
    input logic [31:0] Mem,      // Raw 32-bit data read from memory (from dmem.rd)
    input logic [31:0] rs2,        // Data from rs2 register (what we want to store)
    input logic [1:0]  MemLsbs,   // Lower 2 bits of the effective memory address (from ALUResult[1:0])
    input logic [1:0]  MemSize,    // 00=Byte, 01=Half, 10=Word (from LSU)
    output logic [31:0] OutputData // The 32-bit word to write to dmem.wd
);

    always_comb begin
        OutputData = rs2; // Default: pass rs2 directly (for SW or non-store ops)

        case (MemSize)
            2'b00: begin // SB (Store Byte)
                // The lower two bits of MemLsbs determine the byte offset
                case (MemLsbs)
                    2'b00: OutputData = {Mem[31:8], rs2[7:0]};
                    2'b01: OutputData = {Mem[31:16], rs2[7:0], Mem[7:0]};
                    2'b10: OutputData = {Mem[31:24], rs2[7:0], Mem[15:0]};
                    2'b11: OutputData = {rs2[7:0], Mem[23:0]};
                    default: OutputData = '0; // Should not happen
                endcase
            end
            2'b01: begin // SH (Store Half-word)
                // The address[1] bit determines the half-word offset
                // Note: RISC-V SH requires address[0] to be 0 (half-word aligned)
                case (MemLsbs[1]) // Only bit 1 matters for half-word alignment
                    1'b0: OutputData = {Mem[31:16], rs2[15:0]}; // Lower half (address[1:0] is 00)
                    1'b1: OutputData = {rs2[15:0], Mem[15:0]}; // Upper half (address[1:0] is 10)
                    default: OutputData = '0; // Should not happen
                endcase
            end
            2'b10: begin // SW (Store Word)
                // No modification needed, just pass the raw rs2
                OutputData = rs2;
            end
            default: OutputData = '0; // Unrecognized size or non-store operation (should be handled by MemWrite outside)
        endcase
    end

endmodule