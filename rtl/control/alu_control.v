module alu_control (
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,

    output reg [3:0] ALU_Control
);

    always @(*) begin

        // Default operation
        ALU_Control = 4'b0000;

        case (ALUOp)

            // Load / Store / ADDI
            2'b00: begin
                ALU_Control = 4'b0000;   // ADD
            end

            // BEQ
            2'b01: begin
                ALU_Control = 4'b0001;   // SUB
            end

            // R-type
            2'b10: begin

                case (funct3)

                    // ADD / SUB
                    3'b000: begin

                        if (funct7 == 7'b0100000)
                            ALU_Control = 4'b0001; // SUB
                        else
                            ALU_Control = 4'b0000; // ADD

                    end

                    // OR
                    3'b110: begin
                        ALU_Control = 4'b0011;
                    end

                    // AND
                    3'b111: begin
                        ALU_Control = 4'b0010;
                    end

                    default: begin
                        ALU_Control = 4'b0000;
                    end

                endcase

            end

            default: begin
                ALU_Control = 4'b0000;
            end

        endcase

    end

endmodule