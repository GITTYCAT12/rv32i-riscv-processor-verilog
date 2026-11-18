// Top-level self-checking smoke test for the current RV32I program.
// The instruction memory contains a directed program covering arithmetic,
// load/store, a taken BEQ, and write-back/flush behavior.
module tb_rv32i_smoke;

    reg clk;
    reg reset;
    integer failures;
    integer load_use_ex_cycles;
    integer load_use_mem_cycles;
    reg [31:0] stalled_pc;
    reg [31:0] stalled_instruction;

    riscv_core dut (
        .clk               (clk),
        .reset             (reset),
        .debug_pc          (),
        .debug_instruction (),
        .debug_alu_result  ()
    );

    // 100 MHz clock.
    always #5 clk = ~clk;

    // The directed LW x7 -> BEQ x3,x7 dependency must hold fetch/decode
    // while the load advances through EX and MEM, inserting an ID/EX bubble.
    always @(posedge clk) begin
        if (!reset && dut.load_use_hazard) begin
            if (dut.load_use_hazard_ex)
                load_use_ex_cycles = load_use_ex_cycles + 1;
            if (dut.load_use_hazard_mem)
                load_use_mem_cycles = load_use_mem_cycles + 1;

            stalled_pc = dut.pc;
            stalled_instruction = dut.if_id_instr;
            #1;

            if (dut.pc !== stalled_pc) begin
                $display("FAIL: PC changed during load-use stall");
                failures = failures + 1;
            end
            if (dut.if_id_instr !== stalled_instruction) begin
                $display("FAIL: IF/ID instruction changed during load-use stall");
                failures = failures + 1;
            end
            if (dut.id_ex_valid !== 1'b0) begin
                $display("FAIL: ID/EX did not receive a bubble during load-use stall");
                failures = failures + 1;
            end
        end
    end

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
        clk                  = 1'b0;
        reset                = 1'b1;
        failures             = 0;
        load_use_ex_cycles  = 0;
        load_use_mem_cycles = 0;

        // Inject an unsupported R-type funct7 encoding at a later instruction
        // address. With no illegal-instruction trap implemented, it must not
        // commit a register write.
        #1;
        dut.imem.memory[15] = 32'h02208533; // ADD x10,x1,x2 with funct7=0000001
        dut.imem.memory[11] = 32'h00109713; // SLLI x14,x1,1 -> 10
        dut.imem.memory[12] = 32'h00115793; // SRLI x15,x2,1 -> 5
        dut.imem.memory[13] = 32'h40115813; // SRAI x16,x2,1 -> 5
        dut.imem.memory[16] = 32'h02109593; // Reserved SLLI funct7=0000001
        dut.imem.memory[17] = 32'h4210D613; // Reserved SRAI funct7=0100001
        dut.imem.memory[18] = 32'h000016E7; // Reserved JALR funct3=001 must not jump/write x13
        dut.imem.memory[19] = 32'h04D00893; // ADDI x17,x0,77 proves sequential execution continues

        // Reset the processor and register file.
        #19;
        reset = 1'b0;

        // Allow the 5-stage pipeline to retire the program and settle.
        #400;

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

        // The immediate load-use dependency must stall once in EX and once in
        // MEM; the branch then consumes x7 and flushes the following ADDI.
        if (load_use_ex_cycles != 1) begin
            $display("FAIL: expected one EX-stage load-use stall, got %0d", load_use_ex_cycles);
            failures = failures + 1;
        end
        if (load_use_mem_cycles != 1) begin
            $display("FAIL: expected one MEM-stage load-use stall, got %0d", load_use_mem_cycles);
            failures = failures + 1;
        end

        // Taken BEQ must flush the following ADDI x8,x0,99.
        check_reg(5'd8, 32'd0);
        check_reg(5'd9, 32'd42);
        check_reg(5'd10, 32'd0);
        // Legal shift-immediate encodings retain their expected results.
        check_reg(5'd14, 32'd10);
        check_reg(5'd15, 32'd5);
        check_reg(5'd16, 32'd5);

        // Reserved shift-immediate encodings follow this core's no-write policy.
        check_reg(5'd11, 32'd0);
        check_reg(5'd12, 32'd0);
        // Reserved JALR funct3 follows the no-write/no-jump policy; the next
        // sequential instruction must still execute.
        check_reg(5'd13, 32'd0);
        check_reg(5'd17, 32'd77);

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
