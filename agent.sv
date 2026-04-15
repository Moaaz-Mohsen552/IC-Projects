package slave_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import slave_sequence_item_pkg::*;
  import slave_monitor_pkg::*;
  import slave_driver_pkg::*;
  import slave_object_pkg::*;
  import sequencer_slave_pkg::*;

  class slave_agent extends uvm_agent;
    `uvm_component_utils(slave_agent)
    slave_config slave_configg;
    slave_sequencer slave_seq;
    slave_monitor my_monitor;
    slave_driver my_driver;
    uvm_analysis_port #(slave_sequence_item) ag;

    function new(string name="slave_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(slave_config)::get(this, "", "cff", slave_configg))
        `uvm_fatal("build_phase", "failed to get this interface");

      if (slave_configg.is_active == UVM_ACTIVE) begin
        slave_seq = slave_sequencer::type_id::create("slave_seq", this);
        my_driver = slave_driver::type_id::create("my_driver", this);
      end

      my_monitor = slave_monitor::type_id::create("my_monitor", this);
      ag = new("ag", this);
    endfunction

function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (slave_configg.is_active == UVM_ACTIVE) begin
    my_driver.slave_if = slave_configg.slave_if;
    my_driver.seq_item_port.connect(slave_seq.seq_item_export);
  end
  my_monitor.slave_if = slave_configg.slave_if;
  my_monitor.mon.connect(ag);
endfunction

endclass

endpackage