module hazard_detection_unit (
    input [4:0] IFID_rs,
    input [4:0] IFID_rt,
    input [4:0] IDEX_rt,
    input IDEX_MemRead,
    input EXMEM_is_pmc,
    input EXMEM_is_jmn,
    output reg stall,
    output reg flush_IFID,
    output reg flush_IDEX
);
    
    always @(*) begin
        stall = 1'b0;
        flush_IFID = 1'b0;
        flush_IDEX = 1'b0;
        
        // Load-Use Hazard Detection
        // If previous instruction is LW (or memory read) and its destination 
        // matches current instruction's source register
        if (IDEX_MemRead && 
            ((IDEX_rt == IFID_rs) || (IDEX_rt == IFID_rt))) begin
            stall = 1'b1;
            flush_IFID = 1'b1;
            flush_IDEX = 1'b1;
        end
        
        // Control Hazards: Flush pipeline on jumps/branches
        // For PMC and JMN, we need to flush pipeline
        if (EXMEM_is_pmc || EXMEM_is_jmn) begin
            flush_IFID = 1'b1;
            flush_IDEX = 1'b1;
        end
    end
    
endmodule
