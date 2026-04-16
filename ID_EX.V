module ID_EX (
    input clk,
    input reset,
    input flush,

    input  [31:0] pc4_in,
    input  [31:0] rd1_in,
    input  [31:0] rd2_in,
    input  [31:0] imm_in,

    input  [4:0] rs_in,
    input  [4:0] rt_in,
    input  [4:0] rd_in,
    input  [5:0] opcode_in,
    input  [5:0] funct_in,

    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemtoReg_in,
    input Branch_in,
    input ALUSrc_in,
    input [1:0] RegDst_in,

    output reg [31:0] pc4,
    output reg [31:0] rd1,
    output reg [31:0] rd2,
    output reg [31:0] imm,

    output reg [4:0] rs,
    output reg [4:0] rt,
    output reg [4:0] rd,
    output reg [5:0] opcode,
    output reg [5:0] funct,

    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg ALUSrc,
    output reg [1:0] RegDst
);

    always @(posedge clk) begin
        if (reset || flush) begin
            pc4 <= 0; rd1 <= 0; rd2 <= 0; imm <= 0;
            rs <= 0; rt <= 0; rd <= 0;
            opcode <= 0; funct <= 0;

            // bubble = all control zero
            RegWrite <= 0;
            MemRead  <= 0;
            MemWrite <= 0;
            MemtoReg <= 0;
            Branch   <= 0;
            ALUSrc   <= 0;
            RegDst   <= 0;
        end 
        else begin
            pc4 <= pc4_in;
            rd1 <= rd1_in;
            rd2 <= rd2_in;
            imm <= imm_in;
            rs  <= rs_in;
            rt  <= rt_in;
            rd  <= rd_in;
            opcode <= opcode_in;
            funct  <= funct_in;

            RegWrite <= RegWrite_in;
            MemRead  <= MemRead_in;
            MemWrite <= MemWrite_in;
            MemtoReg <= MemtoReg_in;
            Branch   <= Branch_in;
            ALUSrc   <= ALUSrc_in;
            RegDst   <= RegDst_in;
        end
    end

endmodule