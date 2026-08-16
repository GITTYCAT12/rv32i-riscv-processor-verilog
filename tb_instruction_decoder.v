`timescale 1ns / 1ps

module tb_instruction_decoder;

    reg [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;

    instruction_decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    initial begin

        // ADDI x1, x0, 1
        instruction = 32'h00100093;
        #10;

        // ADDI x2, x0, 2
        instruction = 32'h00200113;
        #10;

        // ADDI x3, x1, 3
        instruction = 32'h00308193;
        #10;

        $finish;

    end

endmodule