`timescale 1ns / 1ps

module tb_register_file;

    reg clk;
    reg reset;

    reg [4:0] rs1;
    reg [4:0] rs2;

    reg [4:0] rd;
    reg [31:0] write_data;
    reg reg_write;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register_file uut (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        rs1 = 0;
        rs2 = 0;
        rd = 0;
        write_data = 0;
        reg_write = 0;

        #10;

        reset = 0;

        // Write 25 into x1
        rd = 5'd1;
        write_data = 32'd25;
        reg_write = 1;

        #10;

        // Read x1
        reg_write = 0;
        rs1 = 5'd1;

        #10;

        // Write 50 into x2
        rd = 5'd2;
        write_data = 32'd50;
        reg_write = 1;

        #10;

        // Read x1 and x2
        reg_write = 0;
        rs1 = 5'd1;
        rs2 = 5'd2;

        #10;

        // Check x0
        rs1 = 5'd0;

        #10;

        $finish;

    end

endmodule
