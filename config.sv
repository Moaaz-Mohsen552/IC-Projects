package slave_object_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class slave_config extends uvm_object;
    `uvm_object_utils(slave_config)
    virtual slave_if slave_if;
    uvm_active_passive_enum is_active;

    function new(string name="slave_config");
      super.new(name);
    endfunction

  endclass
endpackage