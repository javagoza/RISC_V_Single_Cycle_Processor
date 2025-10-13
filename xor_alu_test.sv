`timescale 1ns / 1ps
module xor_alu_test;
  logic [31:0] a_tb = 32'h00000123;
  logic [31:0] b_tb = 32'h00000ABC;
  logic [3:0] alucontrol_tb = 4'b0100;
  logic [31:0] result_tb;
  logic [3:0] flags_tb;

  alu u_alu (
    .a(a_tb),
    .b(b_tb),
    .alucontrol(alucontrol_tb),
    .result(result_tb),
    .flags(flags_tb)
  );

  initial begin
    $monitor("a: %h, b: %h, alucontrol: %b, result: %h", a_tb, b_tb, alucontrol_tb, result_tb);
    #10; // Let combinational logic settle
    $finish;
  end
endmodule