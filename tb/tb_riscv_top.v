`timescale 1ns / 1ps

module tb_riscv_top;

reg clk;
reg reset;

wire [31:0] debug_pc;
wire [31:0] debug_instruction;
wire [31:0] debug_alu_result;

riscv_top dut (
    .clk(clk),
    .reset(reset),
    .debug_pc(debug_pc),
    .debug_instruction(debug_instruction),
    .debug_alu_result(debug_alu_result)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;

    #20;

    reset = 0;

    #500;

    $finish;
end

initial begin
    $monitor("Time=%0t Reset=%b PC=%h Instruction=%h ALU_Result=%h",
             $time,
             reset,
             debug_pc,
             debug_instruction,
             debug_alu_result);
end

endmodule