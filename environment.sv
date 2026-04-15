package slave_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import slave_scoreboard_pkg::*;
  import slave_coverage_pkg::*;
  import slave_agent_pkg::*;

  class slave_env extends uvm_env;
    `uvm_component_utils(slave_env)
    slave_coverage_collector cov;
    slave_scoreboard score;
    slave_agent age;

    function new(string name="slave_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      cov = slave_coverage_collector::type_id::create("cov", this);
      score = slave_scoreboard::type_id::create("score", this);
      age = slave_agent::type_id::create("age", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      age.ag.connect(cov.sb);
      age.ag.connect(score.sb);
    endfunction

  endclass
endpackage