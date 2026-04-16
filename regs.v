// regfile32.v
module regfile32 (
    input clk,
    input reset,
    input regwrite,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:31];
    integer i;
    
    assign read_data1 = (read_reg1 == 5'd0) ? 32'd0 : regs[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? 32'd0 : regs[read_reg2];

    always @(posedge clk) begin
        if (reset) begin
            for (i=0;i<32;i=i+1) regs[i] <= 32'd0;
        end else begin
            if (regwrite && (write_reg != 5'd0)) regs[write_reg] <= write_data;
        end
    end
endmodule

