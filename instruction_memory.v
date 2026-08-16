`timescale 1ns / 1ps

module instruction_memory (
    input wire [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013; // NOP

        memory[0]  = 32'h00500093; // ADDI x1,x0,5
        memory[1]  = 32'h00A00113; // ADDI x2,x0,10
        memory[2]  = 32'h002081B3; // ADD x3,x1,x2
        memory[3]  = 32'h40110233; // SUB x4,x2,x1
        memory[4]  = 32'h0020F2B3; // AND x5,x1,x2
        memory[5]  = 32'h0020E333; // OR x6,x1,x2
        memory[6]  = 32'h00302023; // SW x3,0(x0)
        memory[7]  = 32'h00002383; // LW x7,0(x0)
        memory[8]  = 32'h00718463; // BEQ x3,x7,+8 (skip next)
        memory[9]  = 32'h06300413; // ADDI x8,x0,99 (must be flushed)
        memory[10] = 32'h02A00493; // ADDI x9,x0,42
        memory[11] = 32'h00000013; // NOP
        memory[12] = 32'h00000013; // NOP
        memory[13] = 32'h00000013; // NOP
        memory[14] = 32'h00000013; // NOP
        memory[15] = 32'h00000013; // NOP
    end

    always @(*) begin
        instruction = memory[address[9:2]];
    end

endmodule
