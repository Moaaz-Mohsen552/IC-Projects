module top_processor_pipelined_with_hazards (
    input clk,
    input reset,
    output [31:0] pc_out_debug,
    output [31:0] current_instr_debug,
    
    // Debug outputs for hazard handling
    output stall_debug,
    output [1:0] forwardA_debug,
    output [1:0] forwardB_debug
);

    // ========================= IF Stage =========================
    reg [31:0] PC;
    wire [31:0] instr_IF;
    wire [31:0] pc4_IF;
    assign pc4_IF = PC + 32'd4;

    instruction_memory IM (.address(PC), .instruction(instr_IF));
    assign current_instr_debug = instr_IF;

    // ======================== Hazard Detection ====================
    wire stall, flush_IFID_hazard, flush_IDEX_hazard;
    
    wire [4:0] IFID_rs, IFID_rt;
    wire [4:0] IDEX_rt_hazard;
    wire IDEX_MemRead_hazard;
    wire EXMEM_is_pmc_hazard, EXMEM_is_jmn_hazard;
    
    // ======================== IF/ID Register =====================
    wire [31:0] instr_ID, pc4_ID;
    wire flush_IFID;
    
    IF_ID ifid_reg (
        .clk(clk),
        .reset(reset || flush_IFID),
        .flush(1'b0),
        .instr_in(stall ? 32'b0 : instr_IF),
        .pc4_in(stall ? pc4_ID : pc4_IF),
        .instr_out(instr_ID),
        .pc4_out(pc4_ID)
    );
    
    assign IFID_rs = instr_ID[25:21];
    assign IFID_rt = instr_ID[20:16];

    // ======================== ID Stage ==========================
    wire [5:0] opcode_ID = instr_ID[31:26];
    wire [4:0] rs_ID     = instr_ID[25:21];
    wire [4:0] rt_ID     = instr_ID[20:16];
    wire [4:0] rd_ID     = instr_ID[15:11];
    wire [15:0] imm16_ID = instr_ID[15:0];
    wire [5:0] funct_ID  = instr_ID[5:0];

    // Control Unit
    wire [1:0] RegDst_ID, Jump_ID;
    wire ALUSrc_ID, MemtoReg_ID, RegWrite_ID, MemRead_ID, MemWrite_ID;
    wire Branch_ID, sign_ext_ID, is_swi_ID, is_pmc_ID, is_jmn_ID, sel_mux2_ID, sel_mux3_ID;

    control_unit CU (
        .opcode(opcode_ID),
        .RegDst(RegDst_ID),
        .ALUSrc(ALUSrc_ID),
        .MemtoReg(MemtoReg_ID),
        .RegWrite(RegWrite_ID),
        .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID),
        .Branch(Branch_ID),
        .Jump(Jump_ID),
        .sign_ext(sign_ext_ID),
        .is_swi(is_swi_ID),
        .is_pmc(is_pmc_ID),
        .is_jmn(is_jmn_ID),
        .sel_mux2(sel_mux2_ID),
        .sel_mux3(sel_mux3_ID)
    );

    // Register File
    wire [31:0] rd1_ID, rd2_ID;
    wire [4:0] write_reg_WB;
    wire [31:0] write_data_WB;
    wire RegWrite_WB;
    
    regfile32 RF (
        .clk(clk),
        .reset(reset),
        .regwrite(RegWrite_WB),
        .read_reg1(rs_ID),
        .read_reg2(rt_ID),
        .write_reg(write_reg_WB),
        .write_data(write_data_WB),
        .read_data1(rd1_ID),
        .read_data2(rd2_ID)
    );

    // Immediate Extension
    wire [31:0] imm_ext_ID;
    extend_16_to_32 EXT (
        .instruction(imm16_ID),
        .sign_ext(sign_ext_ID),
        .extended_instruction(imm_ext_ID)
    );

    // ======================== ID/EX Register =====================
    wire [31:0] IDEX_pc4, IDEX_rd1, IDEX_rd2, IDEX_imm;
    wire [4:0] IDEX_rs, IDEX_rt, IDEX_rd;
    wire [5:0] IDEX_opcode, IDEX_funct;
    wire IDEX_RegWrite, IDEX_MemRead, IDEX_MemWrite, IDEX_MemtoReg, IDEX_Branch;
    wire IDEX_ALUSrc, IDEX_is_swi, IDEX_is_pmc, IDEX_is_jmn, IDEX_sel_mux2, IDEX_sel_mux3;
    wire [1:0] IDEX_RegDst, IDEX_Jump;
    wire IDEX_sign_ext;
    wire flush_IDEX;
    
  ID_EX idex_reg (
    .clk(clk),
    .reset(reset || flush_IDEX),
    .flush(1'b0),
    .pc4_in(pc4_ID),
    .rd1_in(rd1_ID),
    .rd2_in(rd2_ID),
    .imm_in(imm_ext_ID),
    .rs_in(rs_ID),
    .rt_in(rt_ID),
    .rd_in(rd_ID),
    .opcode_in(opcode_ID),
    .funct_in(funct_ID),
    .RegWrite_in(stall ? 1'b0 : RegWrite_ID),
    .MemRead_in(stall ? 1'b0 : MemRead_ID),
    .MemWrite_in(stall ? 1'b0 : MemWrite_ID),
    .MemtoReg_in(stall ? 1'b0 : MemtoReg_ID),
    .Branch_in(stall ? 1'b0 : Branch_ID),
    .ALUSrc_in(ALUSrc_ID),
    .RegDst_in(RegDst_ID),
    .pc4(IDEX_pc4),
    .rd1(IDEX_rd1),
    .rd2(IDEX_rd2),
    .imm(IDEX_imm),
    .rs(IDEX_rs),
    .rt(IDEX_rt),
    .rd(IDEX_rd),
    .opcode(IDEX_opcode),
    .funct(IDEX_funct),
    .RegWrite(IDEX_RegWrite),
    .MemRead(IDEX_MemRead),
    .MemWrite(IDEX_MemWrite),
    .MemtoReg(IDEX_MemtoReg),
    .Branch(IDEX_Branch),
    .ALUSrc(IDEX_ALUSrc),
    .RegDst(IDEX_RegDst)
);
    assign IDEX_rt_hazard = IDEX_rt;
    assign IDEX_MemRead_hazard = IDEX_MemRead;

    // ======================== Forwarding Unit =====================
    wire [1:0] forwardA, forwardB;
    wire [4:0] EXMEM_rd_fwd, MEMWB_rd_fwd;
    wire EXMEM_RegWrite_fwd, MEMWB_RegWrite_fwd;
    wire EXMEM_is_swi_fwd, MEMWB_is_swi_fwd;
    
    forwarding_unit fwd_unit (
        .IDEX_rs(IDEX_rs),
        .IDEX_rt(IDEX_rt),
        .EXMEM_rd(EXMEM_rd_fwd),
        .MEMWB_rd(MEMWB_rd_fwd),
        .EXMEM_RegWrite(EXMEM_RegWrite_fwd),
        .MEMWB_RegWrite(MEMWB_RegWrite_fwd),
        .EXMEM_is_swi(EXMEM_is_swi_fwd),
        .MEMWB_is_swi(MEMWB_is_swi_fwd),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    
    assign forwardA_debug = forwardA;
    assign forwardB_debug = forwardB;

    // ======================== EX Stage ==========================
    // إضافة الـForwarding MUXes هنا - هذا الجزء مفقود
    
    wire [31:0] EXMEM_alu_res_fwd; // من EX/MEM stage
    wire [31:0] MEMWB_alu_res_fwd; // من MEM/WB stage (لكن اللي بنستخدمه write_data_WB)
    
    // MUX للـForwarding للـALU input A
    wire [31:0] alu_input_A_forwarded;
    mux3 #(.N(32)) forward_mux_A (
        .a(IDEX_rd1),           // 00: القيمة الأصلية من الـregister file
        .b(write_data_WB),      // 01: من الـMEM/WB stage (القيمة اللي تم كتابتها)
        .c(EXMEM_alu_res_fwd),  // 10: من الـEX/MEM stage (نتيجة الـALU)
        .sel(forwardA),
        .y(alu_input_A_forwarded)
    );
    
    // MUX للـForwarding للـALU input B (قبل الـALUSrc MUX)
    wire [31:0] alu_input_B_forwarded;
    mux3 #(.N(32)) forward_mux_B (
        .a(IDEX_rd2),           // 00: القيمة الأصلية من الـregister file
        .b(write_data_WB),      // 01: من الـMEM/WB stage
        .c(EXMEM_alu_res_fwd),  // 10: من الـEX/MEM stage
        .sel(forwardB),
        .y(alu_input_B_forwarded)
    );
    
    // الـALUSrc MUX العادي (بعد الـForwarding)
    wire [31:0] alu_in2_EX;
    mux2 #(.N(32)) alu_src_mux (
        .a(alu_input_B_forwarded), // القيمة بعد الـforwarding
        .b(IDEX_imm),
        .sel(IDEX_ALUSrc),
        .y(alu_in2_EX)
    );

    wire [2:0] alu_ctrl_EX;
    alu_control_unit ALUCTRL (
        .opcode(IDEX_opcode),
        .funct(IDEX_funct),
        .alu_ctrl(alu_ctrl_EX)
    );

    wire [31:0] alu_res_EX;
    wire zero_EX;
    ALU ALU0 (
        .A(alu_input_A_forwarded), // استخدم القيمة بعد الـforwarding
        .B(alu_in2_EX),
        .alu_op(alu_ctrl_EX),
        .result(alu_res_EX),
        .zero(zero_EX)
    );

    // Branch Target Calculation
    wire [31:0] branch_target_EX = IDEX_pc4 + (IDEX_imm << 2);
    wire branch_taken_EX = IDEX_Branch & zero_EX;

    // Write Register Selection
    wire [4:0] write_reg_EX;
    mux3 #(.N(5)) regdst_mux (
        .a(IDEX_rt),
        .b(IDEX_rd),
        .c(IDEX_rs),
        .sel(IDEX_RegDst),
        .y(write_reg_EX)
    );

    // Data for SWI (rs + imm) - use forwarded value for rs
    wire [31:0] swi_result_EX = alu_input_A_forwarded + IDEX_imm;

    // ======================== EX/MEM Register =====================
    wire EXMEM_RegWrite, EXMEM_MemRead, EXMEM_MemWrite, EXMEM_MemtoReg;
    wire EXMEM_is_swi, EXMEM_is_pmc, EXMEM_is_jmn, EXMEM_sel_mux2, EXMEM_sel_mux3;
    wire [31:0] EXMEM_alu_res, EXMEM_rd2, EXMEM_branch_target, EXMEM_swi_result;
    wire [31:0] EXMEM_pc4;
    wire [4:0] EXMEM_write_reg;
    wire [1:0] EXMEM_Jump;
    
    EX_MEM exmem_reg (
        .clk(clk),
        .reset(reset),
        .RegWrite_in(IDEX_RegWrite),
        .MemRead_in(IDEX_MemRead),
        .MemWrite_in(IDEX_MemWrite),
        .MemtoReg_in(IDEX_MemtoReg),
        .Branch_in(IDEX_Branch),
        .alu_res_in(alu_res_EX),
        .rd2_in(alu_input_B_forwarded), // استخدم القيمة بعد الـforwarding
        .branch_target_in(branch_target_EX),
        .write_reg_in(write_reg_EX),
        .RegWrite(EXMEM_RegWrite),
        .MemRead(EXMEM_MemRead),
        .MemWrite(EXMEM_MemWrite),
        .MemtoReg(EXMEM_MemtoReg),
        .Branch(EXMEM_Branch),
        .alu_res(EXMEM_alu_res),
        .rd2(EXMEM_rd2),
        .branch_target(EXMEM_branch_target),
        .write_reg(EXMEM_write_reg)
    );
    
    assign EXMEM_alu_res_fwd = EXMEM_alu_res; // للتوصيل للـforwarding
    assign EXMEM_rd_fwd = EXMEM_write_reg;
    assign EXMEM_RegWrite_fwd = EXMEM_RegWrite;
    assign EXMEM_is_swi_fwd = EXMEM_is_swi;
    assign EXMEM_is_pmc_hazard = EXMEM_is_pmc;
    assign EXMEM_is_jmn_hazard = EXMEM_is_jmn;

    // ======================== MEM Stage =========================
    wire [31:0] mem_read_addr_MEM;
    mux2 #(.N(32)) mux_mem_read_addr_MEM (
        .a(EXMEM_rd2),
        .b(EXMEM_alu_res),
        .sel(EXMEM_sel_mux2),
        .y(mem_read_addr_MEM)
    );

    wire [31:0] mem_write_data_MEM;
    mux2 #(.N(32)) mux_mem_write_data_MEM (
        .a(EXMEM_pc4),
        .b(EXMEM_rd2),
        .sel(EXMEM_sel_mux3),
        .y(mem_write_data_MEM)
    );

    wire [31:0] mem_write_addr_MEM;
    mux2 #(.N(32)) mux_mem_write_addr_MEM (
        .a(EXMEM_alu_res),
        .b(EXMEM_swi_result),
        .sel(EXMEM_is_swi),
        .y(mem_write_addr_MEM)
    );

    wire [31:0] mem_read_data_MEM;
    data_memory_dualaddr_sync DM (
        .clk(clk),
        .memwrite(EXMEM_MemWrite),
        .write_addr(mem_write_addr_MEM),
        .write_data(mem_write_data_MEM),
        .read_addr(mem_read_addr_MEM),
        .read_data(mem_read_data_MEM)
    );

    wire [31:0] jump_from_mem = mem_read_data_MEM;

    // ======================== MEM/WB Register =====================
    wire MEMWB_RegWrite, MEMWB_MemtoReg, MEMWB_is_swi, MEMWB_is_pmc, MEMWB_is_jmn;
    wire [31:0] MEMWB_mem_data, MEMWB_alu_res, MEMWB_swi_result, MEMWB_jump_from_mem;
    wire [4:0] MEMWB_write_reg;
    
    MEM_WB memwb_reg (
        .clk(clk),
        .reset(reset),
        .RegWrite_in(EXMEM_RegWrite),
        .MemtoReg_in(EXMEM_MemtoReg),
        .mem_data_in(mem_read_data_MEM),
        .alu_res_in(EXMEM_alu_res),
        .write_reg_in(EXMEM_write_reg),
        .RegWrite(MEMWB_RegWrite),
        .MemtoReg(MEMWB_MemtoReg),
        .mem_data(MEMWB_mem_data),
        .alu_res(MEMWB_alu_res),
        .write_reg(MEMWB_write_reg)
    );
    
    assign MEMWB_rd_fwd = MEMWB_write_reg;
    assign MEMWB_RegWrite_fwd = MEMWB_RegWrite;
    assign MEMWB_is_swi_fwd = MEMWB_is_swi;

    // ======================== WB Stage ==========================
    wire [31:0] normal_wb_data;
    mux2 #(.N(32)) wb_mux (
        .a(MEMWB_alu_res),
        .b(MEMWB_mem_data),
        .sel(MEMWB_MemtoReg),
        .y(normal_wb_data)
    );

    assign write_data_WB = (MEMWB_is_swi) ? MEMWB_swi_result : normal_wb_data;
    assign write_reg_WB = MEMWB_write_reg;
    assign RegWrite_WB = MEMWB_RegWrite && !MEMWB_is_pmc;

    // ======================== Hazard Detection Instantiation ======
    hazard_detection_unit hdu (
        .IFID_rs(IFID_rs),
        .IFID_rt(IFID_rt),
        .IDEX_rt(IDEX_rt_hazard),
        .IDEX_MemRead(IDEX_MemRead_hazard),
        .EXMEM_is_pmc(EXMEM_is_pmc_hazard),
        .EXMEM_is_jmn(EXMEM_is_jmn_hazard),
        .stall(stall),
        .flush_IFID(flush_IFID_hazard),
        .flush_IDEX(flush_IDEX_hazard)
    );
    
    assign stall_debug = stall;
    assign flush_IFID = flush_IFID_hazard || branch_taken_EX || (IDEX_Jump != 2'b00);
    assign flush_IDEX = flush_IDEX_hazard;

    // ======================== Next PC Logic ======================
    always @(posedge clk) begin
        if (reset) begin
            PC <= 32'd0;
        end
        else if (stall) begin
            PC <= PC;
        end
        else if (EXMEM_is_pmc || EXMEM_is_jmn) begin
            PC <= jump_from_mem;
        end
        else if (branch_taken_EX) begin
            PC <= branch_target_EX;
        end
        else if (IDEX_Jump == 2'b01) begin
            PC <= {IDEX_pc4[31:28], instr_ID[25:0], 2'b00}; // Jump target
        end
        else begin
            PC <= pc4_IF;
        end
    end

    assign pc_out_debug = PC;

endmodule
