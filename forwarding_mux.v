module mux3 #(parameter N = 32) (
    input  [N-1:0] a,    // 00: From register file
    input  [N-1:0] b,    // 01: From MEM/WB stage
    input  [N-1:0] c,    // 10: From EX/MEM stage
    input  [1:0]   sel,
    output reg [N-1:0] y
);
    
    always @(*) begin
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            default: y = a;
        endcase
    end
    
endmodule