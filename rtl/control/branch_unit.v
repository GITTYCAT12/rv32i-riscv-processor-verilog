`timescale 1ns / 1ps

module branch_unit(
    input [2:0] funct3,
    input branch,
    input jump,
    input is_jalr,
    input [31:0] pc,
    input [31:0] imm,
    input [31:0] rs1,
    input zero,
    input sign,
    input overflow,
    input carry,
    output reg pc_sel,
    output [31:0] target_pc
);

assign target_pc = is_jalr ?
                   ((rs1 + imm) & 32'hFFFFFFFE) :
                   (pc + imm);

always @(*) begin

    pc_sel = 1'b0;

    if (jump) begin
        pc_sel = 1'b1;
    end

    else if (branch) begin

        case (funct3)

            3'b000: begin
                // BEQ
                pc_sel = zero;
            end

            3'b001: begin
                // BNE
                pc_sel = ~zero;
            end

            3'b100: begin
                // BLT
                pc_sel = sign ^ overflow;
            end

            3'b101: begin
                // BGE
                pc_sel = ~(sign ^ overflow);
            end

            3'b110: begin
                // BLTU
                pc_sel = ~carry;
            end

            3'b111: begin
                // BGEU
                pc_sel = carry;
            end

            default: begin
                pc_sel = 1'b0;
            end

        endcase
    end

end

endmodule