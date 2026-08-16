`timescale 1ns / 1ps

module tb_control_unit;

    reg [6:0] opcode;

    wire RegWrite;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire MemToReg;
    wire Branch;
    wire [1:0] ALUOp;

    control_unit uut (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    initial begin

        // R-type
        opcode = 7'b0110011;
        #10;

        // ADDI
        opcode = 7'b0010011;
        #10;

        // LW
        opcode = 7'b0000011;
        #10;

        // SW
        opcode = 7'b0100011;
        #10;

        // BEQ
        opcode = 7'b1100011;
        #10;

        // Invalid instruction
        opcode = 7'b1111111;
        #10;

        $finish;

    end

endmodule
