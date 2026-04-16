module tb_15;

    reg clk;
    reg reset;

    wire [31:0] pc_out;
    wire [31:0] current_instr;

    // Debug signals
    wire stall;
    wire [1:0] forwardA;
    wire [1:0] forwardB;

    // Instantiate the Pipelined Processor
    top_processor_pipelined_with_hazards uut (
        .clk(clk),
        .reset(reset),
        .pc_out_debug(pc_out),
        .current_instr_debug(current_instr),
        .stall_debug(stall),
        .forwardA_debug(forwardA),
        .forwardB_debug(forwardB)
    );

    // ================= Clock Generation =================
    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;

    // ================= Test Sequence ====================
    initial begin
        // Initialize
        clk   = 0;
        reset = 1;

        // Apply reset
        #20;
        reset = 0;

        // Run long enough to flush pipeline
        // Pipeline needs more cycles than single-cycle
        #500;

        $display("=================================");
        $display(" Simulation Finished Successfully");
        $display("=================================");
        $finish;
    end

    // ================= Monitor ==========================
    initial begin
        $monitor(
            "T=%0t | PC=%h | Inst=%h | Stall=%b | fwdA=%b | fwdB=%b",
            $time,
            pc_out,
            current_instr,
            stall,
            forwardA,
            forwardB
        );
    end

    // ================= Final State Check =================
    initial begin
        #480;
        $display("\n========= FINAL STATE =========");

        // Register File check
        $display("R1 = %d", uut.RF.regs[1]);
        $display("R2 = %d", uut.RF.regs[2]);
        $display("R3 = %d", uut.RF.regs[3]);
        $display("R4 = %d", uut.RF.regs[4]);

        // Data memory check (example address)
        $display("Mem[20] = %h", uut.DM.mem[20 >> 2]);

        $display("================================\n");
    end

endmodule
