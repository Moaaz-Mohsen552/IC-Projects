module dsp ( A, B,C,D, CLK , CARRYIN , OPMODE , RSTA, RSTB , RSTP , RSTM , RSTC , RSTD , RSTCARRYIN 
, RSTOPMODE , CEA , CEB , CEC , CED , CEM , CEP , CECARRYIN , CEOPMODE ,PCIN , P , M , PCOUT
, BCOUT , CARRYOUT , CARRYOUTF , BCIN 
 ) ;

 // inputs & outputs

 input [17:0] A,B,D, BCIN ;
 input [ 47:0] C, PCIN ;
 input CLK , CARRYIN, RSTA, RSTB , RSTC , RSTD , RSTM ,RSTP ,CEA , CEB , CEC , CED , CEM , CEP
 , CECARRYIN , CEOPMODE , RSTOPMODE , RSTCARRYIN  ;
 input [7:0] OPMODE ;
 output [17:0] BCOUT;
 output [47:0] PCOUT , P ;
 output [35:0] M;
 output CARRYOUT , CARRYOUTF ;

 // parameters 
 
 parameter A0REG = 0 , A1REG = 1 ;
 parameter B0REG = 0 , B1REG = 1 ;
 parameter CREG=1 , DREG=1 , MREG=1 , PREG=1 , CARRYINREG=1 , CARRYOUTREG=1 , OPMODEREG = 1 ;
 parameter RSTTYPE = "SYNC" , CARRYINSEL ="OPMODES" , B_INPUT = "DIRECT";

 // internal wires 

 wire [17:0] a0_out , a0_reg_out , a1_out , a1_reg_out ;
 wire [17:0] b0_out , b0_reg_out , b_mux_out , b1_out , b1_out_reg  ;
 wire [17:0] d_out , d_out_reg ;
 wire [47:0] c_out , c_out_reg ;
 wire [17:0] pre_add_sub_out ;
 wire [7:0] opmode_out , opmode_reg_out ;
 wire carryin_mux_out , carryin_out , carryin_reg_out ;
 wire [35:0] multi_out , m_out , m_reg_out ;
 wire carry_out , carry_reg_out ;
 wire [47:0] x_mux_out , z_mux_out ;
 wire [47:0] final_add_sub , p_reg_out ;
 wire [47:0] concatenated_buses ;
wire [17:0] opmode4_mux_out ;

// path A0

dff #(.width(18), .RSTTYPE(RSTTYPE)) a0_reg(.clk(CLK) , .d(A) , .q(a0_reg_out) , .rst(RSTA) , 
.CE(CEA)) ;
mux #(.width(18) , .inputs(2)) a0_mux( .in0(A) , .in1(a0_reg_out) , .in2(18'b0) , .in3(18'b0) ,
.sel(A0REG[0]) , .out(a0_out)) ;

//path A1

dff #(.width(18), .RSTTYPE(RSTTYPE)) a1_reg(.clk(CLK) , .d(a0_out) , .q(a1_reg_out), .rst(RSTA)
, .CE(CEA)) ;
mux# (.width(18) , .inputs(2)) a1_mux(.in0(a1_reg_out) , .in1(a0_out) , .in2(18'b0) , 
.in3(18'b0) , .sel(A1REG[0]) , .out(a1_out)) ;

// path B0 

mux #(.width(18) , .inputs(2)) b_mux_input(.in0(B) , .in1(BCIN) , .in2(18'b0) , .in3(18'b0) ,
.sel(B_INPUT == "CASCADE") , .out(b_mux_out)) ;
dff #(.width(18) , .RSTTYPE(RSTTYPE)) b1_reg(.clk(CLK) , .rst(RSTB) , .d(b_mux_out) , .q(b0_reg_out) ,
.CE(CEB)) ;
mux #(.width(18) , .inputs(2)) b0_mux(.in0(b0_reg_out) , .in1(b_mux_out) , .in2(18'b0) , 
.in3(18'b0) , .sel(B0REG[0]) , .out(b0_out)) ;

// path B1

dff #(.width(18) , .RSTTYPE(RSTTYPE)) b1_reg1(.clk(CLK) , .rst(RSTB) , .d(opmode4_mux_out) , 
.q(b1_out_reg) , .CE(CEB)) ;
mux #(.width(18) , .inputs(2)) b1_mux(.in0(b1_out_reg) , .in1(opmode4_mux_out) , .in2(18'b0) , 
.in3(18'b0) ,  .sel(B1REG[0]) , .out(b1_out)) ;
assign BCOUT = b1_out ;

// path C 

dff #(.width(48) , .RSTTYPE(RSTTYPE)) c_reg(.clk(CLK) , .rst(RSTC) , .d(C) , .q(c_out_reg) , 
.CE(CEC)) ;
mux #(.width(48) , .inputs(2)) c_mux(.in0(c_out_reg) , .in1(C) , .in2(18'b0) , .in3(18'b0)
, .sel(CREG[0]) , .out(c_out) ) ;

