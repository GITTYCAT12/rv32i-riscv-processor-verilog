module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0] ALU_Sel,
    output reg [31:0] Result
);

always @(*) begin
    case (ALU_Sel)
        4'b0000: Result = A + B;                              // ADD
        4'b0001: Result = A - B;                              // SUB
        4'b0010: Result = A & B;                              // AND
        4'b0011: Result = A | B;                              // OR
        4'b0100: Result = A ^ B;                              // XOR
        4'b0101: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
        4'b0110: Result = (A < B) ? 32'd1 : 32'd0;            // SLTU
        4'b0111: Result = A << B[4:0];                        // SLL
        4'b1000: Result = A >> B[4:0];                        // SRL
        4'b1001: Result = $signed(A) >>> B[4:0];              // SRA
        4'b1010: Result = B;                                  // LUI
        default: Result = 32'b0;
    endcase
end

endmodule
