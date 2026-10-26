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

    task check_fields;
        input [31:0] encoded_instruction;
        input [6:0] expected_opcode;
        input [4:0] expected_rd;
        input [4:0] expected_rs1;
        input [4:0] expected_rs2;
        input [2:0] expected_funct3;
        input [6:0] expected_funct7;
        begin
            instruction = encoded_instruction;
            #1;
            if ({opcode, rd, rs1, rs2, funct3, funct7} !==
                {expected_opcode, expected_rd, expected_rs1, expected_rs2, expected_funct3, expected_funct7}) begin
                $display("FAIL: instruction %h decoded to unexpected fields", encoded_instruction);
                $fatal(1);
            end
        end
    endtask

    initial begin
        check_fields(32'h00100093, 7'h13, 5'd1, 5'd0, 5'd1, 3'd0, 7'd0);
        check_fields(32'h00200113, 7'h13, 5'd2, 5'd0, 5'd2, 3'd0, 7'd0);
        check_fields(32'h00308193, 7'h13, 5'd3, 5'd1, 5'd3, 3'd0, 7'd0);
        $display("PASS: instruction decoder field extraction.");
        $finish;
    end
endmodule