// path D

dff #(.width(18) , .RSTTYPE(RSTTYPE)) d_reg(.rst(RSTD) , .clk(CLK) ,  .d(D) , .q(d_out_reg) , 
.CE(CED)) ;

mux #(.width(18) , .inputs(2)) d_mux(.in0(d_out_reg) , .in1(D) , .in2(18'b0) , .in3(18'b0) ,
.sel(DREG[0]) , .out(d_out)) ;

// OPMODE 

dff #(.width(8) , .RSTTYPE(RSTTYPE)) opmode_reg(.clk(CLK) , .rst(RSTOPMODE) , .d(OPMODE) , 
.q(opmode_reg_out) , .CE(CEOPMODE)) ;
 

mux #(.width(8) , .inputs(2)) opmode_mux(.in0(OPMODE) , .in1(opmode_reg_out) , .in2(8'b0) , 
.in3(8'b0) , .sel(OPMODEREG[0]) ,  .out(opmode_out)) ;

// PRE_ADDER_SUB 
assign pre_add_sub_out = OPMODE[6] ? (d_out-b0_out) : d_out+b0_out ;

// OPMODE{4} MUX
assign opmode4_mux_out = OPMODE[4] ? pre_add_sub_out : b0_out ;

// MULIPLICATION 
assign multi_out = b1_out * a1_out ;

// M

dff #(.width(36) , .RSTTYPE(RSTTYPE)) M_reg(.clk(CLK) , .rst(RSTM) ,  .d(multi_out) , .q(m_reg_out) 
, .CE(CEM)) ;
mux #(.width(36) , .inputs(2)) m_mux(.in0(m_reg_out) , .in1(multi_out) , .sel(MREG[0]) 
, .in2(36'b0) , .in3(36'b0) , .out(m_out)) ;

assign M = m_out ;

// concatenated 

assign concatenated = {d_out[11:0] , a1_out , b1_out} ;

// X MUX

mux #(.width(48) , .inputs(4)) x_mux( .in0(P) , .in1(concatenated) , .in2({{12{1'b0}} , m_out}) ,
.in3(48'b0) , .sel(OPMODE[1:0]) , .out(x_mux_out)) ;

// Z MUX 

mux #(.width(48) , .inputs(4)) z_mux(.in0(c_out) , .in1(P) , .in2(PCIN) , .in3(48'b0) , 
.sel(OPMODE[3:2]) , .out(z_mux_out)) ;

// carry in 

mux #(.width(1) , .inputs(2)) carry_in_mux(.in0(OPMODE[5]) , .in1(CARRYIN) ,
.sel(CARRYINSEL=="OPMODES") , .out(carryin_mux_out)) ;

dff #(.width(1) , .RSTTYPE(RSTTYPE)) carry_in_reg(.rst(RSTCARRYIN) , .clk(CLK) , .d(carryin_mux_out) , 
.q(carryin_reg_out) , .CE(CECARRYIN)) ;

mux #(.width(1) , .inputs(2)) carry_in_mux2(.in0(carryin_reg_out) , .in1(carryin_mux_out) , 
.sel(CARRYINREG[0]) , .out(carryin_out)) ;

// final ADD_SUB 

assign final_add_sub = OPMODE[7] ? z_mux_out-(carryin_out+x_mux_out) :z_mux_out+carryin_out+x_mux_out ;

// CARRY_OUT 

dff #(.width(1) , .RSTTYPE(RSTTYPE)) carryout_reg(.clk(CLK) , .rst(RSTCARRYIN) , .d(carry_out) , 
.q(carry_out_reg) , .CE(CARRYIN)) ;

mux #(.width(1) , .inputs(2)) carry_out_mux(.in0(carry_out_reg) , .in1(carry_out) , 
.in2(1'b0) , .in3(1'b0) , .sel(CARRYINREG[0]) , .out(CARRYOUT)) ; 
 assign CARRYOUTF = CARRYOUT ;

// P OUTPUT 

dff #(.width(18) , .RSTTYPE(RSTTYPE)) p_out_reg(.rst(RSTP) , .clk(CLK) , .d(final_add_sub) , 
.q(p_reg_out) , .CE(CEP)) ;

mux #(.width(48) , .inputs(2)) p_mux(.in0(p_reg_out) , .in1(final_add_sub) , .in2(48'b0) , 
.in3(48'b0) , .sel(CARRYOUTREG[0]) , .out(P)) ;
assign PCOUT = P ; 

endmodule

 







 