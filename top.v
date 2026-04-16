module top_processor (
    input clk,
    input reset,
    output [31:0] pc_out_debug
);  
    // ===========================
    // PC and Fetch Stage
    // ===========================
    wire [31:0] pc_in;          // Final next PC from mux_final
    reg  [31:0] pc_reg;         // PC register
    wire [31:0] pc_out = pc_reg;
    wire [31:0] pc_plus4 = pc_out + 32'd4;
    assign pc_out_debug = pc_out;

    // ===========================
    // Instruction Memory
    // ===========================
    wire [31:0] instruction;
    instruction_memory imem (
        .address(pc_out),
        .instruction(instruction)
    );

    // ===========================
    // Instruction Decode Fields
    // ===========================
    wire [5:0]  opcode      = instruction[31:26];
    wire [4:0]  inst_rs     = instruction[25:21];
    wire [4:0]  inst_rt     = instruction[20:16];
    wire [4:0]  inst_rd     = instruction[15:11];
    wire [15:0] imm16       = instruction[15:0];
    wire [25:0] jump_imm26  = instruction[25:0];
    wire [5:0]  funct       = instruction[5:0];

    // ===========================
    // Control Unit
    // ===========================
    wire [1:0] RegDst;
    wire       ALUSrc;
    wire       MemtoReg;
    wire       RegWrite_raw;
    wire       MemWrite;
    wire       MemRead;
    wire       Branch;
    wire [1:0] Jump;
    wire       sign_ext;
    wire       is_pmc, is_jmn, is_swi;
    wire       sel_mux2, sel_mux3;

    control_unit ctrl (
        .opcode     (opcode),
        .RegDst     (RegDst),
        .ALUSrc     (ALUSrc),
        .MemtoReg   (MemtoReg),
        .RegWrite   (RegWrite_raw),
        .MemRead    (MemRead),
        .MemWrite   (MemWrite),
        .Branch     (Branch),
        .Jump       (Jump),
        .sign_ext   (sign_ext),
        .is_pmc     (is_pmc),
        .is_jmn     (is_jmn),
        .is_swi     (is_swi),
        .sel_mux2   (sel_mux2),
        .sel_mux3   (sel_mux3)
    );

    // ===========================
    // Register File
    // ===========================
    wire [31:0] read_data1, read_data2;
    wire [4:0]  write_reg_sel;

    // MUX1: Select write register (R-type, I-type, or custom)
    mux3 #(.N(5)) mux_regdst (
        .a(inst_rt),
        .b(inst_rd),
        .c(inst_rs),
        .sel(RegDst),
        .y(write_reg_sel)
    );

    // ===========================
    // Immediate Extension
    // ===========================
    wire [31:0] imm_ext;
    extend_16_to_32 ext16 (
        .instruction        (imm16),
        .sign_ext           (sign_ext),
        .extended_instruction(imm_ext)
    );

    // ===========================
    // ALU Source MUX
    // ===========================
    wire [31:0] alu_b_input;
    mux2 #(.N(32)) mux_alusrc (
        .a(read_data2),
        .b(imm_ext),
        .sel(ALUSrc),
        .y(alu_b_input)
    );

    // ===========================
    // ALU Control & Core
    // ===========================
    wire [2:0] alu_ctrl;
    alu_control_unit alu_ctl (
        .opcode(opcode),
        .funct(funct),
        .alu_ctrl(alu_ctrl)
    );

    wire [31:0] alu_result;
    wire        alu_zero;
    ALU alu_core (
        .A       (read_data1),
        .B       (alu_b_input),
        .alu_op  (alu_ctrl),
        .result  (alu_result),
        .zero    (alu_zero)
    );

    // ===========================
    // Branch Logic
    // ===========================
    wire [31:0] branch_target = pc_plus4 + {imm_ext[29:0], 2'b00}; // shifted
    wire        branch_take   = Branch & alu_zero;

    // ===========================
    // Jump Target
    // ===========================
    wire [31:0] jump_target = {pc_plus4[31:28], jump_imm26, 2'b00};
    wire jump_taken = (Jump != 2'b00);

    // ===========================
    // Data Memory
    // ===========================
    wire [31:0] mem_read_addr;
    mux2 #(.N(32)) mux_mem_read_addr (
        .a(read_data2),
        .b(alu_result),
        .sel(sel_mux2),
        .y(mem_read_addr)
    );

    wire [31:0] mem_write_data;
    mux2 #(.N(32)) mux_mem_write_data (
        .a(pc_plus4),
        .b(read_data2),
        .sel(sel_mux3),
        .y(mem_write_data)
    );

    wire [31:0] mem_read_data;
    data_memory_dualaddr_sync dmem (
        .clk        (clk),
        .memwrite   (MemWrite),
        .MemRead    (MemRead),
        .write_addr (alu_result),
        .write_data (mem_write_data),
        .read_addr  (mem_read_addr),
        .read_data  (mem_read_data)
    );

    // ===========================
    // Write-back MUX
    // ===========================
    wire [31:0] write_data_rf;
    mux2 #(.N(32)) mux_memtoreg (
        .a(alu_result),
        .b(mem_read_data),
        .sel(MemtoReg),
        .y(write_data_rf)
    );

    // ===========================
    // Final Write Register and Data (for SWI)
    // ===========================
    wire [4:0]  write_reg_final  = (is_swi) ? inst_rs : write_reg_sel;
    wire [31:0] write_data_final = (is_swi) ? (read_data1 + imm_ext) : write_data_rf;

    // ===========================
    // Register File Instantiation
    // ===========================
    regfile32 RF (
        .clk        (clk),
        .reset      (reset),
        .regwrite   (RegWrite_raw && !is_pmc),
        .read_reg1  (inst_rs),
        .read_reg2  (inst_rt),
        .write_reg  (write_reg_final),
        .write_data (write_data_final),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    // ===========================
    // PC MUXes
    // ===========================
    // MUX6: Branch select (PC+4 or branch_target)
    wire [31:0] output_mux5;
    mux2 #(.N(32)) mux_2_5 (
        .a(pc_plus4),
        .b(branch_target),
        .sel(branch_take),
        .y(output_mux5)
    );

    // MUX7: Final PC select (branch/jump/custom)
    mux3 #(.N(32)) mux_final (
        .a(output_mux5),
        .b(jump_target),
        .c(write_data_rf),
        .sel(Jump),
        .y(pc_in)
    );

    // ===========================
    //  PC  
    // ===========================
    always @(posedge clk) begin
        if (reset)
            pc_reg <= 32'd0;
        else if (is_pmc || is_jmn)
            pc_reg <= mem_read_data;
        else
            pc_reg <= pc_in;
    end  

endmodule
