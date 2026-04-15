package sequencer_slave_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import slave_sequence_item_pkg::*;

  class slave_sequencer extends uvm_sequencer #(slave_sequence_item);
    `uvm_component_utils(slave_sequencer)

    function new(string name="slave_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction

  endclass
endpackage