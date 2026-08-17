`timescale 1ns / 1ps

module tb_riscv_core;

    reg clk;
    reg reset;

    // ------------------------------------------------
    // DUT
    // ------------------------------------------------

    riscv_core uut (
        .clk   (clk),
        .reset (reset)
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
            uut.current_pc,
            uut.instruction
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