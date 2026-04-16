module extend_16_to_32 (
    input  [15:0] instruction,
    input    sign_ext,        
    output reg [31:0] extended_instruction
);
    always @(*) begin
        if(sign_ext)
            extended_instruction = {{16{instruction[15]}}, instruction};  // sign-extend
        else
            extended_instruction = {16'h0000, instruction};              // zero-extend
    end
endmodule

