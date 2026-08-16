`timescale 1ns / 1ps

module tb_next_pc_mux();
    reg pc_sel;
    reg [31:0] pc_plus_4;
    reg [31:0] target_pc;
    wire [31:0] next_pc;

    next_pc_mux uut (
        .pc_sel(pc_sel),
        .pc_plus_4(pc_plus_4),
        .target_pc(target_pc),
        .next_pc(next_pc)
    );

    initial begin
        pc_plus_4 = 32'h00000004;
        target_pc = 32'h00000050;

        pc_sel = 1'b0; // Should choose pc_plus_4
        #10;

        pc_sel = 1'b1; // Should choose target_pc
        #10;

        $finish;
    end
endmodule