import uvm_pkg::*;
`include "uvm_macros.svh"
import slave_test_pkg::*;

module top;
    bit clk;

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    slave_if varf(clk);

    SLAVE dut (varf);

    bind SLAVE assertions assertions_ins(varf);

    initial begin
        uvm_config_db#(virtual slave_if)::set(null, "*", "s_if", varf);
        run_test("slave_test");
    end

endmodule