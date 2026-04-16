// alu.v
module ALU (
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0]  alu_op, 
    output reg [31:0] result,
    output zero
);
    always @(*) begin
        case (alu_op)
            3'b000: result = A + B;    // ADD
            3'b001: result = A - B;    // SUB
            3'b010: result = A & B;    // AND
            3'b011: result = A | B;    // OR
            3'b100: result = ( (A) < (B)) ? 32'd1 : 32'd0 ; // SLT
            default: result = 32'd0;
        endcase
    end
    assign zero = (result == 32'd0);
endmodule