package slave_driver_pkg;
  import uvm_pkg::*;
  import slave_sequence_item_pkg::*;
  `include "uvm_macros.svh"

  class slave_driver extends uvm_driver #(slave_sequence_item);
    `uvm_component_utils(slave_driver)
    virtual slave_if slave_if;
    slave_sequence_item slave_seq;

    function new(string name="slave_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        slave_seq = slave_sequence_item::type_id::create("slave_seq");
        seq_item_port.get_next_item(slave_seq);
        slave_if.SS_n = slave_seq.SS_n;
        slave_if.rst_n = slave_seq.rst_n;
        slave_if.tx_valid = slave_seq.tx_valid;
        slave_if.tx_data = slave_seq.tx_data;
        slave_if.MOSI = slave_seq.MOSI;
        @(negedge slave_if.clk);
        seq_item_port.item_done();
        `uvm_info("slave_driver", slave_seq.convert2string_stimulus(), UVM_HIGH)
      end
    endtask
  endclass
endpackage