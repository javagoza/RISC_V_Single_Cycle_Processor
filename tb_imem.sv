`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/15/2025 05:19:20 PM
// Design Name: 
// Module Name: tb_imem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_imem;

    // --- Testbench Signals ---
    logic clk;           // Clock signal
    logic reset;         // Reset signal
    logic [31:0] test_a; // Address to drive to imem
    logic [31:0] test_rd; // Data read from imem
    
    logic [31:0] simulated_DataAdr;
    logic [31:0] simulated_WriteData;

    // --- Instantiate the Unit Under Test (UUT) ---
    imem uut (
        .a  (test_a),
        .rd (test_rd)
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with a 10ns period (5ns high, 5ns low)
    end

    // --- Test Scenario ---
    initial begin
        // Initialize inputs
        reset = 1;      // Assert reset
        test_a = '0;    // Set initial address to 0

        #10; // Wait a bit for reset to settle

        reset = 0; // Deassert reset
        $display("--------------------------------------------------");
        $display("Starting IMEM Testbench");
        $display("--------------------------------------------------");

        // Test specific instruction fetches based on your riscvtest.mem
        // Remember that 'a' is a byte address, and imem uses a[31:2] for word addressing.

        // Fetch instruction at address 0x00
        test_a = 32'h0000_0000;
        #10; // Wait for combinational logic to propagate
        $display("Time: %0t, Address: 0x%h, Data Read: 0x%h (Expected: 0x00500113)", $time, test_a, test_rd);
        if (test_rd !== 32'h00500113) $error("ERROR: Mismatch at address 0x00000000");

        // Fetch instruction at address 0x04
        test_a = 32'h0000_0004;
        #10;
        $display("Time: %0t, Address: 0x%h, Data Read: 0x%h (Expected: 0x00C00193)", $time, test_a, test_rd);
        if (test_rd !== 32'h00C00193) $error("ERROR: Mismatch at address 0x00000004");

        // Fetch instruction at address 0x0C (where the 'OR' instruction is)
        test_a = 32'h0000_000C;
        #10;
        $display("Time: %0t, Address: 0x%h, Data Read: 0x%h (Expected: 0x0023E233)", $time, test_a, test_rd);
        if (test_rd !== 32'h0023E233) $error("ERROR: Mismatch at address 0x0000000C");

        // Fetch instruction at address 0x20 (the corrected BEQ)
        test_a = 32'h0000_0020;
        #10;
        $display("Time: %0t, Address: 0x%h, Data Read: 0x%h (Expected: 0x00020463)", $time, test_a, test_rd);
        if (test_rd !== 32'h00020463) $error("ERROR: Mismatch at address 0x00000020");

        // Fetch instruction at address 0x4C (the corrected SW)
        test_a = 32'h0000_004C;
        #10;
        $display("Time: %0t, Address: 0x%h, Data Read: 0x%h (Expected: 0x0221A023)", $time, test_a, test_rd);
        if (test_rd !== 32'h0221A023) $error("ERROR: Mismatch at address 0x0000004C");


        // --- Example of checking for the final write (conceptually) ---
        // NOTE: Your 'imem' module is read-only.
        // This check would normally be in a testbench for a data memory or processor.
        // We'll simulate the event for demonstration purposes.
        $display("\n--- Simulating Data Memory Write Check ---");

        // Pretend our processor executed the 'sw' instruction and produced these values
        simulated_DataAdr = 100;
        simulated_WriteData = 25;

        #10; // Wait some time

        if (simulated_DataAdr === 100 && simulated_WriteData === 25) begin
            $display("SUCCESS: Test criterion met! Value 25 written to address 100 (simulated).");
        end else begin
            $display("FAILURE: Test criterion not met. DataAdr: %0d, WriteData: %0d (simulated).",
                     simulated_DataAdr, simulated_WriteData);
        end

        $display("--------------------------------------------------");
        $display("IMEM Testbench Finished");
        $display("--------------------------------------------------");

        #20; // Final delay before ending simulation
        $finish; // End simulation
    end

endmodule