// Top-level self-checking smoke test for the current RV32I program.
// The instruction memory contains a directed program covering arithmetic,
// load/store, a taken BEQ, and write-back/flush behavior.
module tb_rv32i_smoke;

    reg clk;
    reg reset;
    integer failures;

    riscv_core dut (
        .clk               (clk),
        .reset             (reset),
        .debug_pc          (),
        .debug_instruction (),
        .debug_alu_result  ()
    );

    // 100 MHz clock.
    always #5 clk = ~clk;

    task check_reg;
        input [4:0] reg_index;
        input [31:0] expected;
        begin
            if (dut.rf.registers[reg_index] !== expected) begin
                $display("FAIL: x%0d expected %0d (0x%08h), got %0d (0x%08h)",
                         reg_index, expected, expected,
                         dut.rf.registers[reg_index], dut.rf.registers[reg_index]);
                failures = failures + 1;
            end
        end
    endtask

    initial begin
        clk      = 1'b0;
        reset    = 1'b1;
        failures = 0;

        // Reset the processor and register file.
        #20;
        reset = 1'b0;

        // Allow the 5-stage pipeline to retire the program and settle.
        #300;

        // Arithmetic: x3=5+10, x4=10-5, x5=5&10, x6=5|10.
        check_reg(5'd1, 32'd5);
        check_reg(5'd2, 32'd10);
        check_reg(5'd3, 32'd15);
        check_reg(5'd4, 32'd5);
        check_reg(5'd5, 32'd0);
        check_reg(5'd6, 32'd15);

        // Load/store path: SW x3 -> memory[0], then LW -> x7.
        check_reg(5'd7, 32'd15);
        if (dut.dmem.memory[0] !== 32'd15) begin
            $display("FAIL: memory[0] expected 15 (0x0000000f), got %0d (0x%08h)",
                     dut.dmem.memory[0], dut.dmem.memory[0]);
            failures = failures + 1;
        end

        // Taken BEQ must flush the following ADDI x8,x0,99.
        check_reg(5'd8, 32'd0);
        check_reg(5'd9, 32'd42);

        if (failures == 0)
            $display("PASS: RV32I top-level smoke test completed successfully.");
        else
            $display("FAIL: RV32I top-level smoke test found %0d error(s).", failures);

        $dumpfile("rv32i_smoke.vcd");
        $dumpvars(0, tb_rv32i_smoke);

        if (failures != 0)
            $finish(1);

        $finish;
    end

endmodule
