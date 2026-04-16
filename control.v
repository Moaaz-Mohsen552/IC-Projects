module control_unit (
    input  [5:0] opcode,




    output reg [1:0] RegDst,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg [1:0] Jump,

    output reg       sign_ext,

    output reg       is_pmc,
    output reg       is_jmn,
    output reg       is_swi,

    output reg       sel_mux2,   // memory read address selector
    output reg       sel_mux3    // memory write data selector
);

always @(*) begin
    // ================= DEFAULTS =================
    RegDst   = 2'b00;
    ALUSrc   = 1'b0;
    MemtoReg = 1'b0;
    RegWrite = 1'b0;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    Branch   = 1'b0;
    Jump     = 2'b00;
    sign_ext = 1'b1;

    is_pmc   = 1'b0;
    is_jmn   = 1'b0;
    is_swi   = 1'b0;

    sel_mux2 = 1'b0;
    sel_mux3 = 1'b0;

    // ================= DECODE =================
    if (opcode == 6'b000000) begin // R-type
        RegDst   = 2'b01;
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
   end else if (opcode == 6'b001000) begin // ADDI
        RegDst   = 2'b00;
        ALUSrc   = 1'b1;
        RegWrite = 1'b1;
        sign_ext = 1'b1;
        MemtoReg = 1'b0;
    end else if (opcode == 6'b001100) begin // ANDI
        RegDst   = 2'b00;
        ALUSrc   = 1'b1;
        RegWrite = 1'b1;
        sign_ext = 1'b0;
        MemtoReg = 1'b0;
    end else if (opcode == 6'b100011) begin // LW
        RegDst   = 2'b00;
        ALUSrc   = 1'b1;
        MemtoReg = 1'b1;
        RegWrite = 1'b1;
        MemRead  = 1'b1;
        sel_mux2 = 1'b1;
    end else if (opcode == 6'b101011) begin // SW
    ALUSrc   = 1'b1;
    MemWrite = 1'b1;
    sel_mux2 = 1'b1;
    sel_mux3 = 1'b1; // write_data = rt
end else if (opcode == 6'b000100) begin // BEQ
        ALUSrc   = 1'b0; // needed for branch offset calculation
        Branch   = 1'b1;
    end else if (opcode == 6'b000010) begin // J
        Jump = 2'b01;
    end  else if (opcode == 6'b100000) begin // PMC
    is_pmc   = 1'b1;
    ALUSrc   = 1'b1;      // for rs + imm (write address)
    MemRead  = 1'b1;      // read from memory (for jump target)
    sel_mux2 = 1'b0;      //  read address = rt (NOT rs+imm)
    Jump     = 2'b10;
    MemWrite = 1'b1;      // write PC+4 into memory
    sel_mux3 = 1'b0;      // write_data = pc_plus4
    MemtoReg = 1'b1;
end else if (opcode == 6'b100001) begin // JMN
    is_jmn   = 1'b1;
    ALUSrc   = 1'b1;      // for rs + imm (read address)
    MemRead  = 1'b1;
    sel_mux2 = 1'b1;      // read address = rs + imm
    Jump     = 2'b10;
    MemtoReg = 1'b1;
    end else if (opcode == 6'b100010) begin // SWI
        is_swi   = 1'b1;
        ALUSrc   = 1'b1;      // for address (rs+imm) and for write-back (rs+imm)
        MemWrite = 1'b1;
        RegWrite = 1'b1;
        sel_mux3 = 1'b1;      // write_data = rt
        RegDst   = 2'b10;
        MemtoReg = 1'b0;
end
end

endmodule
