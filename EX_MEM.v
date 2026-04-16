module EX_MEM (
    input clk,
    input reset,

    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,
    input Branch_in,

    input zero_in,
    input [31:0] alu_res_in,
    input [31:0] rd2_in,
    input [31:0] branch_target_in,
    input [4:0] write_reg_in,

    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,

    output reg zero,
    output reg [31:0] alu_res,
    output reg [31:0] rd2,
    output reg [31:0] branch_target,
    output reg [4:0] write_reg
);

    always @(posedge clk) begin
        if (reset) begin
            RegWrite      <= 0;
            MemRead       <= 0;
            MemWrite      <= 0;
            MemtoReg      <= 0;
            Branch        <= 0;
            zero          <= 0;
            alu_res       <= 0;
            rd2           <= 0;
            branch_target <= 0;
            write_reg     <= 0;
        end else begin
            RegWrite      <= RegWrite_in;
            MemRead       <= MemRead_in;
            MemWrite      <= MemWrite_in;
            MemtoReg      <= MemtoReg_in;
            Branch        <= Branch_in;
            zero          <= zero_in;
            alu_res       <= alu_res_in;
            rd2           <= rd2_in;
            branch_target <= branch_target_in;
            write_reg     <= write_reg_in;
        end
    end

endmodule