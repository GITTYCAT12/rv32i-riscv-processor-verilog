`timescale 1ns / 1ps

module tb_next_pc_mux;
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
        pc_sel = 1'b0;
        #1;
        if (next_pc !== 32'h00000004)
            $fatal(1, "FAIL: sequential selection expected 0x00000004, got 0x%08h", next_pc);

        // The mux must remain combinational when the selected input changes.
        pc_plus_4 = 32'h00000100;
        #1;
        if (next_pc !== 32'h00000100)
            $fatal(1, "FAIL: updated sequential input was not propagated");

        pc_sel = 1'b1;
        #1;
        if (next_pc !== 32'h00000050)
            $fatal(1, "FAIL: target selection expected 0x00000050, got 0x%08h", next_pc);

        target_pc = 32'h00000084;
        #1;
        if (next_pc !== 32'h00000084)
            $fatal(1, "FAIL: updated target input was not propagated");

        $display("PASS: next-PC mux selection test completed.");
        $finish;
    end
endmodule
