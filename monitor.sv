package slave_monitor_pkg;
  import uvm_pkg::*;
  import slave_sequence_item_pkg::*;
  `include "uvm_macros.svh"

  class slave_monitor extends uvm_monitor;
    `uvm_component_utils(slave_monitor)
    virtual slave_if slave_if;
    slave_sequence_item slave_seq;
    uvm_analysis_port #(slave_sequence_item) mon;

    function new(string name="slave_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual slave_if)::get(this, "", "s_if", slave_if))
        `uvm_fatal("NOVIF", "virtual interface not provided to slave_monitor")
      mon = new("mon", this);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        slave_seq = slave_sequence_item::type_id::create("slave_seq");
        @(negedge slave_if.clk);
        slave_seq.rst_n = slave_if.rst_n;
        slave_seq.tx_valid = slave_if.tx_valid;
        slave_seq.MOSI = slave_if.MOSI;
        if (slave_if.tx_valid) slave_seq.MISO = slave_if.MISO;
        slave_seq.rx_valid = slave_if.rx_valid;
        slave_seq.SS_n = slave_if.SS_n;
        slave_seq.tx_data = slave_if.tx_data;
        if (slave_if.rx_valid) slave_seq.rx_data = slave_if.rx_data;

        mon.write(slave_seq);
        `uvm_info("run_phase", slave_seq.convert2string_stimulus(), UVM_HIGH)
      end
    endtask
  endclass
endpackage