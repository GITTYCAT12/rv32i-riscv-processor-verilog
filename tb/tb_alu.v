`timescale 1ns / 1ps

module tb_alu;

    reg [31:0] A;
    reg [31:0] B;
    reg [1:0] ALU_Sel;

    wire [31:0] Result;

    alu uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .Result(Result)
    );

    initial begin

        // ADD
        A = 10;
        B = 5;
        ALU_Sel = 2'b00;
        #10;

        // SUB
        A = 10;
        B = 5;
        ALU_Sel = 2'b01;
        #10;

        // AND
        A = 4'b1010;
        B = 4'b1100;
        ALU_Sel = 2'b10;
        #10;

        // OR
        A = 4'b1010;
        B = 4'b1100;
        ALU_Sel = 2'b11;
        #10;

        $finish;
    end

endmodule