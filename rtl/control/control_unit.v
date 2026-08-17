module control_unit (
    input  [6:0] opcode,

    output reg       RegWrite,
    output reg       ALUSrc,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       MemToReg,
    output reg       Branch,
    output reg [1:0] ALUOp
);

    // RISC-V opcodes
    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;   // ADDI
    localparam LW     = 7'b0000011;
    localparam SW     = 7'b0100011;
    localparam BEQ    = 7'b1100011;

    always @(*) begin

        // Default values
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)

            // -------------------------
            // R-Type: ADD, SUB, AND, OR
            // -------------------------
            R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b10;
            end

            // -------------------------
            // I-Type: ADDI
            // -------------------------
            I_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // -------------------------
            // Load Word: LW
            // -------------------------
            LW: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                MemToReg = 1'b1;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // -------------------------
            // Store Word: SW
            // -------------------------
            SW: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemToReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // -------------------------
            // Branch Equal: BEQ
            // -------------------------
            BEQ: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end

            // -------------------------
            // Unsupported instruction
            // -------------------------
            default: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemToReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

        endcase
    end

endmodule