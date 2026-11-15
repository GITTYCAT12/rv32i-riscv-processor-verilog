`timescale 1ns / 1ps

module tb_immediate_generator;

    reg [31:0] instruction;
    reg [1:0] immediate_type;
    wire [31:0] immediate;
    integer failures;

    immediate_generator uut (
        .instruction(instruction),
        .immediate_type(immediate_type),
        .immediate(immediate)
    );

    task check_case;
        input [31:0] test_instruction;
        input [1:0] test_type;
        input [31:0] expected;
        begin
            instruction = test_instruction;
            immediate_type = test_type;
            #1;
            if (immediate !== expected) begin
                $display("FAIL: type=%b instruction=%08h expected=%08h got=%08h",
                         test_type, test_instruction, expected, immediate);
                failures = failures + 1;
            end else begin
                $display("PASS: type=%b instruction=%08h immediate=%08h",
                         test_type, test_instruction, immediate);
            end
        end
    endtask

    initial begin
        failures = 0;

        // I-type: positive, negative, and minimum signed 12-bit values.
        check_case(32'h00100093, 2'b00, 32'h00000001);
        check_case(32'hFFF00093, 2'b00, 32'hFFFFFFFF);
        check_case(32'h80000000, 2'b00, 32'hFFFFF800);

        // S-type: largest positive and a negative offset.
        check_case(32'h7E000F80, 2'b01, 32'h000007FF);
        check_case(32'hFE000800, 2'b01, 32'hFFFFFFF0);

        // B-type: positive and negative, including the implicit low zero bit.
        check_case(32'h00000400, 2'b10, 32'h00000008);
        check_case(32'hFE000E80, 2'b10, 32'hFFFFFFFC);

        // Unsupported immediate type has a deterministic zero default.
        check_case(32'hFFFFFFFF, 2'b11, 32'h00000000);

        if (failures == 0)
            $display("PASS: immediate generator signed-encoding tests completed.");
        else
            $display("FAIL: immediate generator found %0d error(s).", failures);

        if (failures != 0)
            $finish(1);

        $finish;
    end

endmodule
