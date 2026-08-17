`timescale 1ns / 1ps

module tb_data_memory;

    reg clk;
    reg MemRead;
    reg MemWrite;

    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;


    // Instantiate Data Memory

    data_memory uut (

        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)

    );


    // Clock generation

    always #5 clk = ~clk;


    // Test sequence

    initial begin

        // Initial values

        clk = 0;
        MemRead = 0;
        MemWrite = 0;
        address = 0;
        write_data = 0;


        // Wait

        #10;


        // ------------------------------------------------
        // WRITE TEST
        // ------------------------------------------------

        address = 32'h00000004;
        write_data = 32'h12345678;

        MemWrite = 1;
        MemRead = 0;

        #10;


        // Stop writing

        MemWrite = 0;


        // ------------------------------------------------
        // READ TEST
        // ------------------------------------------------

        #10;

        address = 32'h00000004;

        MemRead = 1;
        MemWrite = 0;

        #10;


        // Stop reading

        MemRead = 0;

        #10;


        // Finish simulation

        $finish;

    end

endmodule