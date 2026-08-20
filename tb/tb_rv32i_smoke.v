`timescale 1ns/1ps

// Lightweight processor-level smoke-test scaffold.
// The testbench is intentionally kept independent of a specific core port list
// so the verification suite can be extended as the top-level interface evolves.
module tb_rv32i_smoke;

    initial begin
        $display("RV32I processor smoke-test scaffold");
        $display("Verification focus: arithmetic, memory, branch and write-back paths");
        $display("TODO: connect the current riscv_top interface and add self-checking assertions.");
        #1;
        $finish;
    end

endmodule
