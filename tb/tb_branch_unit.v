`timescale 1ns / 1ps

module tb_branch_unit();

    reg [2:0]  funct3;
    reg        branch;
    reg        jump;
    reg        is_jalr;
    reg [31:0] pc;
    reg [31:0] imm;
    reg [31:0] rs1;
    reg        zero;
    reg        sign;
    reg        overflow;
    reg        carry;

    wire        pc_sel;
    wire [31:0] target_pc;

    branch_unit uut (
        .funct3(funct3),
        .branch(branch),
        .jump(jump),
        .is_jalr(is_jalr),
        .pc(pc),
        .imm(imm),
        .rs1(rs1),
        .zero(zero),
        .sign(sign),
        .overflow(overflow),
        .carry(carry),
        .pc_sel(pc_sel),
        .target_pc(target_pc)
    );

    initial begin
        funct3   = 3'b000;
        branch   = 1'b0;
        jump     = 1'b0;
        is_jalr  = 1'b0;
        pc       = 32'h00000000; 
        imm      = 32'h00000010; 
        rs1      = 32'h00000100;
        zero     = 1'b0;
        sign     = 1'b0;
        overflow = 1'b0;
        carry    = 1'b0;
        #10;

        jump = 1'b1;
        #10;
        
        jump = 1'b0;

        branch = 1'b1; 
        funct3 = 3'b000; 
        zero   = 1'b1;
        #10;

        zero = 1'b0;
        #10;

        branch  = 1'b0; 
        jump    = 1'b1; 
        is_jalr = 1'b1;
        #10;

        $finish;
    end

endmodule