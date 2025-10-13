`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2025 09:00:46 PM
// Design Name: 
// Module Name: tb_all_riscv32i_is
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//# RISC-V RV32I Single-Cycle Test Program
//# This program aims to test all core RV32I instructions,
//# including byte and half-word loads/stores,
//# tailored specifically for your `dmem`, `loaddata`, and `storedata` modules.
//#
//# Constraints:
//# - No .data segment: All constants embedded as immediates or constructed.
//# - Memory Range: 0x00000000 to 0x000000FC (256 bytes total).
//# - Memory Access: All addresses for SW/LW/SH/LH/SB/LB must be within this range.
//# - Alignment:
//#   - LW/SW: 4-byte aligned (offset % 4 == 0).
//#   - LH/LHU/SH: 2-byte aligned (offset % 2 == 0).
//#   - LB/LBU/SB: Can be any byte address.
//# - Store/Load Byte/Half-word logic uses your provided `storedata` and `loaddata` modules.

// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Rewied with https://luplab.gitlab.io/rvcodecjs/
// https://riscv-software-src.github.io/riscv-unified-db/manual/html/isa/isa_20240411/chapters/rv32.html
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_all_riscv32i_is(

    );

    // Declare the memory array that will hold the assembled instructions.
    // The size (e.g., 256 words) can be adjusted based on your code's needs.
    logic [31:0] MEM [0:255]; // 256 words of 32-bit memory
    
    // Declare the program counter for the assembler.
    // This variable tracks the current assembly address.
    int memPC;

    `define BENCH 0
    //`define GET_ASM_LABELS 0
    `include "riscv_assembly.sv"
    
    int _start = 0;   // Placeholder initial value
    int branch_target = 56;      // Placeholder initial value
    int dummy_function_target = 60; // Placeholder initial value
    
    initial begin
        // Initialize the program counter to 0 (start assembling from address 0)
        memPC = 0;

//_start:
 Label(_start);
//    # --- Setup Memory Base ---
//    # We will use 0x00000000 as the base address for our memory tests.

//    addi x6, x0, 0          # 0x00000313 | x6 = 0x00000000 (base address for memory operations)
      ADDI(x6, x0, 0); 
//    # --- Initial Register Setup ---

//    addi x1, x0, 1          # 0x00100093 | x1 = 1 (standard 'ra' register)
      ADDI(x1, x0, 1); 

//    addi x2, x0, 5          # 0x00500113 | x2 = 5
      ADDI(x2, x0, 5); 

//    addi x3, x0, 12         # 0x00c00193 | x3 = 12
      ADDI(x3, x0, 12); 

//    addi x4, x0, -1         # 0xfff00213 | x4 = -1 (0xFFFFFFFF)
      ADDI(x4, x0, -1); 

//    lui x5, 0x12345         # 0x123452b7 | x5 = 0x12345000 (testing LUI)
      LUI(x5, 'h12345);

//    auipc x7, 0x0           # 0x00000397 | x7 = PC of this instruction (testing AUIPC)
      AUIPC(x7, 32'h0);

//    # Store some initial values to our "result_area" for verification
//    # Using offsets from x6 (0x00000000)

//    sw x0, 0(x6)            # 0x00032023 | mem[0x000] = 0x00000000
      SW(x0, x6,0);

//    sw x1, 4(x6)            # 0x00132223 | mem[0x004] = 0x00000001
      SW(x1, x6, 4);

//    sw x2, 8(x6)            # 0x00232423 | mem[0x008] = 0x00000005
      SW(x2, x6, 8);

//    sw x3, 12(x6)           # 0x00332623 | mem[0x00C] = 0x0000000C
      SW(x3, x6, 12);

//    sw x4, 16(x6)           # 0x00432823 | mem[0x010] = 0xFFFFFFFF
      SW(x4, x6, 16);

//    sw x5, 20(x6)           # 0x00532a23 | mem[0x014] = 0x12345000
      SW(x5, x6, 20);

//    sw x7, 24(x6)           # 0x00732c23 | mem[0x018] = AUIPC value (current PC)
      SW(x7, x6, 24);

//    # --- R-Type Instructions (Register-Register Operations) ---

//    # ADD

//    add x8, x2, x3          # 0x00310433 | x8 = (5 + 12) = 17
      ADD(x8, x2, x3);

//    sw x8, 28(x6)           # 0x00832e23 | mem[0x01C] = 17
      SW(x8, x6, 28);

//    # SUB

//    sub x9, x3, x2          # 0x402184b3 | x9 = (12 - 5) = 7
      SUB(x9, x3, x2);

//    sw x9, 32(x6)           # 0x02932023 | mem[0x020] = 7
      SW(x9, x6, 32);

//    # SLL (Shift Left Logical)

//    sll x10, x2, x3         # 0x00311533 | x10 = 5 << 12 (using x3 as shift amount) = 20480
      SLL(x10, x2, x3);

//    sw x10, 36(x6)          # 0x02a32223 | mem[0x024] = 20480
      SW(x10, x6, 36);

//    # SRL (Shift Right Logical)

//    srl x11, x10, x2        # 0x002555b3 | x11 = 20480 >> 5 = 640
      SRL(x11, x10, x2);

//    sw x11, 40(x6)          # 0x02b32423 | mem[0x028] = 640
      SW(x11, x6, 40);

//    # SRA (Shift Right Arithmetic)

//    addi x12, x0, -32       # 0xfe000613 | x12 = -32 (0xFFFFFFE0)
      ADDI(x12, x0, -32);

//    addi x13, x0, 2         # 0x00200693 | x13 = 2
      ADDI(x13, x0, 2);

//    sra x14, x12, x13       # 0x40d65733 | x14 = -32 >> 2 = -8 (0xFFFFFFF8)
      SRA(x14, x12, x13);

//    sw x14, 44(x6)          # 0x02e32623 | mem[0x02C] = -8
      SW(x14, x6, 44);

//    # XOR

//    addi x15, x0, 0b1010    # 0x00a00793 | x15 = 10
      ADDI(x15, x0, 4'b1010);

//    addi x16, x0, 0b1100    # 0x00c00813 | x16 = 12
      ADDI(x16, x0, 4'b1100);

//    xor x17, x15, x16       # 0x0107c8b3 | x17 = 10 ^ 12 = 0b0110 = 6
      XOR(x17, x15, x16);

//    sw x17, 48(x6)          # 0x03132823 | mem[0x030] = 6
      SW(x17, x6, 48);

//    # OR

//    or x18, x15, x16        # 0x0107e933 | x18 = 10 | 12 = 0b1110 = 14
      OR(x18, x15, x16);

//    sw x18, 52(x6)          # 0x03232a23 | mem[0x034] = 14
      SW(x18, x6, 52);

//    # AND

//    and x19, x15, x16       # 0x0107f9b3 | x19 = 10 & 12 = 0b1000 = 8
      AND( x19, x15, x16);

//    sw x19, 56(x6)          # 0x03332c23 | mem[0x038] = 8
      SW(x19, x6, 56);

//    # SLT (Set Less Than) - Signed

//    slt x20, x2, x3         # 0x00312a33 | x20 = (5 < 12) ? 1 : 0 = 1
      SLT(x20, x2, x3);

//    sw x20, 60(x6)          # 0x03432e23 | mem[0x03C] = 1
      SW(x20, x6, 60);

//    slt x21, x3, x2         # 0x0021aab3 | x21 = (12 < 5) ? 1 : 0 = 0
      SLT(x21, x3, x2);

//    sw x21, 64(x6)          # 0x05532023 | mem[0x040] = 0
      SW(x21, x6, 64);

//    slt x22, x4, x2         # 0x00222b33 | x22 = (-1 < 5) ? 1 : 0 = 1
      SLT(x22, x4, x2);

//    sw x22, 68(x6)          # 0x05632223 | mem[0x044] = 1
      SW(x22, x6, 68);

//    # SLTU (Set Less Than Unsigned)

//    addi x23, x0, -1        # 0xfff00b93 | x23 = 0xFFFFFFFF
      ADDI(x23, x0, -1);

//    addi x24, x0, 10        # 0x00a00c13 | x24 = 10
      ADDI(x24, x0, 10);

//    sltu x25, x23, x24      # 0x018bbcb3 | x25 = (0xFFFFFFFF < 10) ? 1 : 0 = 0 (unsigned comparison)
      SLTU(x25, x23, x24);

//    sw x25, 72(x6)          # 0x05932423 | mem[0x048] = 0
      SW(x25, x6, 72);

//    sltu x26, x24, x23      # 0x017c3d33 | x26 = (10 < 0xFFFFFFFF) ? 1 : 0 = 1 (unsigned comparison)
      SLTU(x26, x24, x23);

//    sw x26, 76(x6)          # 0x05a32623 | mem[0x04C] = 1
      SW(x26, x6, 76);


//    # --- I-Type Instructions (Immediate Operations) ---

//    # ADDI

//    addi x27, x0, 200       # 0x0c800d93 | x27 = 200
      ADDI(x27, x0, 200);

//    sw x27, 80(x6)          # 0x05b32823 | mem[0x050] = 200
      SW(x27, x6, 80);

//    addi x28, x27, 47       # 0x02fd8e13 | x28 = 200 + 47 = 247
      ADDI(x28, x27, 47);

//    sw x28, 84(x6)          # 0x05c32a23 | mem[0x054] = 247
      SW(x28, x6, 84);

//    addi x29, x27, -100     # 0xf9cd8e93 | x29 = 200 - 100 = 100
      ADDI(x29, x27, -100);

//    sw x29, 88(x6)          # 0x05d32c23 | mem[0x058] = 100
      SW(x29, x6, 88);

//    # SLTI (Set Less Than Immediate) - Signed

//    slti x30, x2, 10        # 0x00a12f13 | x30 = (5 < 10) ? 1 : 0 = 1
      SLTI(x30, x2, 10);

//    sw x30, 92(x6)          # 0x05e32e23 | mem[0x05C] = 1
      SW(x30, x6, 92);

//    slti x31, x3, 5         # 0x0051af93 | x31 = (12 < 5) ? 1 : 0 = 0
      SLTI(x31, x3, 5);

//    sw x31, 96(x6)          # 0x07f32023 | mem[0x060] = 0
      SW(x31, x6, 96);

//    slti x1, x4, 0          # 0x00022093 | x1 = (-1 < 0) ? 1 : 0 = 1 (reusing x1 for next test)
      SLTI(x1, x4, 0);

//    sw x1, 100(x6)          # 0x06132223 | mem[0x064] = 1
      SW(x1, x6, 100);

//    # SLTIU (Set Less Than Immediate Unsigned)

//    sltiu x2, x2, 10        # 0x00a13113 | x2 = (5 < 10) ? 1 : 0 = 1 (reusing x2)
      SLTIU(x2, x2, 10);

//    sw x2, 104(x6)          # 0x06232423 | mem[0x068] = 1
      SW(x2, x6, 104);

//    sltiu x3, x4, 10        # 0x00a23193 | x3 = (0xFFFFFFFF < 10) ? 1 : 0 = 0 (unsigned) (reusing x3)
      SLTIU(x3, x4, 10);

//    sw x3, 108(x6)          # 0x06332623 | mem[0x06C] = 0
      SW(x3, x6, 108);

//    sltiu x4, x2, -1        # 0xfff13213 | x4 = (5 < 0xFFFFFFFF) ? 1 : 0 = 1 (unsigned) (reusing x4)
      SLTIU(x4, x2, -1);

//    sw x4, 112(x6)          # 0x06432823 | mem[0x070] = 1
      SW(x4, x6, 112);

//    # XORI (FIXED: 0xABC needs to be built with LUI+ADDI because 0xABC > 2047)

//    addi x5, x0, 0x123      # 0x12300293 | x5 = 0x00000123
      ADDI(x5, x0, 'h123);

//    lui x20, 0x1            # 0x00001a37 | x20 = 0x00001000
      LUI(x20, 1);

//    addi x20, x20, -1348    # 0xabca0a13 | x20 = 0x1000 - 1348 = 2748 = 0xABC (Corrected way to load 0xABC)
      ADDI(x20, x20, -1348);

//    xor x5, x5, x20         # 0x0142c2b3 | x5 = 0x123 ^ 0xABC = 0xBBF
      XOR(x5, x5, x20);

//    sw x5, 116(x6)          # 0x06532a23 | mem[0x074] = 0xBBF
      SW(x5, x6, 116);

//    # ORI (0x101 and 0x011 are fine as 12-bit signed immediates)

//    addi x7, x0, 0x101      # 0x10100393 | x7 = 0x101 (257, fits)
      ADDI(x7, x0, 'h101);

//    ori x7, x7, 0x011       # 0x0113e393 | x7 = 0x101 | 0x011 = 0x111 (17, fits)
      ORI(x7, x7, 'h011);

//    sw x7, 120(x6)          # 0x06732c23 | mem[0x078] = 0x111
      SW(x7, x6, 120);


//    # ANDI (FIXED: 0xF0F needs to be built with LUI+ADDI because 0xF0F > 2047)
//    # 0xF0F = 3855. We need: LUI x_temp, 1; ADDI x_temp, x_temp, 0xF0F - 0x1000 = 0xF0F - 4096 = -241.

//    lui x8, 0x1             # 0x00001437 | x8 = 0x00001000
      LUI(x8, 1);

//    addi x8, x8, -241       # 0xf0f40413 | x8 = 0x1000 - 241 = 3855 = 0xF0F (Corrected way to load 0xF0F)
      ADDI(x8, x8, -241);

//    andi x8, x8, 0x0FF      # 0x0ff47413 | x8 = 0xF0F & 0x0FF = 0x00F (0x0FF = 255, fits 12-bit signed)
      ANDI(x8, x8, 'h0ff);

//    sw x8, 124(x6)          # 0x06832e23 | mem[0x07C] = 0x00F
      SW(x8, x6, 124);

//    # SLLI (Shift Left Logical Immediate)

//    addi x9, x0, 7          # 0x00700493 | x9 = 7
      ADDI(x9, x0, 7);

//    slli x9, x9, 3          # 0x00349493 | x9 = 7 << 3 = 56
      SLLI(x9, x9, 3);

//    sw x9, 128(x6)          # 0x08932023 | mem[0x080] = 56
      SW(x9, x6, 128);

//    # SRLI (Shift Right Logical Immediate)

//    addi x10, x0, 100       # 0x06400513 | x10 = 100
      ADDI(x10, x0, 100);

//    srli x10, x10, 2        # 0x00255513 | x10 = 100 >> 2 = 25
      SRLI(x10, x10, 2);

//    sw x10, 132(x6)         # 0x08a32223 | mem[0x084] = 25
      SW(x10, x6, 132);

//    # SRAI (Shift Right Arithmetic Immediate)

//    addi x11, x0, -100      # 0xf9c00593 | x11 = 0xFFFFFF9C
      ADDI(x11, x0, -100);

//    srai x11, x11, 2        # 0x4025d593 | x11 = -100 >> 2 = -25 (0xFFFFFFE7)
      SRAI(x11, x11, 2);

//    sw x11, 136(x6)         # 0x08b32423 | mem[0x088] = -25
      SW(x11, x6, 136);


//    # --- Memory Access Instructions (LW, SW, LB, LBU, LH, LHU, SB, SH) ---
//    # We will store initial word values and then perform byte/half-word ops on them.
//    # All offsets must be within 0x0 to 0xFC.

//    # Prepare some memory locations with known 32-bit values
//    # 0xFEEDBEEF (LUI/ADDI construction)

//    lui x12, 0xFEEDC       # 0xfeedc637 | x12 = 0xFEEDC000 (upper 20 bits are 0xFEEDC)
      LUI(x12, 'hFEEDC);

//    addi x12, x12, -273     # 0xeef60613 | x12 = 0xFEEDC000 + (-273) = 0xFEEDBEEF (Corrected way to load 0xFEEDBEEF)
      ADDI(x12, x12, -273);

//    sw x12, 140(x6)         # 0x08c32623 | mem[0x08C] = 0xFEEDBEEF
      SW(x12, x6, 140);

//    # 0xAABBCCDD (LUI/ADDI construction)

//    lui x13, 0xAABBD       # 0xaabbd6b7 | x13 = 0xAABBD000
      LUI(x13, 'hAABBD);

//    addi x13, x13, -803     # 0xcdd68693 | x13 = 0xAABBD000 + (-803) = 0xAABBCCDD (Corrected way to load 0xAABBCCDD)
      ADDI(x13, x13, -803);

//    sw x13, 144(x6)         # 0x08d32823 | mem[0x090] = 0xAABBCCDD
      SW(x13, x6, 144);

//    # LW (Load Word)

//    lw x15, 140(x6)         # 0x08c32783 | x15 = 0xFEEDBEEF
      LW(x15, x6, 140);

//    sw x15, 148(x6)         # 0x08f32a23 | mem[0x094] = 0xFEEDBEEF (verify LW)
      SW(x15, x6, 148);

//    # SW (Store Word)
//    # 0x55AA55AA (LUI/ADDI construction)

//    lui x16, 0x55AA5        # 0x55aa5837 | x16 = 0x55AA5000
      LUI(x16, 'h55AA5);

//    addi x16, x16, 0x5AA    # 0x5aa80813 | x16 = 0x55AA55AA (Corrected way to load 0x55AA55AA)
      ADDI(x16, x16, 'h5AA);

//    sw x16, 152(x6)         # 0x09032c23 | mem[0x098] = 0x55AA55AA
      SW(x16, x6, 152);

//    lw x17, 152(x6)         # 0x09832883 | x17 = 0x55AA55AA (verify SW)
      LW(x17, x6, 152);

//    sw x17, 156(x6)         # 0x09132e23 | mem[0x09C] = 0x55AA55AA (verify LW after SW)
      SW(x17, x6, 156);

//    # --- Byte Operations (LB, LBU, SB) ---
//    # Using mem[0x098] = 0x55AA55AA
//    # Bytes are: 0xAA (byte 0), 0x55 (byte 1), 0xAA (byte 2), 0x55 (byte 3)

//    # LB (Load Byte - Signed)

//    lb x18, 152(x6)         # 0x09830903 | x18 = 0xFFFFFFAA (sign-extended from 0xAA)
      LB(x18, x6, 152);

//    sw x18, 160(x6)         # 0x0b232023 | mem[0x0A0] = 0xFFFFFFAA
      SW(x18, x6, 160);

//    lb x19, 153(x6)         # 0x09930983 | x19 = 0x00000055 (sign-extended from 0x55)
      LB(x19, x6, 153);

//    sw x19, 164(x6)         # 0x0b332223 | mem[0x0A4] = 0x00000055
      SW(x19, x6, 164);

//    lb x20, 154(x6)         # 0x09a30a03 | x20 = 0xFFFFFFAA (sign-extended from 0xAA)
      LB(x20, x6, 154);

//    sw x20, 168(x6)         # 0x0b432423 | mem[0x0A8] = 0xFFFFFFAA
      SW(x20, x6, 168);

//    lb x21, 155(x6)         # 0x09b30a83 | x21 = 0x00000055 (sign-extended from 0x55)
      LB(x21, x6, 155);

//    sw x21, 172(x6)         # 0x0b532623 | mem[0x0AC] = 0x00000055
      SW(x21, x6, 172);

//    # LBU (Load Byte Unsigned)

//    lbu x18, 152(x6)        # 0x09834903 | x18 = 0x000000AA (zero-extended from 0xAA)
      LBU(x18, x6, 152);

//    sw x18, 176(x6)         # 0x0b232823 | mem[0x0B0] = 0x000000AA
      SW(x18, x6, 176);

//    lbu x19, 153(x6)        # 0x09934983 | x19 = 0x00000055 (zero-extended from 0x55)
      LBU(x19, x6, 153);

//    sw x19, 180(x6)         # 0x0b332a23 | mem[0x0B4] = 0x00000055
      SW(x19, x6, 180);

//    # SB (Store Byte)

//    addi x22, x0, 0xEE      # 0x0ee00b13 | Store 0xEE (fits 12-bit signed)
      ADDI(x22, x0, 'hEE);

//    sb x22, 152(x6)         # 0x09630c23 | mem[0x098] now = 0x55AA55EE (modified lowest byte)
      SB(x22, x6, 152);

//    lw x23, 152(x6)         # 0x09832b83 | x23 = 0x55AA55EE
      LW(x23, x6, 152);

//    sw x23, 184(x6)         # 0x0b732c23 | mem[0x0B8] = 0x55AA55EE (verify SB)
      SW(x23, x6, 184);

//    addi x22, x0, 0xBB      # 0x0bb00b13 | Store 0xBB (fits 12-bit signed)
      ADDI(x22, x0, 'hbb);

//    sb x22, 153(x6)         # 0x09630ca3 | mem[0x098] now = 0x55AA BB EE (modified second byte)
      SB(x22, x6, 153);

//    lw x23, 152(x6)         # 0x09832b83 | x23 = 0x55AABBE E (Note: this LW still reads the whole word, not just modified parts)
      LW(x23, x6, 152);

//    sw x23, 188(x6)         # 0x0b732e23 | mem[0x0BC] = 0x55AABBEE (verify SB)
      SW(x23, x6, 188);

//    # --- Half-Word Operations (LH, LHU, SH) ---
//    # Using mem[0x090] = 0xAABBCCDD
//    # Half-words: 0xCCDD (half 0), 0xAABB (half 1)

//    # LH (Load Half-word - Signed)

//    lh x24, 144(x6)         # 0x09031c03 | x24 = 0xFFFFCCDD (sign-extended from 0xCCDD)
      LH(x24, x6, 144);

//    sw x24, 192(x6)         # 0x0d832023 | mem[0x0C0] = 0xFFFFCCDD
      SW(x24, x6, 192);

//    lh x25, 146(x6)         # 0x09231c83 | x25 = 0xFFFFAABB (sign-extended from 0xAABB)
      LH(x25, x6, 146);

//    sw x25, 196(x6)         # 0x0d932223 | mem[0x0C4] = 0xFFFFAABB
      SW(x25, x6, 196);

//    # LHU (Load Half-word Unsigned)

//    lhu x24, 144(x6)        # 0x09035c03 | x24 = 0x0000CCDD (zero-extended from 0xCCDD)
      LHU(x24, x6, 144);

//    sw x24, 200(x6)         # 0x0d832423 | mem[0x0C8] = 0x0000CCDD
      SW(x24, x6, 200);

//    lhu x25, 146(x6)        # 0x09235c83 | x25 = 0x0000AABB (zero-extended from 0xAABB)
      LHU(x25, x6, 146);

//    sw x25, 204(x6)         # 0x0d932623 | mem[0x0CC] = 0x0000AABB
      SW(x25, x6, 204);

//    # SH (Store Half-word)
//    # 0x1122 (LUI/ADDI construction)

//    lui x26, 0x00001        # 0x00001d37 | x26 = 0x00001000
      LUI(x26, 1);

//    addi x26, x26, 0x122    # 0x122d0d13 | x26 = 0x00001122 (Corrected way to load 0x1122)
      ADDI(x26, x26, 'h122);

//    sh x26, 144(x6)         # 0x09a31823 | mem[0x090] now = 0xAABB1122 (modified lowest half)
      SH(x26, x6, 144);

//    lw x27, 144(x6)         # 0x09032d83 | x27 = 0xAABB1122
      LW(x27, x6, 144);

//    sw x27, 208(x6)         # 0x0db32823 | mem[0x0D0] = 0xAABB1122 (verify SH)
      SW(x27, x6, 208);

//    # 0x3344 (LUI/ADDI construction)

//    lui x26, 0x00003        # 0x00003d37 | x26 = 0x00003000
      LUI(x26, 3);

//    addi x26, x26, 0x344    # 0x344d0d13 | x26 = 0x00003344 (Corrected way to load 0x3344)
      ADDI(x26, x26, 'h344);

//    sh x26, 146(x6)         # 0x09a31923 | mem[0x090] now = 0x33441122 (modified highest half)
      SH(x26, x6, 146);

//    lw x27, 144(x6)         # 0x09032d83 | x27 = 0x33441122
      LW(x27, x6, 144);

//    sw x27, 212(x6)         # 0x0db32a23 | mem[0x0D4] = 0x33441122 (verify SH)
      SW(x27, x6, 212);


//    # --- JAL and JALR (Control Flow) ---

//    # JAL (Jump and Link)
//    # Target: jal_target, which is current PC + offset.
//    # Current PC: 0x00000170
//    # jal_target: 0x0000017C
//    # Offset = Target - Current PC = 0x17C - 0x170 = 0xC
//    # J-type immediate encoding: imm[20|10:1|11|19:12]
//    # imm = 0xC (0b1100)
//    # imm[20] = 0
//    # imm[10:1] = 0b110 (0x6)
//    # imm[11] = 0
//    # imm[19:12] = 0
//    # Encoding: 0 (bit 20) | 00000000 (bits 19:12) | 0 (bit 11) | 000000110 (bits 10:1) | opcode=0x6F
//    # Result: 0000006f
//    jal x1, jal_target      # 0x0000006f | x1 = address of next instruction (after JAL)

//    # Dummy instruction, should be skipped
//    # PC: 0x00000174
//    # 0xDEAD (LUI/ADDI construction)
//    lui x20, 0xE            # 0x0000eab7 | x20 = 0x0000E000 (0x0D + 1 shifted)
//    addi x20, x20, -339     # 0xebdb2a33 | x20 = 0x0000E000 + (-339) = 0x0000DEAD (Corrected way to load 0xDEAD)
//    sw x20, 216(x6)         # 0x01832d23 | mem[0x0D8] = 0xDEAD if not skipped (error)

//jal_target:
//    # This instruction should be executed
//    # PC: 0x0000017C
//    # 0xCAFE (LUI/ADDI construction)
//    lui x21, 0xD            # 0x0000db37 | x21 = 0x0000D000 (0x0C + 1 shifted)
//    addi x21, x21, -1282    # 0xb02acb33 | x21 = 0x0000D000 + (-1282) = 0x0000CAFE (Corrected way to load 0xCAFE)
//    sw x21, 220(x6)         # 0x01c32d23 | mem[0x0DC] = 0xCAFE

//    # Verify return address in x1 (ra) from JAL
//    sw x1, 224(x6)          # 0x01a32e23 | mem[0x0E0] = PC of 'lui x20, 0xE' (0x00000174)

//    # JALR (Jump and Link Register)
//    # PC: 0x00000188
//    # Jump to PC + 8, store PC+4 in x1.
//    # Current PC: 0x00000188
//    # Target: 0x00000188 + 8 = 0x00000190
//    # JALR: imm[11:0] | rs1 | funct3=000 | rd | opcode=0x67
//    # Here, rs1 is x22 (0), imm is 8.
//    # Encoding: 00800067
//    addi x22, x0, 0         # 0x00000b33 | Clear x22
//    jalr x1, x22, 8         # 0x008000e7 | Jump to PC + 8, store PC+4 in x1.
//                            # (x22 is x0, so effectively jump to 8(x0), PC relative jump)

//    # Dummy instruction, should be skipped
//    # PC: 0x00000190
//    # 0xFEED (LUI/ADDI construction)
//    lui x23, 0x10           # 0x00010bb7 | x23 = 0x00010000 (0x0F + 1 shifted)
//    addi x23, x23, -275     # 0xefdb3b33 | x23 = 0x00010000 + (-275) = 0x0000FEED (Corrected way to load 0xFEED)
//    sw x23, 228(x6)         # 0x01c32e23 | mem[0x0E4] = 0xFEED if not skipped

//jalr_actual_target:
//    # This instruction should be executed
//    # PC: 0x00000198
//    # 0xBEEF (LUI/ADDI construction)
//    lui x24, 0xC            # 0x0000cbe7 | x24 = 0x0000C000 (0x0B + 1 shifted)
//    addi x24, x24, -273     # 0xefdcb213 | x24 = 0x0000C000 + (-273) = 0x0000BEEF (Corrected way to load 0xBEEF)
//    sw x24, 232(x6)         # 0x01c32023 | mem[0x0E8] = 0xBEEF

//    # Verify return address in x1 (ra) from JALR
//    sw x1, 236(x6)          # 0x01d32223 | mem[0x0EC] = PC of 'lui x23, 0x10' (0x00000190)


//    # --- B-Type Instructions (Conditional Branches) ---

//    # BEQ (Branch Equal)
//    # PC: 0x000001A8
//    addi x25, x0, 10        # 0x00a00c93 | x25 = 10
//    addi x26, x0, 10        # 0x00a00d13 | x26 = 10
//    # Branch offset: Target - Current PC = beq_taken - (PC of beq instruction)
//    # beq_taken: 0x000001BC
//    # PC of beq: 0x000001B0
//    # Offset = 0x1BC - 0x1B0 = 0xC
//    # B-type immediate encoding: imm[12|10:5] | rs2 | rs1 | funct3 | imm[4:1|11] | opcode
//    # imm = 0xC (0b1100)
//    # imm[12] = 0
//    # imm[10:5] = 0b000001 (0x1)
//    # imm[4:1] = 0b100 (0x4)
//    # imm[11] = 0
//    # Encoding: 0 (bit 12) | 000001 (bits 10:5) | x26(26) | x25(25) | 000 (funct3) | 0100 (bits 4:1) | 0 (bit 11) | opcode=0x63
//    # Result: 001d8c63
//    beq x25, x26, beq_taken # 0x006c8c63 | Should branch (10 == 10) # Rcorrected with actual x25/x26
//                            # 0x006c8c63 = imm[12]=0, imm[10:5]=000110, rs2=x26, rs1=x25, funct3=000, imm[4:1]=0000, imm[11]=0, opcode=0x63
//                            # imm is calculated as:
//                            #  target_PC - current_PC = (0x1BC - 0x1B0) = 0xC
//                            #  0xC = 0b000000001100
//                            #  imm[12] = 0
//                            #  imm[10:5] = 0b000001
//                            #  imm[4:1] = 0b100
//                            #  imm[11] = 0
//                            #  This gives 000001_01100_000_000_00_011_0011 (binary)
//                            #  000001 | 11010 | 11001 | 000 | 00100 | 0110011
//                            #  000001 (imm[10:5]) | 11010 (rs2=x26) | 11001 (rs1=x25) | 000 (funct3) | 0100 (imm[4:1]) | 0 (imm[11]) | 0x63 (opcode)
//                            # Let's re-encode with the correct B-type format:
//                            # imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode
//                            # For offset 0xC (12 decimal): 0b000000001100
//                            # imm[12] = 0
//                            # imm[10:5] = 0b000001
//                            # imm[4:1] = 0b100
//                            # imm[11] = 0
//                            # So, 0 | 000001 | 11010 (x26) | 11001 (x25) | 000 | 0100 | 0 | 0110011
//                            # = 0000011101011001000010000110011
//                            # = 0x005D9063.
//                            # Oh, previous was 0x006c8c63. The assembler might optimize branch targets, or I'm mixing up pseudo-ops.
//                            # No, the branch offset is relative to PC.
//                            # current PC is 0x1b0 (432 decimal). target PC is 0x1bc (444 decimal).
//                            # offset is 0xC.
//                            # B-type format: imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode
//                            # imm[12] = (offset >> 12) & 1
//                            # imm[10:5] = (offset >> 5) & 0x3F
//                            # imm[4:1] = (offset >> 1) & 0xF
//                            # imm[11] = (offset >> 11) & 1
//                            # For offset 0xC (0b1100):
//                            # imm[12] = 0
//                            # imm[10:5] = (0xC >> 5) = 0 (0b000000)
//                            # imm[4:1] = (0xC >> 1) = 0x6 (0b0110)
//                            # imm[11] = 0
//                            # This means the imm parts are: 0_000000_0110_0
//                            # Assembled: 0 | 000000 | 11010(x26) | 11001(x25) | 000 | 0110 | 0 | 0110011
//                            # = 0000001101011001000011000110011
//                            # = 0x005D9063.

//    # Let's assume the assembler is correctly handling the branch offset.
//    # The hexdump you originally provided did not include these.
//    # I'll use 0x006c8c63 as it's a common output from some tools for a positive branch,
//    # but the manual calculation 0x005D9063 looks more correct.
//    # I'll stick to my manual calculation for consistency.
//    beq x25, x26, beq_taken # 0x005d9c63 | Should branch (10 == 10) # (Calculated with offset 0xC)

//    # Dummy, should be skipped
//    # PC: 0x000001B4
//    # 0x1111 (LUI/ADDI construction)
//    lui x27, 0x1            # 0x00001db7 | x27 = 0x00001000
//    addi x27, x27, 0x111    # 0x111d8db3 | x27 = 0x00001111 (Corrected way to load 0x1111)
//    sw x27, 240(x6)         # 0x01832f23 | mem[0x0F0] = 0x1111 if not skipped

//beq_taken:
//    # PC: 0x000001BC
//    addi x28, x0, 1         # 0x00100e13 | Flag for branch taken
//    sw x28, 244(x6)         # 0x01932f23 | mem[0x0F4] = 1

//    addi x25, x0, 10        # 0x00a00c93 | x25 = 10
//    addi x26, x0, 20        # 0x01400d13 | x26 = 20
//    # Branch offset: Target - Current PC = beq_skip - (PC of beq instruction)
//    # beq_skip: 0x000001D0
//    # PC of beq: 0x000001C8
//    # Offset = 0x1D0 - 0x1C8 = 0x8
//    # Encoding for offset 0x8 (0b1000): imm[12]=0, imm[10:5]=0b000000, imm[4:1]=0b1000, imm[11]=0
//    # Encoded: 0 | 000000 | 11010(x26) | 11001(x25) | 000 | 1000 | 0 | 0110011
//    # = 0x006D9463
//    beq x25, x26, beq_skip  # 0x006d9463 | Should NOT branch (10 != 20)

//    addi x29, x0, 2         # 0x00200e93 | Flag for branch not taken
//    sw x29, 248(x6)         # 0x01c32f23 | mem[0x0F8] = 2
//beq_skip:
//    # PC: 0x000001D0 (No instruction here, just a label)

//    # BNE (Branch Not Equal)
//    addi x25, x0, 10        # 0x00a00c93 | x25 = 10
//    addi x26, x0, 20        # 0x01400d13 | x26 = 20
//    # Branch offset: Target - Current PC = bne_taken - (PC of bne instruction)
//    # bne_taken: 0x000001E4
//    # PC of bne: 0x000001DC
//    # Offset = 0x1E4 - 0x1DC = 0x8
//    # Encoding for offset 0x8: imm[12]=0, imm[10:5]=0b000000, imm[4:1]=0b1000, imm[11]=0
//    # Encoded: 0 | 000000 | 11010(x26) | 11001(x25) | 001 | 1000 | 0 | 0110011 (funct3=001 for BNE)
//    # = 0x006d94e3
//    bne x25, x26, bne_taken # 0x006d94e3 | Should branch (10 != 20)

//    # Dummy, should be skipped
//    # PC: 0x000001E0
//    # 0x2222 (LUI/ADDI construction)
//    lui x27, 0x2            # 0x00002db7 | x27 = 0x00002000
//    addi x27, x27, 0x222    # 0x222d8db3 | x27 = 0x00002222 (Corrected way to load 0x2222)
//    # sw x27, 252(x6)       # Only 0x0FC (252) left! We'll use this last slot.
//                            # (This line is effectively commented out by the flow for now)

//bne_taken:
//    # PC: 0x000001E4
//    addi x28, x0, 3         # 0x00300e13 | Flag for branch taken
//    sw x28, 252(x6)         # 0x01d32f23 | mem[0x0FC] = 3 (LAST VALID WORD IN DMEM)

//    addi x25, x0, 10        # 0x00a00c93 | x25 = 10
//    addi x26, x0, 10        # 0x00a00d13 | x26 = 10
//    # Branch offset: Target - Current PC = bne_skip - (PC of bne instruction)
//    # bne_skip: 0x000001F8
//    # PC of bne: 0x000001F0
//    # Offset = 0x1F8 - 0x1F0 = 0x8
//    # Encoding for offset 0x8, funct3=001 (BNE): 0x006d94e3
//    bne x25, x26, bne_skip  # 0x006d94e3 | Should NOT branch (10 == 10)

//    addi x29, x0, 4         # 0x00400e93 | Flag for branch not taken
//    sw x29, 0(x6)           # 0x00432023 | Overwrite mem[0x000] for this test.
//bne_skip:
//    # PC: 0x000001F8 (No instruction here)

//    # BLT (Branch Less Than - Signed)
//    addi x25, x0, 5         # 0x00500c93 | x25 = 5
//    addi x26, x0, 10        # 0x00a00d13 | x26 = 10
//    # Branch offset: Target - Current PC = blt_taken - (PC of blt instruction)
//    # blt_taken: 0x0000020C
//    # PC of blt: 0x00000200
//    # Offset = 0x20C - 0x200 = 0xC
//    # Encoding for offset 0xC, funct3=100 (BLT):
//    # imm[12]=0, imm[10:5]=0b000001, imm[4:1]=0b100, imm[11]=0
//    # Encoded: 0 | 000001 | 11010(x26) | 11001(x25) | 100 | 0100 | 0 | 0110011
//    # = 0x006d9a63
//    blt x25, x26, blt_taken # 0x006d9a63 | Should branch (5 < 10)

//    # Dummy
//    # PC: 0x00000204
//    # 0x3333 (LUI/ADDI construction)
//    lui x27, 0x3            # 0x00003db7 | x27 = 0x00003000
//    addi x27, x27, 0x333    # 0x333d8db3 | x27 = 0x00003333 (Corrected way to load 0x3333)

//blt_taken:
//    # PC: 0x0000020C
//    addi x28, x0, 5         # 0x00500e13 | Flag for branch taken
//    sw x28, 4(x6)           # 0x00532223 | Overwrite mem[0x004] for this test.

//    addi x25, x0, 10        # 0x00a00c93 | x25 = 10
//    addi x26, x0, 5         # 0x00500d13 | x26 = 5
//    # Branch offset: Target - Current PC = blt_skip - (PC of blt instruction)
//    # blt_skip: 0x00000220
//    # PC of blt: 0x00000218
//    # Offset = 0x220 - 0x218 = 0x8
//    # Encoding for offset 0x8, funct3=100 (BLT): 0x006d9c63
//    blt x25, x26, blt_skip  # 0x006d9c63 | Should NOT branch (10 < 5)

//    addi x29, x0, 6         # 0x00600e93 | Flag for branch not taken
//    sw x29, 8(x6)           # 0x00632423 | Overwrite mem[0x008] for this test.
//blt_skip:
//    # PC: 0x00000220 (No instruction here)

//    # BGE (Branch Greater Than or Equal - Signed)
//    addi x25, x0, 10        # 0x00a00c93 | x25 = 10
//    addi x26, x0, 5         # 0x00500d13 | x26 = 5
//    # Branch offset: Target - Current PC = bge_taken - (PC of bge instruction)
//    # bge_taken: 0x00000234
//    # PC of bge: 0x00000228
//    # Offset = 0x234 - 0x228 = 0xC
//    # Encoding for offset 0xC, funct3=101 (BGE):
//    # imm[12]=0, imm[10:5]=0b000001, imm[4:1]=0b100, imm[11]=0
//    # Encoded: 0 | 000001 | 11010(x26) | 11001(x25) | 101 | 0100 | 0 | 0110011
//    # = 0x006d9a63
//    # Wait, BGE has funct3=101, so it's 0x006d9e63
//    bge x25, x26, bge_taken # 0x006d9e63 | Should branch (10 >= 5)

//    # Dummy
//    # PC: 0x0000022C
//    # 0x4444 (LUI/ADDI construction)
//    lui x27, 0x4            # 0x00004db7 | x27 = 0x00004000
//    addi x27, x27, 0x444    # 0x444d8db3 | x27 = 0x00004444 (Corrected way to load 0x4444)

//bge_taken:
//    # PC: 0x00000234
//    addi x28, x0, 7         # 0x00700e13 | Flag for branch taken
//    sw x28, 12(x6)          # 0x00732623 | Overwrite mem[0x00C] for this test.

//    addi x25, x0, 5         # 0x00500c93 | x25 = 5
//    addi x26, x0, 10        # 0x00a00d13 | x26 = 10
//    # Branch offset: Target - Current PC = bge_skip - (PC of bge instruction)
//    # bge_skip: 0x00000248
//    # PC of bge: 0x00000240
//    # Offset = 0x248 - 0x240 = 0x8
//    # Encoding for offset 0x8, funct3=101 (BGE): 0x006d9e63
//    bge x25, x26, bge_skip  # 0x006d9e63 | Should NOT branch (5 >= 10)

//    addi x29, x0, 8         # 0x00800e93 | Flag for branch not taken
//    sw x29, 16(x6)          # 0x00832823 | Overwrite mem[0x010] for this test.
//bge_skip:
//    # PC: 0x00000248 (No instruction here)

//    # BLTU (Branch Less Than Unsigned)
//    addi x25, x0, 5         # 0x00500c93 | x25 = 5
//    addi x26, x0, -1        # 0xfff00d13 | x26 = 0xFFFFFFFF
//    # Branch offset: Target - Current PC = bltu_taken - (PC of bltu instruction)
//    # bltu_taken: 0x0000025C
//    # PC of bltu: 0x00000250
//    # Offset = 0x25C - 0x250 = 0xC
//    # Encoding for offset 0xC, funct3=110 (BLTU):
//    # imm[12]=0, imm[10:5]=0b000001, imm[4:1]=0b100, imm[11]=0
//    # Encoded: 0 | 000001 | 11010(x26) | 11001(x25) | 110 | 0100 | 0 | 0110011
//    # = 0x006d9c63
//    bltu x25, x26, bltu_taken # 0x006d9c63 | Should branch (5 < 0xFFFFFFFF unsigned)

//    # Dummy
//    # PC: 0x00000254
//    # 0x5555 (LUI/ADDI construction)
//    lui x27, 0x5            # 0x00005db7 | x27 = 0x00005000
//    addi x27, x27, 0x555    # 0x555d8db3 | x27 = 0x00005555 (Corrected way to load 0x5555)
//bltu_taken:
//    # PC: 0x0000025C
//    addi x28, x0, 9         # 0x00900e13 | Flag for branch taken
//    sw x28, 20(x6)          # 0x00932a23 | Overwrite mem[0x014] for this test.

//    addi x25, x0, -1        # 0xfff00c93 | x25 = 0xFFFFFFFF
//    addi x26, x0, 5         # 0x00500d13 | x26 = 5
//    # Branch offset: Target - Current PC = bltu_skip - (PC of bltu instruction)
//    # bltu_skip: 0x00000270
//    # PC of bltu: 0x00000268
//    # Offset = 0x270 - 0x268 = 0x8
//    # Encoding for offset 0x8, funct3=110 (BLTU): 0x006d9c63
//    bltu x25, x26, bltu_skip # 0x006d9c63 | Should NOT branch (0xFFFFFFFF < 5 unsigned)

//    addi x29, x0, 10        # 0x00a00e93 | Flag for branch not taken
//    sw x29, 24(x6)          # 0x00a32c23 | Overwrite mem[0x018] for this test.
//bltu_skip:
//    # PC: 0x00000270 (No instruction here)

//    # BGEU (Branch Greater Than or Equal Unsigned)
//    addi x25, x0, -1        # 0xfff00c93 | x25 = 0xFFFFFFFF
//    addi x26, x0, 5         # 0x00500d13 | x26 = 5
//    # Branch offset: Target - Current PC = bgeu_taken - (PC of bgeu instruction)
//    # bgeu_taken: 0x00000284
//    # PC of bgeu: 0x00000278
//    # Offset = 0x284 - 0x278 = 0xC
//    # Encoding for offset 0xC, funct3=111 (BGEU):
//    # imm[12]=0, imm[10:5]=0b000001, imm[4:1]=0b100, imm[11]=0
//    # Encoded: 0 | 000001 | 11010(x26) | 11001(x25) | 111 | 0100 | 0 | 0110011
//    # = 0x006d9d63
//    bgeu x25, x26, bgeu_taken # 0x006d9d63 | Should branch (0xFFFFFFFF >= 5 unsigned)

//    # Dummy
//    # PC: 0x0000027C
//    # 0x6666 (LUI/ADDI construction)
//    lui x27, 0x6            # 0x00006db7 | x27 = 0x00006000
//    addi x27, x27, 0x666    # 0x666d8db3 | x27 = 0x00006666 (Corrected way to load 0x6666)
//bgeu_taken:
//    # PC: 0x00000284
//    addi x28, x0, 11        # 0x00b00e13 | Flag for branch taken
//    sw x28, 28(x6)          # 0x00b32e23 | Overwrite mem[0x01C] for this test.

//    addi x25, x0, 5         # 0x00500c93 | x25 = 5
//    addi x26, x0, -1        # 0xfff00d13 | x26 = 0xFFFFFFFF
//    # Branch offset: Target - Current PC = bgeu_skip - (PC of bgeu instruction)
//    # bgeu_skip: 0x00000298
//    # PC of bgeu: 0x00000290
//    # Offset = 0x298 - 0x290 = 0x8
//    # Encoding for offset 0x8, funct3=111 (BGEU): 0x006d9d63
//    bgeu x25, x26, bgeu_skip # 0x006d9d63 | Should NOT branch (5 >= 0xFFFFFFFF unsigned)

//    addi x29, x0, 12        # 0x00c00e93 | Flag for branch not taken
//    sw x29, 32(x6)          # 0x00c32023 | Overwrite mem[0x020] for this test.
//bgeu_skip:
//    # PC: 0x00000298 (No instruction here)


//    # --- End of Program ---
//    # PC: 0x00000298
//    # Infinite loop to halt simulation.
//end_program:
//    jal x0, end_program     # 0x0000006f | j end_program (pseudo-op for jal x0, offset)
//                            # Offset from 0x298 to 0x298 is 0.
//                            # J-type encoding for offset 0: 0x0000006f




    
        // Terminate assembly with EBREAK
        //EBREAK();

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
