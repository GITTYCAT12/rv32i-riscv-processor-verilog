`timescale 1ns / 1ps

module tb_riscv_core;

    reg clk;
    reg reset;

    wire [31:0] debug_pc;
    wire [31:0] debug_instruction;
    wire [31:0] debug_alu_result;

    // ------------------------------------------------
    // DUT
    // ------------------------------------------------

    riscv_core uut (
        .clk              (clk),
        .reset            (reset),
        .debug_pc         (debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result (debug_alu_result)
    );

    // ------------------------------------------------
    // Clock
    // 10 ns period = 100 MHz
    // ------------------------------------------------

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ------------------------------------------------
    // Reset + simulation
    // ------------------------------------------------

    initial begin

        reset = 1'b1;

        // Hold reset for 20 ns
        #20;

        reset = 1'b0;

        // Run processor
        #300;

        $display("-----------------------------------------");
        $display("Simulation completed");
        $display("-----------------------------------------");

        $finish;

    end

    // ------------------------------------------------
    // Monitor
    // ------------------------------------------------

    always @(posedge clk) begin

        $display(
            "Time=%0t | PC=%h | Instruction=%h",
            $time,
            debug_pc,
            debug_instruction
        );

    end

    // ------------------------------------------------
    // Generate waveform
    // ------------------------------------------------

    initial begin

        $dumpfile("riscv_core.vcd");

        $dumpvars(0, tb_riscv_core);

    end

endmodule
