`timescale 1ns / 1ps

module tb_program_counter;

    reg clk;
    reg reset;
    reg [31:0] next_pc;

    wire [31:0] pc;

    program_counter uut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        next_pc = 32'h00000000;

        #10;

        reset = 0;
        next_pc = 32'h00000004;

        #10;

        next_pc = 32'h00000008;

        #10;

        next_pc = 32'h0000000C;

        #10;

        $finish;

    end

endmodule