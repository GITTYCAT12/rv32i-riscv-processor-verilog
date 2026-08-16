`timescale 1ns / 1ps

module riscv_core (
    input  wire        clk,
    input  wire        reset,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_instruction,
    output wire [31:0] debug_alu_result
);

    // =========================================================
    // IF STAGE
    // =========================================================

    reg [31:0] pc;

    wire [31:0] pc_plus4_if;
    wire [31:0] instruction_if;
    wire [31:0] next_pc;

    assign pc_plus4_if = pc + 32'd4;

    instruction_memory imem (
        .address     (pc),
        .instruction (instruction_if)
    );


    // =========================================================
    // IF / ID PIPELINE REGISTER
    // =========================================================

    reg        if_id_valid;
    reg [31:0] if_id_pc;
    reg [31:0] if_id_pc4;
    reg [31:0] if_id_instr;


    // =========================================================
    // ID STAGE
    // =========================================================

    wire [6:0] id_opcode;
    wire [4:0] id_rd;
    wire [2:0] id_funct3;
    wire [4:0] id_rs1;
    wire [4:0] id_rs2;
    wire [6:0] id_funct7;

    assign id_opcode = if_id_instr[6:0];
    assign id_rd     = if_id_instr[11:7];
    assign id_funct3 = if_id_instr[14:12];
    assign id_rs1    = if_id_instr[19:15];
    assign id_rs2    = if_id_instr[24:20];
    assign id_funct7 = if_id_instr[31:25];


    // =========================================================
    // WRITEBACK SIGNALS
    // =========================================================

    reg        mem_wb_valid;
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_pc4;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;
    reg        mem_wb_mem_to_reg;
    reg [1:0]  mem_wb_wb_sel;

    wire [31:0] wb_write_data;

    assign wb_write_data =
        (mem_wb_wb_sel == 2'b01) ? mem_wb_mem_data :
        (mem_wb_wb_sel == 2'b10) ? mem_wb_pc4 :
                                    mem_wb_alu_result;


    // =========================================================
    // REGISTER FILE
    // =========================================================

    wire [31:0] id_read_data1;
    wire [31:0] id_read_data2;

    register_file rf (
        .clk        (clk),
        .reset      (reset),
        .rs1        (id_rs1),
        .rs2        (id_rs2),
        .rd         (mem_wb_rd),
        .write_data (wb_write_data),
        .reg_write  (mem_wb_reg_write),
        .read_data1 (id_read_data1),
        .read_data2 (id_read_data2)
    );


    // =========================================================
    // ID CONTROL
    // =========================================================

    reg        id_reg_write;
    reg        id_mem_read;
    reg        id_mem_write;
    reg        id_mem_to_reg;
    reg        id_alu_src;
    reg        id_branch;
    reg        id_jump;
    reg        id_jalr;
    reg        id_alu_to_pc;

    reg [1:0]  id_wb_sel;

    reg        id_uses_rs1;
    reg        id_uses_rs2;

    reg [3:0]  id_alu_sel;

    reg [31:0] id_imm;


    always @(*) begin

        id_reg_write  = 1'b0;
        id_mem_read   = 1'b0;
        id_mem_write  = 1'b0;
        id_mem_to_reg = 1'b0;
        id_alu_src    = 1'b0;

        id_branch     = 1'b0;
        id_jump       = 1'b0;
        id_jalr       = 1'b0;

        id_alu_to_pc  = 1'b0;

        id_wb_sel     = 2'b00;

        id_uses_rs1   = 1'b0;
        id_uses_rs2   = 1'b0;

        id_alu_sel    = 4'b0000;

        id_imm        = 32'b0;


        case (id_opcode)

            // =================================================
            // R-TYPE
            // =================================================

            7'b0110011: begin

                id_uses_rs1  = 1'b1;
                id_uses_rs2  = 1'b1;
                id_reg_write = 1'b1;

                case (id_funct3)

                    3'b000:
                        id_alu_sel =
                            (id_funct7 == 7'b0100000) ?
                            4'b0001 : 4'b0000;

                    3'b111:
                        id_alu_sel = 4'b0010;

                    3'b110:
                        id_alu_sel = 4'b0011;

                    3'b100:
                        id_alu_sel = 4'b0100;

                    3'b010:
                        id_alu_sel = 4'b0101;

                    3'b011:
                        id_alu_sel = 4'b0110;

                    3'b001:
                        id_alu_sel = 4'b0111;

                    3'b101:
                        id_alu_sel =
                            (id_funct7 == 7'b0100000) ?
                            4'b1001 : 4'b1000;

                    default:
                        id_alu_sel = 4'b0000;

                endcase
            end


            // =================================================
            // I-TYPE ALU
            // =================================================

            7'b0010011: begin

                id_uses_rs1  = 1'b1;
                id_reg_write = 1'b1;
                id_alu_src   = 1'b1;

                id_imm = {{20{if_id_instr[31]}},
                          if_id_instr[31:20]};

                case (id_funct3)

                    3'b000:
                        id_alu_sel = 4'b0000;       // ADDI

                    3'b111:
                        id_alu_sel = 4'b0010;       // ANDI

                    3'b110:
                        id_alu_sel = 4'b0011;       // ORI

                    3'b100:
                        id_alu_sel = 4'b0100;       // XORI

                    3'b010:
                        id_alu_sel = 4'b0101;       // SLTI

                    3'b011:
                        id_alu_sel = 4'b0110;       // SLTIU

                    3'b001: begin
                        id_alu_sel = 4'b0111;
                        id_imm = {27'b0,
                                  if_id_instr[24:20]};
                    end

                    3'b101: begin
                        id_alu_sel =
                            if_id_instr[30] ?
                            4'b1001 : 4'b1000;

                        id_imm = {27'b0,
                                  if_id_instr[24:20]};
                    end

                    default:
                        id_alu_sel = 4'b0000;

                endcase
            end


            // =================================================
            // LW
            // =================================================

            7'b0000011: begin

                id_uses_rs1   = 1'b1;
                id_reg_write  = 1'b1;
                id_mem_read   = 1'b1;
                id_mem_to_reg = 1'b1;
                id_alu_src    = 1'b1;

                id_alu_sel = 4'b0000;

                id_imm = {{20{if_id_instr[31]}},
                          if_id_instr[31:20]};
            end


            // =================================================
            // SW
            // =================================================

            7'b0100011: begin

                id_uses_rs1  = 1'b1;
                id_uses_rs2  = 1'b1;

                id_mem_write = 1'b1;
                id_alu_src   = 1'b1;

                id_alu_sel = 4'b0000;

                id_imm = {{20{if_id_instr[31]}},
                          if_id_instr[31:25],
                          if_id_instr[11:7]};
            end


            // =================================================
            // BRANCH
            // =================================================

            7'b1100011: begin

                id_uses_rs1 = 1'b1;
                id_uses_rs2 = 1'b1;

                id_branch = 1'b1;

                id_alu_sel = 4'b0001;

                id_imm = {{19{if_id_instr[31]}},
                          if_id_instr[31],
                          if_id_instr[7],
                          if_id_instr[30:25],
                          if_id_instr[11:8],
                          1'b0};
            end


            // =================================================
            // JAL
            // =================================================

            7'b1101111: begin

                id_reg_write = 1'b1;
                id_jump      = 1'b1;

                id_wb_sel = 2'b10;

                id_imm = {{11{if_id_instr[31]}},
                          if_id_instr[31],
                          if_id_instr[19:12],
                          if_id_instr[20],
                          if_id_instr[30:21],
                          1'b0};
            end


            // =================================================
            // JALR
            // =================================================

            7'b1100111: begin

                id_uses_rs1  = 1'b1;
                id_reg_write = 1'b1;

                id_jump = 1'b1;
                id_jalr = 1'b1;

                id_wb_sel = 2'b10;

                id_alu_src = 1'b1;

                id_imm = {{20{if_id_instr[31]}},
                          if_id_instr[31:20]};
            end


            // =================================================
            // LUI
            // =================================================

            7'b0110111: begin

                id_reg_write = 1'b1;
                id_alu_src   = 1'b1;

                id_alu_sel = 4'b1010;

                id_imm = {if_id_instr[31:12],
                          12'b0};
            end


            // =================================================
            // AUIPC
            // =================================================

            7'b0010111: begin

                id_reg_write = 1'b1;
                id_alu_src   = 1'b1;
                id_alu_to_pc = 1'b1;

                id_alu_sel = 4'b0000;

                id_imm = {if_id_instr[31:12],
                          12'b0};
            end


            default: begin
            end

        endcase

    end


    // =========================================================
    // ID / EX PIPELINE REGISTER
    // =========================================================

    reg        id_ex_valid;

    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_pc4;

    reg [31:0] id_ex_rs1_data;
    reg [31:0] id_ex_rs2_data;

    reg [31:0] id_ex_imm;

    reg [4:0]  id_ex_rs1;
    reg [4:0]  id_ex_rs2;
    reg [4:0]  id_ex_rd;

    reg [2:0]  id_ex_funct3;

    reg        id_ex_reg_write;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg        id_ex_mem_to_reg;

    reg        id_ex_alu_src;

    reg        id_ex_branch;
    reg        id_ex_jump;
    reg        id_ex_jalr;

    reg        id_ex_alu_to_pc;

    reg [1:0]  id_ex_wb_sel;

    reg [3:0]  id_ex_alu_sel;


    // =========================================================
    // EX / MEM PIPELINE REGISTER
    // =========================================================

    reg        ex_mem_valid;

    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [31:0] ex_mem_pc4;

    reg [4:0]  ex_mem_rd;

    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg        ex_mem_mem_to_reg;

    reg [1:0]  ex_mem_wb_sel;


    // =========================================================
    // EX FORWARDING
    // =========================================================

    reg [31:0] ex_forward_a;
    reg [31:0] ex_forward_b;

    reg [31:0] ex_alu_a;
    reg [31:0] ex_alu_b;

    wire [31:0] ex_alu_result;


    always @(*) begin

        ex_forward_a = id_ex_rs1_data;
        ex_forward_b = id_ex_rs2_data;


        // EX/MEM forwarding
        // Do not forward a load from EX/MEM.

        if (ex_mem_reg_write &&
            !ex_mem_mem_read &&
            (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == id_ex_rs1)) begin

            ex_forward_a = ex_mem_alu_result;
        end

        else if (mem_wb_reg_write &&
                 (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == id_ex_rs1)) begin

            ex_forward_a = wb_write_data;
        end


        if (ex_mem_reg_write &&
            !ex_mem_mem_read &&
            (ex_mem_rd != 5'd0) &&
            (ex_mem_rd == id_ex_rs2)) begin

            ex_forward_b = ex_mem_alu_result;
        end

        else if (mem_wb_reg_write &&
                 (mem_wb_rd != 5'd0) &&
                 (mem_wb_rd == id_ex_rs2)) begin

            ex_forward_b = wb_write_data;
        end


        if (id_ex_alu_to_pc)
            ex_alu_a = id_ex_pc;
        else
            ex_alu_a = ex_forward_a;


        if (id_ex_alu_src)
            ex_alu_b = id_ex_imm;
        else
            ex_alu_b = ex_forward_b;

    end


    // =========================================================
    // ALU
    // =========================================================

    alu ex_alu (
        .A       (ex_alu_a),
        .B       (ex_alu_b),
        .ALU_Sel (id_ex_alu_sel),
        .Result  (ex_alu_result)
    );


    // =========================================================
    // BRANCH / JUMP
    // =========================================================

    reg        ex_branch_taken;
    reg [31:0] ex_branch_target;


    always @(*) begin

        ex_branch_taken  = 1'b0;
        ex_branch_target = id_ex_pc + id_ex_imm;


        if (id_ex_jalr)
            ex_branch_target =
                (ex_forward_a + id_ex_imm) &
                32'hFFFFFFFE;


        if (id_ex_jump) begin

            ex_branch_taken = 1'b1;

        end

        else if (id_ex_branch) begin

            case (id_ex_funct3)

                3'b000:
                    ex_branch_taken =
                        (ex_forward_a == ex_forward_b);

                3'b001:
                    ex_branch_taken =
                        (ex_forward_a != ex_forward_b);

                3'b100:
                    ex_branch_taken =
                        ($signed(ex_forward_a) <
                         $signed(ex_forward_b));

                3'b101:
                    ex_branch_taken =
                        ($signed(ex_forward_a) >=
                         $signed(ex_forward_b));

                3'b110:
                    ex_branch_taken =
                        (ex_forward_a < ex_forward_b);

                3'b111:
                    ex_branch_taken =
                        (ex_forward_a >= ex_forward_b);

                default:
                    ex_branch_taken = 1'b0;

            endcase

        end

    end


    // =========================================================
    // NEXT PC
    // =========================================================

    assign next_pc =
        ex_branch_taken ?
        ex_branch_target :
        pc_plus4_if;


    // =========================================================
    // DATA MEMORY
    // =========================================================

    wire [31:0] mem_read_data;

    data_memory dmem (
        .clk       (clk),
        .MemRead   (ex_mem_mem_read),
        .MemWrite  (ex_mem_mem_write),
        .address   (ex_mem_alu_result),
        .write_data(ex_mem_store_data),
        .read_data (mem_read_data)
    );


    // =========================================================
    // HAZARD DETECTION
    // =========================================================

    wire load_use_hazard_ex;
    wire load_use_hazard_mem;
    wire load_use_hazard;


    assign load_use_hazard_ex =
        id_ex_valid &&
        id_ex_mem_read &&
        (id_ex_rd != 5'd0) &&
        if_id_valid &&
        (
            (id_uses_rs1 && (id_ex_rd == id_rs1)) ||
            (id_uses_rs2 && (id_ex_rd == id_rs2))
        );


    assign load_use_hazard_mem =
        ex_mem_valid &&
        ex_mem_mem_read &&
        (ex_mem_rd != 5'd0) &&
        if_id_valid &&
        (
            (id_uses_rs1 && (ex_mem_rd == id_rs1)) ||
            (id_uses_rs2 && (ex_mem_rd == id_rs2))
        );


    assign load_use_hazard =
        load_use_hazard_ex ||
        load_use_hazard_mem;


    // =========================================================
    // PIPELINE SEQUENTIAL LOGIC
    // =========================================================

    always @(posedge clk) begin

        if (reset) begin

            // -------------------------------------------------
            // PC
            // -------------------------------------------------

            pc <= 32'b0;


            // -------------------------------------------------
            // IF/ID
            // -------------------------------------------------

            if_id_valid <= 1'b0;
            if_id_pc    <= 32'b0;
            if_id_pc4   <= 32'b0;
            if_id_instr <= 32'h00000013;


            // -------------------------------------------------
            // ID/EX
            // -------------------------------------------------

            id_ex_valid      <= 1'b0;

            id_ex_pc         <= 32'b0;
            id_ex_pc4        <= 32'b0;

            id_ex_rs1_data   <= 32'b0;
            id_ex_rs2_data   <= 32'b0;

            id_ex_imm        <= 32'b0;

            id_ex_rs1        <= 5'b0;
            id_ex_rs2        <= 5'b0;
            id_ex_rd         <= 5'b0;

            id_ex_funct3     <= 3'b0;

            id_ex_reg_write  <= 1'b0;
            id_ex_mem_read   <= 1'b0;
            id_ex_mem_write  <= 1'b0;
            id_ex_mem_to_reg <= 1'b0;

            id_ex_alu_src    <= 1'b0;

            id_ex_branch     <= 1'b0;
            id_ex_jump       <= 1'b0;
            id_ex_jalr       <= 1'b0;

            id_ex_alu_to_pc  <= 1'b0;

            id_ex_wb_sel     <= 2'b00;

            id_ex_alu_sel    <= 4'b0000;


            // -------------------------------------------------
            // EX/MEM
            // -------------------------------------------------

            ex_mem_valid      <= 1'b0;

            ex_mem_alu_result <= 32'b0;
            ex_mem_store_data <= 32'b0;
            ex_mem_pc4        <= 32'b0;

            ex_mem_rd         <= 5'b0;

            ex_mem_reg_write  <= 1'b0;
            ex_mem_mem_read   <= 1'b0;
            ex_mem_mem_write  <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;

            ex_mem_wb_sel     <= 2'b00;


            // -------------------------------------------------
            // MEM/WB
            // -------------------------------------------------

            mem_wb_valid      <= 1'b0;

            mem_wb_alu_result <= 32'b0;
            mem_wb_mem_data   <= 32'b0;
            mem_wb_pc4        <= 32'b0;

            mem_wb_rd         <= 5'b0;

            mem_wb_reg_write  <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;

            mem_wb_wb_sel     <= 2'b00;

        end

        else begin

            // =================================================
            // PC + IF/ID
            // =================================================

            if (ex_branch_taken) begin

                // Branch/jump flush

                pc <= next_pc;

                if_id_valid <= 1'b0;
                if_id_pc    <= 32'b0;
                if_id_pc4   <= 32'b0;
                if_id_instr <= 32'h00000013;

            end

            else if (load_use_hazard) begin

                // Stall PC and IF/ID

                pc <= pc;

                if_id_valid <= if_id_valid;
                if_id_pc    <= if_id_pc;
                if_id_pc4   <= if_id_pc4;
                if_id_instr <= if_id_instr;

            end

            else begin

                pc <= next_pc;

                if_id_valid <= 1'b1;
                if_id_pc    <= pc;
                if_id_pc4   <= pc_plus4_if;
                if_id_instr <= instruction_if;

            end


            // =================================================
            // ID/EX
            // =================================================

            if (ex_branch_taken ||
                load_use_hazard) begin

                // Insert bubble

                id_ex_valid      <= 1'b0;

                id_ex_reg_write  <= 1'b0;
                id_ex_mem_read   <= 1'b0;
                id_ex_mem_write  <= 1'b0;
                id_ex_mem_to_reg <= 1'b0;

                id_ex_branch     <= 1'b0;
                id_ex_jump       <= 1'b0;
                id_ex_jalr       <= 1'b0;

                id_ex_alu_to_pc  <= 1'b0;
                id_ex_wb_sel     <= 2'b00;

            end

            else begin

                id_ex_valid <= if_id_valid;

                id_ex_pc    <= if_id_pc;
                id_ex_pc4   <= if_id_pc4;

                id_ex_rs1_data <= id_read_data1;
                id_ex_rs2_data <= id_read_data2;

                id_ex_imm <= id_imm;

                id_ex_rs1 <= id_rs1;
                id_ex_rs2 <= id_rs2;
                id_ex_rd  <= id_rd;

                id_ex_funct3 <= id_funct3;

                id_ex_reg_write  <= id_reg_write &&
                                    if_id_valid;

                id_ex_mem_read   <= id_mem_read &&
                                    if_id_valid;

                id_ex_mem_write  <= id_mem_write &&
                                    if_id_valid;

                id_ex_mem_to_reg <= id_mem_to_reg &&
                                    if_id_valid;

                id_ex_alu_src <= id_alu_src;

                id_ex_branch <= id_branch &&
                                if_id_valid;

                id_ex_jump <= id_jump &&
                              if_id_valid;

                id_ex_jalr <= id_jalr &&
                              if_id_valid;

                id_ex_alu_to_pc <= id_alu_to_pc;

                id_ex_wb_sel <= id_wb_sel;

                id_ex_alu_sel <= id_alu_sel;

            end


            // =================================================
            // EX/MEM
            // =================================================

            ex_mem_valid <= id_ex_valid;

            ex_mem_alu_result <= ex_alu_result;

            ex_mem_store_data <= ex_forward_b;

            ex_mem_pc4 <= id_ex_pc4;

            ex_mem_rd <= id_ex_rd;

            ex_mem_reg_write <= id_ex_reg_write;

            ex_mem_mem_read <= id_ex_mem_read;

            ex_mem_mem_write <= id_ex_mem_write;

            ex_mem_mem_to_reg <= id_ex_mem_to_reg;

            ex_mem_wb_sel <= id_ex_wb_sel;


            // =================================================
            // MEM/WB
            // =================================================

            mem_wb_valid <= ex_mem_valid;

            mem_wb_alu_result <= ex_mem_alu_result;

            mem_wb_mem_data <= mem_read_data;

            mem_wb_pc4 <= ex_mem_pc4;

            mem_wb_rd <= ex_mem_rd;

            mem_wb_reg_write <= ex_mem_reg_write;

            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;

            mem_wb_wb_sel <= ex_mem_wb_sel;

        end

    end


    // =========================================================
    // DEBUG OUTPUTS
    // =========================================================

    assign debug_pc          = pc;
    assign debug_instruction = instruction_if;
    assign debug_alu_result  = ex_alu_result;


endmodule