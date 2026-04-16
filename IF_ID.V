module IF_ID (
    input clk,
    input reset,
    input flush,
    input IFID_Write,                 // <-- جديد: control stall
    input [31:0] instr_in,
    input [31:0] pc4_in,
    output reg [31:0] instr_out,
    output reg [31:0] pc4_out
);

    always @(posedge clk) begin
        if (reset || flush) begin
            instr_out <= 32'd0;
            pc4_out   <= 32'd0;
        end
        else if (IFID_Write) begin    // <-- فقط لو IFID_Write = 1 نكتب
            instr_out <= instr_in;
            pc4_out   <= pc4_in;
        end
        // else: نحافظ على القيم القديمة (stall)
    end

endmodule