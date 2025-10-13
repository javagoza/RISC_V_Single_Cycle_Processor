`timescale 1ns / 1ps
// riscv_test_assembler.sv




//////////////////////////////////////////////////////////////////////////////////
// Company:   Your Company
// Engineer:  Your Name
//
// Create Date: 2025/07/26 22:31:50
// Design Name: riscv_test_assembler
// Module Name: riscv_test_assembler
// Project Name: RISC-V Assembler Test
// Target Devices:
// Tool Versions:
// Description: Top-level SystemVerilog module to demonstrate the RISC-V assembler
//              tasks provided in 'riscv_assembly.sv'.
//
// Dependencies: riscv_assembly.sv
//
// Revision:
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////

`define BENCH2 0

module riscv_test_assembler();
   
    // Declare the memory array that will hold the assembled instructions.
    // The size (e.g., 256 words) can be adjusted based on your code's needs.
    logic [31:0] MEM [0:255]; // 256 words of 32-bit memory
    
    // Declare the program counter for the assembler.
    // This variable tracks the current assembly address.
    int memPC;

    `define BENCH 0
    //`define GET_ASM_LABELS 0
    `include "riscv_assembly.sv"


    // Include the SystemVerilog assembler tasks and functions.
    // The content of 'riscv_assembly.sv' will be textually inserted here.



    // Declare and *initialize* integer variables for labels.
    // Initializing them to 0 (or 'hx) prevents "not declared" errors.
    // The 'Label' task will then report the correct values during the first run.
    
    int loop_start_label = 32;   // Placeholder initial value
    int branch_target = 56;      // Placeholder initial value
    int dummy_function_target = 60; // Placeholder initial value

    initial begin
        // Initialize the program counter to 0 (start assembling from address 0)
        memPC = 0;

        // --- Start Assembling RISC-V Instructions ---

        // Example 1: Basic Arithmetic and Immediate
        ADDI(x1, x0, 10);        // x1 = 0 + 10
        ADDI(x2, x0, 20);        // x2 = 0 + 20
        ADD(x3, x1, x2);         // x3 = x1 + x2 (10 + 20 = 30)

        // Example 2: Load Immediate (LI pseudo-instruction)
        LI(x4, 32'hFEEDFACE);    // x4 = 0xFEEDFACE (uses LUI and ADDI)
        LI(x5, 123);             // x5 = 123 (small immediate, uses only ADDI)
        LI(x6, 0);               // x6 = 0 (uses ADD x0,x0,x0)

        // Example 3: Branching and Labels
        // A simple loop that counts down from x7 to 0
        LI(x7, 10); // Initialize x7 to 10
        Label(loop_start_label); // Define a label at the current memPC
        $info("--- Loop Start Label (loop_start_label = %0d) ---", loop_start_label);
        ADDI(x7, x7, -1);       // x7 = x7 - 1
        BNEZ(x7, LabelRef(loop_start_label)); // If x7 != 0, branch back to loop_start_label

        // Example 4: Jump and Call/Return
        LI(a0, 50); // Argument for a dummy function
        CALL(dummy_function_target); // Call a dummy function
        NOP(); // Instruction after return

        Label(branch_target); // Another label example
        ADDI(x10, x10, 1);

        // Dummy function (defined inline for demonstration)
        Label(dummy_function_target); // Define the dummy_function_target here
        ADD(a1, a0, a0); // a1 = a0 * 2
        RET(); // Return to caller (uses JALR x0,x1,0)


        // Example 5: Store and Load
        SW(x3, sp, 0); // Store x3 to memory at address sp + 0
        LW(x8, sp, 0); // Load value back into x8 from memory at address sp + 0 (x8 should be 30)

        // Terminate assembly with EBREAK
        EBREAK();

        // Call the endASM task for final checks and simulation termination
        endASM();

        // --- Display Assembled Memory Contents ---
        $info("--- Assembled Memory Contents (memPC = %0d) ---", memPC);
        for (int i = 0; i < memPC / 4; i = i + 1) begin
            $info("MEM[%0d] (0x%0h): %h", i, i * 4, MEM[i]);
        end
        $info("---------------------------------------------");

        // Optional: You might want to dump memory to a file for external use
        $writememh("assembled_code.mem", MEM);

        $finish; // End simulation after assembly
    end

endmodule