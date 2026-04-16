module dff ( q , rst , d , CE , clk ) ;
parameter width = 1 ;
parameter RSTTYPE = "SYNC" ;
input [width-1 : 0 ] d ;
output reg [width-1 : 0] q ;
input clk , rst , CE ;
generate 
    if (RSTTYPE == "ASYNC") begin 
        always @(posedge clk or posedge rst) begin 
            if (rst) 
            q <= {width{1'b0}} ;
            else if (CE) 
            q <= d;
        end
    end
    else begin 
            always @( posedge clk ) begin 
                if (rst) 
                q <= {width{1'b0}} ;
                else if (CE)
                q <= d ;
            end
        end
    
endgenerate
endmodule

