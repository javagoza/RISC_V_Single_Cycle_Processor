`timescale 1ns / 1ps

module testbench3();

    logic clk;
    logic reset;

    logic [31:0] tb_WriteData;
    logic [31:0] tb_DataAdr;
    logic tb_MemWrite;

    // Use an associative array of queues to store expected memory values
    // Key: address, Value: queue of expected_data for that address in order
    typedef logic [31:0] data_queue_t [$]; // Define a queue type
    data_queue_t expected_mem_writes_sequence[int];

    integer pass_count = 0;
    integer total_expected_writes = 0; // Total number of individual writes we expect to verify

    // instantiate device to be tested
    top dut(
        .clk(clk),
        .reset(reset),
        .debug_WriteData(tb_WriteData),
        .debug_DataAdr(tb_DataAdr),
        .debug_MemWrite(tb_MemWrite)
    );

    // Function to add an expected write to the sequence
    function void add_expected_write(int addr, logic [31:0] data);
        expected_mem_writes_sequence[addr].push_back(data);
        total_expected_writes++;
    endfunction
    
    
    // initialize test
initial begin
    // Initialize clock and reset
    clk <= 1;
    reset <= 1;
    #22; // Keep reset active for a few clock cycles
    reset <= 0;
    $display("Simulation Started. Waiting for program execution...");

    // Populate expected memory values from the assembly code in order of execution
    // Initial Register Setup related stores
    add_expected_write(32'h000, 32'h00000000); // sw x0, 0(x6)
    add_expected_write(32'h004, 32'h00000001); // sw x1, 4(x6)
    add_expected_write(32'h008, 32'h00000005); // sw x2, 8(x6)
    add_expected_write(32'h00C, 32'h0000000C); // sw x3, 12(x6)
    add_expected_write(32'h010, 32'hFFFFFFFF); // sw x4, 16(x6)
    add_expected_write(32'h014, 32'h12345000); // sw x5, 20(x6)
    add_expected_write(32'h018, 32'h00000018); // sw x7, 24(x6) (PC of AUIPC, assuming PC=0 initially, and AUIPC is at 0x18)

    // R-Type Instructions Results
    add_expected_write(32'h01C, 32'h00000011); // sw x8, 28(x6) | ADD (17)
    add_expected_write(32'h020, 32'h00000007); // sw x9, 32(x6) | SUB (7)
    add_expected_write(32'h024, 32'h00005000); // sw x10, 36(x6) | SLL (20480)
    add_expected_write(32'h028, 32'h00000280); // sw x11, 40(x6) | SRL (640)
    add_expected_write(32'h02C, 32'hFFFFFFF8); // sw x14, 44(x6) | SRA (-8)
    add_expected_write(32'h030, 32'h00000006); // sw x17, 48(x6) | XOR (6)
    add_expected_write(32'h034, 32'h0000000E); // sw x18, 52(x6) | OR (14)
    add_expected_write(32'h038, 32'h00000008); // sw x19, 56(x6) | AND (8)
    add_expected_write(32'h03C, 32'h00000001); // sw x20, 60(x6) | SLT (1)
    add_expected_write(32'h040, 32'h00000000); // sw x21, 64(x6) | SLT (0)
    add_expected_write(32'h044, 32'h00000001); // sw x22, 68(x6) | SLT (1)
    add_expected_write(32'h048, 32'h00000000); // sw x25, 72(x6) | SLTU (0)
    add_expected_write(32'h04C, 32'h00000001); // sw x26, 76(x6) | SLTU (1)

    // I-Type Instructions Results
    add_expected_write(32'h050, 32'h000000C8); // sw x27, 80(x6) | ADDI (200)
    add_expected_write(32'h054, 32'h000000F7); // sw x28, 84(x6) | ADDI (247)
    add_expected_write(32'h058, 32'h00000064); // sw x29, 88(x6) | ADDI (100)
    add_expected_write(32'h05C, 32'h00000001); // sw x30, 92(x6) | SLTI (1)
    add_expected_write(32'h060, 32'h00000000); // sw x31, 96(x6) | SLTI (0)
    add_expected_write(32'h064, 32'h00000001); // sw x1, 100(x6) | SLTI (1)
    add_expected_write(32'h068, 32'h00000001); // sw x2, 104(x6) | SLTIU (1)
    add_expected_write(32'h06C, 32'h00000000); // sw x3, 108(x6) | SLTIU (0)
    add_expected_write(32'h070, 32'h00000001); // sw x4, 112(x6) | SLTIU (1)
    add_expected_write(32'h074, 32'h00000B9F); // sw x5, 116(x6) | XORI (0xB9F)
    add_expected_write(32'h078, 32'h00000111); // sw x7, 120(x6) | ORI (0x111)
    add_expected_write(32'h07C, 32'h0000000F); // sw x8, 124(x6) | ANDI (0x00F)
    add_expected_write(32'h080, 32'h00000038); // sw x9, 128(x6) | SLLI (56)
    add_expected_write(32'h084, 32'h00000019); // sw x10, 132(x6) | SRLI (25)
    add_expected_write(32'h088, 32'hFFFFFFE7); // sw x11, 136(x6) | SRAI (-25)

    // Memory Access Instructions Verification
    add_expected_write(32'h08C, 32'hFEEDBEEF); // sw x12, 140(x6)
    add_expected_write(32'h090, 32'hAABBCCDD); // sw x13, 144(x6)
    add_expected_write(32'h094, 32'hFEEDBEEF); // sw x15, 148(x6) (verify LW from 0x08C)
    add_expected_write(32'h098, 32'h55AA55AA); // sw x16, 152(x6)
    add_expected_write(32'h09C, 32'h55AA55AA); // sw x17, 156(x6) (verify LW after SW)

    // Byte Operations
    add_expected_write(32'h0A0, 32'hFFFFFFAA); // sw x18, 160(x6) | LB 152(x6) (sign-extended)
    add_expected_write(32'h0A4, 32'h00000055); // sw x19, 164(x6) | LB 153(x6) (sign-extended)
    add_expected_write(32'h0A8, 32'hFFFFFFAA); // sw x20, 168(x6) | LB 154(x6) (sign-extended)
    add_expected_write(32'h0AC, 32'h00000055); // sw x21, 172(x6) | LB 155(x6) (sign-extended)
    add_expected_write(32'h0B0, 32'h000000AA); // sw x18, 176(x6) | LBU 152(x6) (zero-extended)
    add_expected_write(32'h0B4, 32'h00000055); // sw x19, 180(x6) | LBU 153(x6) (zero-extended)

    // --- ADDED: Direct memory writes from SB instructions ---
    add_expected_write(32'h098, 32'h55AA55EE); // **NEW**: Direct write by SB instruction (sb x22, 152(x6))
    add_expected_write(32'h0B8, 32'h55AA55EE); // sw x23, 184(x6) | (verify LW from 0x098 after first SB)

    add_expected_write(32'h098, 32'h55AABBEE); // **NEW**: Direct write by second SB instruction (sb x22, 153(x6))
    add_expected_write(32'h0BC, 32'h55AABBEE); // sw x23, 188(x6) | (verify LW from 0x098 after second SB)

// Half-Word Operations
add_expected_write(32'h0C0, 32'hFFFFCCDD); // sw x24, 192(x6) | LH 144(x6) (sign-extended)
// Correction for 0x0C4: LH 146(x6) should be 0xFFFFAABB
add_expected_write(32'h0C4, 32'hFFFF_AABB); // sw x25, 196(x6) | LH 146(x6) (sign-extended from 0xAABB)
add_expected_write(32'h0C8, 32'h0000CCDD); // sw x24, 200(x6) | LHU 144(x6) (zero-extended)
// Correction for 0x0CC: LHU 146(x6) should be 0x0000AABB
add_expected_write(32'h0CC, 32'h0000_AABB); // sw x25, 204(x6) | LHU 146(x6) (zero-extended from 0xAABB)

    // --- ADDED: Direct memory writes from SH instructions ---
    add_expected_write(32'h090, 32'hAABB1122); // **NEW**: Direct write by SH instruction (sh x26, 144(x6))
    add_expected_write(32'h0D0, 32'hAABB1122); // sw x27, 208(x6) | (verify LW from 0x090 after first SH)

    add_expected_write(32'h090, 32'h33441122); // **NEW**: Direct write by second SH instruction (sh x26, 146(x6))
    add_expected_write(32'h0D4, 32'h33441122); // sw x27, 212(x6) | (verify LW from 0x090 after second SH)


    // JAL and JALR (Control Flow)
    // Dummy instruction skip at 0x0D8 (216) should NOT happen.
    add_expected_write(32'h0DC, 32'h0000CAFE); // sw x21, 220(x6) (JAL target)
    add_expected_write(32'h0E0, 32'h00000224); // sw x1, 224(x6) (JAL return addr - Corrected to 0x220 + 4)

    // Dummy instruction skip at 0x0E4 (228) should NOT happen.
    add_expected_write(32'h0E8, 32'h0000BEEF); // sw x24, 232(x6) (JALR target)
    add_expected_write(32'h0EC, 32'h00000248); // sw x1, 236(x6) (JALR return addr)

    // B-Type Instructions (Conditional Branches)
    add_expected_write(32'h0F4, 32'h00000001); // sw x28, 244(x6) | BEQ taken
    add_expected_write(32'h0F8, 32'h00000002); // sw x29, 248(x6) | BEQ not taken (because it wasn't branched to)
    add_expected_write(32'h0FC, 32'h00000003); // sw x28, 252(x6) | BNE taken

    // Overwrites for branch tests
    add_expected_write(32'h000, 32'h00000004); // sw x29, 0(x6) | BNE not taken
    add_expected_write(32'h004, 32'h00000005); // sw x28, 4(x6) | BLT taken
    add_expected_write(32'h008, 32'h00000006); // sw x29, 8(x6) | BLT not taken
    add_expected_write(32'h00C, 32'h00000007); // sw x28, 12(x6) | BGE taken
    add_expected_write(32'h010, 32'h00000008); // sw x29, 16(x6) | BGE not taken
    add_expected_write(32'h014, 32'h00000009); // sw x28, 20(x6) | BLTU taken
    add_expected_write(32'h018, 32'h0000000A); // sw x29, 24(x6) | BLTU not taken
    add_expected_write(32'h01C, 32'h0000000B); // sw x28, 28(x6) | BGEU taken
    add_expected_write(32'h020, 32'h0000000C); // sw x29, 32(x6) | BGEU not taken

    $display("Total expected memory writes: %0d", total_expected_writes);
end

    // generate clock to sequence tests
    always begin
        clk <= 1; #5; clk <= 0; #5; // 10ns clock period
    end

    // check results on memory writes
    always @(posedge clk) begin // Check on posedge clk, as data is typically stable then
        if (tb_MemWrite) begin
            $display("Time %0t: Memory Write Detected! Addr = 0x%h, Data = 0x%h",
                     $time, tb_DataAdr, tb_WriteData);

            // Check if there is an expected write for this address
            if (expected_mem_writes_sequence.exists(tb_DataAdr)) begin
                // Check if the current write matches the *next* expected value for this address
                if (expected_mem_writes_sequence[tb_DataAdr].size() > 0) begin
                    logic [31:0] expected_data = expected_mem_writes_sequence[tb_DataAdr].pop_front();
                    if (tb_WriteData === expected_data) begin
                        $display("  Verification PASSED for address 0x%h: Data 0x%h matches expected (next in sequence).",
                                 tb_DataAdr, tb_WriteData);
                        pass_count++;

                        // Check if all expected writes have occurred
                        if (pass_count == total_expected_writes) begin
                            $display("\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                            $display("!!! SIMULATION SUCCEEDED: All expected writes verified. !!!");
                            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
                            $finish; // End simulation gracefully
                        end
                    end else begin
                        $display("  Verification FAILED for address 0x%h: Expected 0x%h, Got 0x%h. (Incorrect value in sequence)",
                                 tb_DataAdr, expected_data, tb_WriteData);
                        $stop; // Stop on first failure
                    end
                end else begin
                    $error("Time %0t: Unexpected memory write to address 0x%h with data 0x%h. No more expected writes for this address in sequence.",
                           $time, tb_DataAdr, tb_WriteData);
                    $stop; // This means an address was written to more times than expected
                end
            end else begin
                // This might happen if there are internal writes we don't track,
                // or if the program behavior is different than expected.
                $warning("Time %0t: Unexpected memory write to address 0x%h with data 0x%h. No expectation set for this address.",
                         $time, tb_DataAdr, tb_WriteData);
                // For a robust testbench, this might indicate an error.
                // $stop; // Uncomment this if you want to stop on *any* unexpected address write.
            end
        end
    end

    // Optional: Timeout to end simulation if it runs too long without hitting a $finish
    initial begin
        #50000000; // Increased timeout further to 50us (50000ns)
        if (pass_count < total_expected_writes) begin
            $display("\n***************************************************");
            $display("!!! SIMULATION TIMEOUT: Did not verify all expected writes. !!!");
            $display("!!! Verified %0d out of %0d expected writes. !!!", pass_count, total_expected_writes);
            $display("***************************************************\n");
            $stop;
        end else begin
            $display("\n***************************************************");
            $display("!!! SIMULATION COMPLETE (TIMEOUT reached but all expected writes were verified). !!!");
            $display("***************************************************\n");
            $finish;
        end
    end

endmodule