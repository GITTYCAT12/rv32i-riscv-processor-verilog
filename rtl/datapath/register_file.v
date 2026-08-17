module register_file (
    input clk,
    input reset,

    input [4:0] rs1,
    input [4:0] rs2,

    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,

    output [31:0] read_data1,
    output [31:0] read_data2
);

    reg [31:0] registers [0:31];

    integer i;

    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end

        end

        else if (reg_write && rd != 5'b00000) begin
            registers[rd] <= write_data;
        end

    end

    assign read_data1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];

    assign read_data2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

endmodule
