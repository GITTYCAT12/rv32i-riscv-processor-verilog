`timescale 1ns / 1ps

module tb_immediate_generator;

    reg [31:0] instruction;
    reg [1:0] immediate_type;

    wire [31:0] immediate;

    immediate_generator uut (
        .instruction(instruction),
        .immediate_type(immediate_type),
        .immediate(immediate)
    );

    initial begin

        // I-type example
        // ADDI x1, x0, 1
        instruction = 32'h00100093;
        immediate_type = 2'b00;

        #10;

        // I-type negative immediate
        instruction = 32'hFFF00093;
        immediate_type = 2'b00;

        #10;

        // S-type example
        instruction = 32'h00102023;
        immediate_type = 2'b01;

        #10;

        // B-type example
        instruction = 32'h00000063;
        immediate_type = 2'b10;

        #10;

        $finish;

    end

endmodule