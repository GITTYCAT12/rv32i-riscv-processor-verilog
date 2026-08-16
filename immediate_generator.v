module immediate_generator (
    input wire [31:0] instruction,
    input wire [1:0] immediate_type,
    output reg [31:0] immediate
);

    always @(*) begin

        case (immediate_type)

            // I-type immediate
            2'b00: begin
                immediate = {{20{instruction[31]}},
                             instruction[31:20]};
            end

            // S-type immediate
            2'b01: begin
                immediate = {{20{instruction[31]}},
                             instruction[31:25],
                             instruction[11:7]};
            end

            // B-type immediate
            2'b10: begin
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};
            end

            default: begin
                immediate = 32'b0;
            end

        endcase

    end

endmodule