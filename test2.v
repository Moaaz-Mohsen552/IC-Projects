module tb_10;
    reg clk;
    reg reset;
    wire [31:0] pc_out;

    // Instantiate Processor
    top_processor uut (
        .clk(clk),
        .reset(reset),
        .pc_out_debug(pc_out)
    );

    // Clock
    always #5 clk = ~clk;

    // Saved info from previous cycle
    reg        prev_regwrite;
    reg        prev_memwrite;
    reg [4:0]  prev_reg_dst;
    reg [31:0] prev_reg_before;
    reg [31:0] prev_mem_addr;
    reg [31:0] prev_mem_before;
    reg [31:0] prev_pc;
    reg [31:0] prev_inst;

    initial begin
        clk = 0;
        reset = 1;
        #20 reset = 0;
        #500;
        $display("\nSimulation Finished.");
        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin
            /* ===============================
                PRINT AFTER (cycle N+1)
               =============================== */

            if (prev_regwrite && prev_reg_dst != 0) begin
                $display("Time: %0t", $time);
                $display(" PC: %h | INST: %h", prev_pc, prev_inst);
                $display(" REG WRITE  R%0d : BEFORE = %d | AFTER = %d",
                         prev_reg_dst,
                         prev_reg_before,
                         uut.RF.regs[prev_reg_dst]);
                $display("--------------------------------------------------");
            end

            if (prev_memwrite) begin
                $display("Time: %0t", $time);
                $display(" PC: %h | INST: %h", prev_pc, prev_inst);
                $display(" MEM WRITE  Addr %h : BEFORE = %h | AFTER = %h",
                         prev_mem_addr,
                         prev_mem_before,
                         uut.dmem.mem[prev_mem_addr[9:2]]);
                $display("--------------------------------------------------");
            end

            /* ===============================
                CAPTURE BEFORE (cycle N)
               =============================== */

            prev_pc       <= pc_out;
            prev_inst     <= uut.instruction;

            prev_regwrite <= uut.RF.regwrite;
            prev_memwrite <= uut.MemWrite;

            prev_reg_dst  <= uut.write_reg_final;
            prev_mem_addr <= uut.alu_result;

            prev_reg_before <= (uut.write_reg_final == 0) ? 0 :
                               uut.RF.regs[uut.write_reg_final];

            prev_mem_before <= uut.dmem.mem[uut.alu_result[9:2]];
        end
    end
endmodule