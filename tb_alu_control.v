`timescale 1ns / 1ps

module tb_alu_control;

    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire [3:0] ALU_Control;

    alu_control uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALU_Control(ALU_Control)
    );

    initial begin

        // ADD
        ALUOp = 2'b10;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // SUB
        ALUOp = 2'b10;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;

        // AND
        ALUOp = 2'b10;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #10;

        // OR
        ALUOp = 2'b10;
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        #10;

        // ADDI / LW / SW
        ALUOp = 2'b00;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // BEQ
        ALUOp = 2'b01;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        $finish;

    end

endmodule