`timescale 1ns / 1ps

module tb_pc_adder();
    reg [31:0] pc;
    wire [31:0] pc_plus_4;

    pc_adder uut (
        .pc(pc),
        .pc_plus_4(pc_plus_4)
    );

    initial begin
        pc = 32'h00000000;
        #10;
        pc = 32'h00000004;
        #10;
        pc = 32'h00000028;
        #10;
        $finish;
    end
endmodule