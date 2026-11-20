`timescale 1ns / 1ps

module tb_data_memory;

    reg clk;
    reg MemRead;
    reg MemWrite;
    reg [31:0] address;
    reg [31:0] write_data;
    wire [31:0] read_data;
    integer failures;

    data_memory uut (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    task expect_read;
        input [31:0] expected;
        input [8*48-1:0] label;
        begin
            #1;
            if (read_data !== expected) begin
                $display("FAIL: %0s expected %08h, got %08h", label, expected, read_data);
                failures = failures + 1;
            end else begin
                $display("PASS: %0s", label);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        address = 32'b0;
        write_data = 32'b0;
        failures = 0;

        expect_read(32'b0, "read disabled returns zero");

        // Writes are synchronous to the rising clock edge.
        @(negedge clk);
        address = 32'h00000004;
        write_data = 32'h12345678;
        MemWrite = 1'b1;
        @(posedge clk);
        #1;
        MemWrite = 1'b0;

        @(negedge clk);
        address = 32'h00000008;
        write_data = 32'hA5A55A5A;
        MemWrite = 1'b1;
        @(posedge clk);
        #1;
        MemWrite = 1'b0;

        // Reads are combinational while MemRead is asserted.
        MemRead = 1'b1;
        address = 32'h00000004;
        expect_read(32'h12345678, "first word is readable");
        address = 32'h00000008;
        expect_read(32'hA5A55A5A, "second word is independent");

        // A clock edge with MemWrite low must not overwrite stored data.
        @(negedge clk);
        address = 32'h00000004;
        write_data = 32'hDEADBEEF;
        MemWrite = 1'b0;
        @(posedge clk);
        expect_read(32'h12345678, "write disabled preserves stored word");

        // The old value remains visible before the write edge; the new value
        // becomes visible after the synchronous memory update.
        @(negedge clk);
        address = 32'h00000004;
        write_data = 32'h87654321;
        MemWrite = 1'b1;
        expect_read(32'h12345678, "write does not update before rising edge");
        @(posedge clk);
        #1;
        MemWrite = 1'b0;
        expect_read(32'h87654321, "write updates on rising edge");

        MemRead = 1'b0;
        expect_read(32'b0, "read disabled gates output to zero");

        if (failures == 0) begin
            $display("PASS: data memory read/write test completed successfully.");
            $finish;
        end else begin
            $fatal(1, "FAIL: %0d data memory check(s) failed.", failures);
        end
    end

endmodule
