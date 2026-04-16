module MEM_WB (
    input clk,
    input reset,

    input RegWrite_in,
    input MemtoReg_in,
    input [31:0] mem_data_in,
    input [31:0] alu_res_in,
    input [4:0] write_reg_in,

    output reg RegWrite,
    output reg MemtoReg,
    output reg [31:0] mem_data,
    output reg [31:0] alu_res,
    output reg [4:0] write_reg
);

    always @(posedge clk) begin
        if (reset) begin
            RegWrite  <= 0;
            MemtoReg  <= 0;
            mem_data  <= 0;
            alu_res   <= 0;
            write_reg <= 0;
        end else begin
            RegWrite  <= RegWrite_in;
            MemtoReg  <= MemtoReg_in;
            mem_data  <= mem_data_in;
            alu_res   <= alu_res_in;
            write_reg <= write_reg_in;
        end
    end

endmodule