`timescale 1ns / 1ps

module riscv_top (
    input wire clk,
    input wire reset,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_instruction,
    output wire [31:0] debug_alu_result
);

    // =========================================================
    // RISC-V PROCESSOR
    // =========================================================

    riscv_core core (
        .clk              (clk),
        .reset            (reset),

        .debug_pc         (debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result (debug_alu_result)
    );

endmodule