`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: javagoza
//
// Create Date: 06/01/2025 08:01:12 PM
// Design Name: Load Store Unit
// Module Name: lsu
// Project Name:
// Target Devices:
// Tool Versions:
// Description: RISC-V Load/Store Unit (LSU)
//              Decodes funct3 for memory access type and size.
//
// Dependencies: None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - Provides control signals for the data memory module (dmem)
// - Differentiates between byte, half-word, and word accesses
// - Assumes the main control unit (or instruction decoder)
//////////////////////////////////////////////////////////////////////////////////

module lsu (
    input logic [2:0] funct3,
    input logic       Load,       // High if instruction is any load type (LW, LH, LB, LHU, LBU)
    input logic       Store,      // High if instruction is any store type (SW, SH, SB)
    output logic      MemWriteEn, // Enable for memory write (this is 'we' for dmem)
    output logic [1:0] MemSize,   // 00=Byte, 01=Half, 10=Word (for both load and store)
    output logic      SignedLoad  // For loads: 1=Signed (LB, LH), 0=Unsigned (LBU, LHU) or Word (LW)
);

    // Initialize outputs to default/safe values
    always_comb begin
        MemWriteEn = 1'b0;
        MemSize = 2'b10; // Default to word
        SignedLoad = 1'b0;

        // Load instructions
        if (Load) begin
            case (funct3)
                3'b000: begin // LB (Load Byte)
                    MemSize = 2'b00; // Byte access
                    SignedLoad = 1'b1;  // Signed
                end
                3'b001: begin // LH (Load Half-word)
                    MemSize = 2'b01; // Half-word access
                    SignedLoad = 1'b1;  // Signed
                end
                3'b010: begin // LW (Load Word)
                    MemSize = 2'b10; // Word access
                    SignedLoad = 1'b1;  // Word loads are typically treated as signed
                end
                3'b100: begin // LBU (Load Byte Unsigned)
                    MemSize = 2'b00; // Byte access
                    SignedLoad = 1'b0;  // Unsigned
                end
                3'b101: begin // LHU (Load Half-word Unsigned)
                    MemSize = 2'b01; // Half-word access
                    SignedLoad = 1'b0;  // Unsigned
                end
                default: begin
                    // Handle invalid funct3 for load opcode (e.g., error, NOP, or don't care)
                    // For now, it will keep default values (no read, byte size, unsigned)
                end
            endcase
        end
        // Store instructions
        else if (Store) begin
            MemWriteEn = 1'b1; // All stores enable memory write
            case (funct3)
                3'b000: begin // SB (Store Byte)
                    MemSize = 2'b00; // Byte access
                end
                3'b001: begin // SH (Store Half-word)
                    MemSize = 2'b01; // Half-word access
                end
                3'b010: begin // SW (Store Word)
                    MemSize = 2'b10; // Word access
                end
                default: begin
                    // Handle invalid funct3 for store opcode (e.g., error, NOP, or don't care)
                    // For now, it will keep default values (no write, byte size)
                end
            endcase
        end
    end

endmodule