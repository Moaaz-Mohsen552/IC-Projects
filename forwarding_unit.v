module forwarding_unit (
    input [4:0] IDEX_rs,
    input [4:0] IDEX_rt,
    input [4:0] EXMEM_rd,
    input [4:0] MEMWB_rd,
    input EXMEM_RegWrite,
    input MEMWB_RegWrite,
    input EXMEM_is_swi,  // SWI writes to rs register
    input MEMWB_is_swi,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    
    always @(*) begin
        // Default: no forwarding
        forwardA = 2'b00;
        forwardB = 2'b00;
        
        // EX Hazard: Forward from EX/MEM stage
        // Check if EX/MEM will write to a register and it's not R0
        if (EXMEM_RegWrite && (EXMEM_rd != 5'b0)) begin
            // Forward to ALU input A
            if (EXMEM_rd == IDEX_rs)
                forwardA = 2'b10;
            
            // Forward to ALU input B
            if (EXMEM_rd == IDEX_rt)
                forwardB = 2'b10;
            
            // Special case for SWI: SWI writes to rs register (not rd)
            if (EXMEM_is_swi && (IDEX_rs == EXMEM_rd))
                forwardA = 2'b10;
        end
        
        // MEM Hazard: Forward from MEM/WB stage
        // Check if MEM/WB will write to a register and it's not R0
        if (MEMWB_RegWrite && (MEMWB_rd != 5'b0)) begin
            // Don't forward if EX hazard already handled the same register
            if (!(EXMEM_RegWrite && (EXMEM_rd != 5'b0) && (EXMEM_rd == IDEX_rs))) begin
                if (MEMWB_rd == IDEX_rs)
                    forwardA = 2'b01;
            end
            
            if (!(EXMEM_RegWrite && (EXMEM_rd != 5'b0) && (EXMEM_rd == IDEX_rt))) begin
                if (MEMWB_rd == IDEX_rt)
                    forwardB = 2'b01;
            end
            
            // Special case for SWI
            if (MEMWB_is_swi && (IDEX_rs == MEMWB_rd) && 
                !(EXMEM_is_swi && (IDEX_rs == EXMEM_rd)))
                forwardA = 2'b01;
        end
    end
    
endmodule
