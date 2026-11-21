// Top-level self-checking smoke test for the current RV32I program.
// The instruction memory contains directed arithmetic, load/store, branch,
// load-use interlock, and ALU-forwarding scenarios.
module tb_rv32i_smoke;

    reg clk;
    reg reset;
    integer failures;
    integer load_use_ex_cycles;
    integer load_use_mem_cycles;
    integer ex_mem_forward_checks;
    integer mem_wb_forward_checks;
    integer store_forward_checks;
    integer store_data_checks;
    integer store_dependency_stall_cycles;
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

    // An ADDI producer immediately followed by SW must not trigger a stall.
    // The store consumes x23 from the EX/MEM forwarding path.
    always @(posedge clk) begin
        if (!reset && dut.id_ex_valid && dut.id_ex_pc == 32'd100 &&
            dut.if_id_valid && dut.if_id_pc == 32'd104 &&
            dut.load_use_hazard) begin
            store_dependency_stall_cycles = store_dependency_stall_cycles + 1;
        end
    end

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

    // Sample forwarding after the rising-edge pipeline-register updates.
    // PCs 84 and 88 consume the immediately preceding ALU result from EX/MEM.
    // PC 92 consumes x19 after one independent instruction, from MEM/WB.
    always @(negedge clk) begin
        if (!reset && dut.id_ex_valid) begin
            case (dut.id_ex_pc)
                32'd84: begin
                    if (dut.ex_mem_reg_write !== 1'b1 ||
                        dut.ex_mem_mem_read !== 1'b0 ||
                        dut.ex_mem_rd !== 5'd18 ||
                        dut.ex_forward_a !== 32'd7) begin
                        $display("FAIL: EX/MEM forwarding for PC 84 was incorrect");
                        failures = failures + 1;
                    end else begin
                        ex_mem_forward_checks = ex_mem_forward_checks + 1;
                    end
                end

                32'd88: begin
                    if (dut.ex_mem_reg_write !== 1'b1 ||
                        dut.ex_mem_mem_read !== 1'b0 ||
                        dut.ex_mem_rd !== 5'd19 ||
                        dut.ex_forward_a !== 32'd10) begin
                        $display("FAIL: EX/MEM forwarding for PC 88 was incorrect");
                        failures = failures + 1;
                    end else begin
                        ex_mem_forward_checks = ex_mem_forward_checks + 1;
                    end
                end

                32'd92: begin
                    if (dut.mem_wb_reg_write !== 1'b1 ||
                        dut.mem_wb_rd !== 5'd19 ||
                        dut.ex_forward_a !== 32'd10) begin
                        $display("FAIL: MEM/WB forwarding for PC 92 was incorrect");
                        failures = failures + 1;
                    end else begin
                        mem_wb_forward_checks = mem_wb_forward_checks + 1;
                    end
                end

                32'd104: begin
                    if (dut.ex_mem_reg_write !== 1'b1 ||
                        dut.ex_mem_mem_read !== 1'b0 ||
                        dut.ex_mem_rd !== 5'd23 ||
                        dut.ex_forward_b !== 32'd85) begin
                        $display("FAIL: EX/MEM store-data forwarding for PC 104 was incorrect");
                        failures = failures + 1;
                    end else begin
                        store_forward_checks = store_forward_checks + 1;
                    end
                end

                default: begin
                end
            endcase
        end

        if (!reset && dut.ex_mem_valid && dut.ex_mem_mem_write &&
            dut.ex_mem_alu_result == 32'd4) begin
            if (dut.ex_mem_store_data !== 32'd85) begin
                $display("FAIL: store data captured 0x%08h instead of 0x00000055",
                         dut.ex_mem_store_data);
                failures = failures + 1;
            end else begin
                store_data_checks = store_data_checks + 1;
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
        clk                   = 1'b0;
        reset                 = 1'b1;
        failures              = 0;
        load_use_ex_cycles    = 0;
        load_use_mem_cycles   = 0;
        ex_mem_forward_checks = 0;
        mem_wb_forward_checks = 0;
        store_forward_checks = 0;
        store_data_checks = 0;
        store_dependency_stall_cycles = 0;

        // Inject unsupported encodings and directed dependency instructions.
        #1;
        dut.imem.memory[15] = 32'h02208533; // ADD x10,x1,x2 with funct7=0000001
        dut.imem.memory[11] = 32'h00109713; // SLLI x14,x1,1 -> 10
        dut.imem.memory[12] = 32'h00115793; // SRLI x15,x2,1 -> 5
        dut.imem.memory[13] = 32'h40115813; // SRAI x16,x2,1 -> 5
        dut.imem.memory[16] = 32'h02109593; // Reserved SLLI funct7=0000001
        dut.imem.memory[17] = 32'h4210D613; // Reserved SRAI funct7=0100001
        dut.imem.memory[18] = 32'h000016E7; // Reserved JALR funct3=001 must not jump/write x13
        dut.imem.memory[19] = 32'h04D00893; // ADDI x17,x0,77 proves sequential execution continues

        // Back-to-back ALU dependencies exercise EX/MEM forwarding.
        dut.imem.memory[20] = 32'h00700913; // ADDI x18,x0,7
        dut.imem.memory[21] = 32'h00390993; // ADDI x19,x18,3 -> 10
        dut.imem.memory[22] = 32'h00598A13; // ADDI x20,x19,5 -> 15
        // One independent instruction separates the x19 producer and consumer.
        dut.imem.memory[23] = 32'h00298A93; // ADDI x21,x19,2 -> 12 (MEM/WB)
        dut.imem.memory[24] = 32'h00100B13; // ADDI x22,x0,1
        // Immediate ALU-to-store dependency exercises EX/MEM forwarding of rs2.
        dut.imem.memory[25] = 32'h05500B93; // ADDI x23,x0,85
        dut.imem.memory[26] = 32'h01702223; // SW x23,4(x0) -> memory[1]=85

        // Reset the processor and register file.
        #19;
        reset = 1'b0;

        // Allow the 5-stage pipeline to retire the program and settle.
        #500;

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
        if (dut.dmem.memory[1] !== 32'd85) begin
            $display("FAIL: memory[1] expected 85 (0x00000055), got %0d (0x%08h)",
                     dut.dmem.memory[1], dut.dmem.memory[1]);
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

        // The two adjacent dependencies must use EX/MEM; the dependency with
        // one independent instruction must use MEM/WB.
        if (ex_mem_forward_checks != 2) begin
            $display("FAIL: expected two EX/MEM forwarding checks, got %0d", ex_mem_forward_checks);
            failures = failures + 1;
        end
        if (mem_wb_forward_checks != 1) begin
            $display("FAIL: expected one MEM/WB forwarding check, got %0d", mem_wb_forward_checks);
            failures = failures + 1;
        end
        if (store_forward_checks != 1) begin
            $display("FAIL: expected one EX/MEM store-data forwarding check, got %0d", store_forward_checks);
            failures = failures + 1;
        end
        if (store_data_checks != 1) begin
            $display("FAIL: expected one forwarded store-data capture, got %0d", store_data_checks);
            failures = failures + 1;
        end
        if (store_dependency_stall_cycles != 0) begin
            $display("FAIL: store dependency incurred %0d unnecessary stall cycle(s)",
                     store_dependency_stall_cycles);
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

        // Forwarded ALU dependencies must produce their architectural values.
        check_reg(5'd18, 32'd7);
        check_reg(5'd19, 32'd10);
        check_reg(5'd20, 32'd15);
        check_reg(5'd21, 32'd12);
        check_reg(5'd22, 32'd1);
        check_reg(5'd23, 32'd85);

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
