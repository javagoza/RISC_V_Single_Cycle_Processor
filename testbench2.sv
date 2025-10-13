`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/15/2025 05:02:52 PM
// Design Name:
// Module Name: testbench
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies: top // Make sure 'top' is in your dependencies
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Updated to match new 'top' module interface.
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module testbench2 
// #(parameter string MEM_PROGRAM_FILE = "riscvtest2.mem")
#(parameter string MEM_PROGRAM_FILE = "assembled_code.mem")
();
    logic clk;
    logic reset;
    // These wires will connect to the debug outputs of the 'top' module
    logic [31:0] tb_WriteData;
    logic [31:0] tb_DataAdr;
    logic tb_MemWrite;
    

    // instantiate device to be tested
    // Connect testbench wires to the 'debug_' outputs of the top module
    top #(.MEM_PROGRAM_FILE(MEM_PROGRAM_FILE)) dut(
        .clk(clk),
        .reset(reset),
        .debug_WriteData(tb_WriteData), // Connect to the new debug output
        .debug_DataAdr(tb_DataAdr),     // Connect to the new debug output
        .debug_MemWrite(tb_MemWrite)    // Connect to the new debug output
    );

    // initialize test
    initial begin
        reset <= 1; #22; reset <= 0;
    end

    // generate clock to sequence tests
    always begin
        clk <= 1; #5; clk <= 0; #5; // 10ns clock period
    end

    // check results
    // Use the testbench wires for assertions
    always @(negedge clk) begin
        // Check if MemWrite (tb_MemWrite) is active
        if(tb_MemWrite) begin
            $display("Time %0t: Memory Write Detected! Addr = 0x%h, Data = 0x%h",
                      $time, tb_DataAdr, tb_WriteData);

            // Assuming a test case where you expect a store to address 216 with data 4140
            if(tb_DataAdr === 32'd216 && tb_WriteData === 32'd4140) begin
                $display("Simulation SUCCEEDED: Store to 216 with 4140 detected!");
                $stop;
            end
            // This condition was previously problematic if DataAdr was often not 96 during valid writes.
            // Consider what specific store operations you are testing.
            // If you want to check for *any* other address not being 96 after a write to 100, this is fine.
            // But if other valid stores happen, it will "fail".
            // It's better to check for specific expected behavior, or log all unexpected writes.
            else if (tb_DataAdr !== 32'd96) begin // Example condition - refine based on your test program
                $display("Simulation FAILED: Unexpected write to address 0x%h with data 0x%h. Expected 0x64 (100) and 0x19 (25) or a specific flow.",
                          tb_DataAdr, tb_WriteData);
                // $stop; // Maybe remove this if you want to see other writes
            end
        end
        // Add more checks for other instruction types, e.g., register file values
        // To check register values, you'd need to expose them from datapath up to top,
        // or add an assertion within the testbench if your test program writes to a specific register.
    end

    // Optional: Timeout to end simulation if it runs too long without hitting a $stop
    initial begin
        #5000; // 5000ns timeout
        $display("Simulation TIMEOUT: Did not reach expected condition.");
        $stop;
    end

endmodule

