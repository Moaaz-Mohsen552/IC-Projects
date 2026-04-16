
module alu_control_unit (
    input [5:0] opcode,
    input [5:0] funct,      
    output reg [2:0] alu_ctrl
);
    always @(*) begin
       
        // If R-type (opcode==0) decode funct
        if (opcode == 6'b000000) begin
            case (funct)
                6'b100000: alu_ctrl = 3'b000; // ADD
                6'b100010: alu_ctrl = 3'b001; // SUB
                6'b100100: alu_ctrl = 3'b010; // AND
                6'b100101: alu_ctrl = 3'b011; // OR
                6'b101010: alu_ctrl = 3'b100; // SLT 
                default:   alu_ctrl = 3'b000;
            endcase
        end else begin
 
            case (opcode)
                6'b001000: alu_ctrl = 3'b000; // ADDI 
                6'b001100: alu_ctrl = 3'b010; // ANDI 
                6'b100011: alu_ctrl = 3'b000; // LW 
                6'b101011: alu_ctrl = 3'b000; // SW 
                6'b000100: alu_ctrl = 3'b001; // BEQ 
              
                6'b100000: alu_ctrl = 3'b000; // PMC 
                6'b100001: alu_ctrl = 3'b000; // JMN 
                6'b100010: alu_ctrl = 3'b000; // SWI 
                default:   alu_ctrl = 3'b000;
            endcase
        end
    end
endmodule
