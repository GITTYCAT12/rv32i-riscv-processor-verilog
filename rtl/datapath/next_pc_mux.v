`timescale 1ns / 1ps

module next_pc_mux (
    input pc_sel,
    input [31:0] pc_plus_4,
    input [31:0] target_pc,
    output [31:0] next_pc
);

    assign next_pc = pc_sel ? target_pc : pc_plus_4;

endmodule