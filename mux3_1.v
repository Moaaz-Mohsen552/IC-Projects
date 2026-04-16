
module mux3 #(parameter N = 32) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    input  [N-1:0] c,
    input  [1:0]   sel,
    output [N-1:0] y
);
    assign y = (sel == 2'b00) ? a :
               (sel == 2'b01) ? b :
               (sel == 2'b10) ? c : a;
endmodule
