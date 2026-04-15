package slave_coverage_pkg;
    import slave_sequence_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_object_pkg::*;
    import sequencer_slave_pkg::*;
    import slave_agent_pkg::*;

    class slave_coverage_collector extends uvm_component;

        `uvm_component_utils(slave_coverage_collector)
        uvm_analysis_export #(slave_sequence_item) sb;
        uvm_tlm_analysis_fifo #(slave_sequence_item) fi;
        slave_sequence_item slave_seq;

        bit [2:0] mosi_shift;
        int mosi_count;

        covergroup cg;
            cp_trans: coverpoint slave_seq.rx_data[9:8] {
                bins all_vals[] = {2'b00, 2'b01, 2'b10, 2'b11};
                bins trans[] = (2'b00, 2'b01, 2'b10, 2'b11 => 2'b00, 2'b01, 2'b10, 2'b11);
            }

            ss_n_tr: coverpoint slave_seq.SS_n {
                bins normal_len[] = (1[*1] => 0[*13] => 1[*1]);
                bins extended_len[] = (1[*1] => 0[*23] => 1[*1]);
            }

            valid_op: coverpoint mosi_shift {
                bins write_addr  = {3'b000};
                bins write_data  = {3'b001};
                bins read_addr   = {3'b110};
                bins read_data   = {3'b111};
            }

            cross ss_n_tr, valid_op {
                option.cross_auto_bin_max = 0;
                bins write_addr_x   = binsof(ss_n_tr.normal_len) && binsof(valid_op.write_addr);
                bins write_data_x   = binsof(ss_n_tr.normal_len) && binsof(valid_op.write_data);
                bins read_addr_x    = binsof(ss_n_tr.normal_len) && binsof(valid_op.read_addr);
                bins read_data_x    = binsof(ss_n_tr.normal_len) && binsof(valid_op.read_data);

                ignore_bins illegal_1 = binsof(ss_n_tr.normal_len) && binsof(valid_op.read_data);
                ignore_bins illegal_2 = binsof(ss_n_tr.extended_len) && binsof(valid_op.write_addr);
                ignore_bins illegal_3 = binsof(ss_n_tr.extended_len) && binsof(valid_op.write_data);
                ignore_bins illegal_4 = binsof(ss_n_tr.extended_len) && binsof(valid_op.read_addr);
            }
        endgroup

function new(string name="slave_coverage_collector", uvm_component parent = null);
    super.new(name, parent);
    cg = new();
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb = new("sb", this);
    fi = new("fi", this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sb.connect(fi.analysis_export);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
    mosi_shift = 3'b000;
    forever begin
        fi.get(slave_seq);
        if (mosi_count < 3) begin
            mosi_count++;
            mosi_shift = {mosi_shift[1:0], slave_seq.MOSI};
        end
        else
            mosi_count = 0;
        cg.sample();
    end
endtask

endclass

endpackage