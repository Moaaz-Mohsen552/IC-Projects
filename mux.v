module mux (in0 ,in1 ,in2 ,in3 , sel , out);
parameter width = 1 ;
parameter inputs = 2 ;
input [width-1 : 0] in0 ;
 input [width-1 : 0] in1 ; 
 input [width-1 : 0] in2 ; 
 input [width-1 : 0] in3 ;
output  reg [width-1 : 0] out ;
input [$clog2(inputs)-1 : 0] sel ;
always @(*) begin
    case (sel)
    0 : out = in0 ;
    1 : out = in1 ;
    2 : out = in2 ;
    3 : out = in3 ;
    endcase
    end
    endmodule