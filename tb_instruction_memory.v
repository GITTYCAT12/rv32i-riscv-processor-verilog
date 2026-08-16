`timescale 1ns / 1ps

module tb_instruction_memory;

    reg [31:0] address;
    wire [31:0] instruction;

    instruction_memory uut (
        .address(address),
        .instruction(instruction)
    );

    initial begin

        address = 32'h00000000;
        #10;

        address = 32'h00000004;
        #10;

        address = 32'h00000008;
        #10;

        address = 32'h0000000C;
        #10;

        $finish;

    end

endmodule 
