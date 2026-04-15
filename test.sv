package slave_test_pkg;
    import slave_env_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_agent_pkg::*;
    import seq::*;
    import slave_main_seq_pkg::*;
    import slave_object_pkg::*;
    import slave_env_pkg::*;

    class slave_test extends uvm_test;

        `uvm_component_utils(slave_test)
        slave_env env;
        slave_config envv;
        reset_seq rese;
        slave_main_seq maini;
        virtual slave_if slave_if;

        function new(string name="slave_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            env = slave_env::type_id::create("env", this);
            envv = slave_config::type_id::create("envv", this);
            rese = reset_seq::type_id::create("rese", this);
            maini = slave_main_seq::type_id::create("maini", this);

            envv.is_active = UVM_ACTIVE;

            if (!uvm_config_db#(virtual slave_if)::get(this, "", "s_if", envv.slave_if)) begin
                `uvm_fatal("build_phase", "failed to get this interface");
            end

            uvm_config_db#(slave_config)::set(this, "*", "cfg", envv);
        endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    `uvm_info("run_phase", "NOT RESETED YET", UVM_LOW);
    rese.start(env.age.slave_seq);
    `uvm_info("run_phase", " RESETED ", UVM_LOW);

    `uvm_info("run_phase", " DATA STARTED ", UVM_LOW);
    maini.start(env.age.slave_seq);
    `uvm_info("run_phase", " DATA ENDED ", UVM_LOW);
    phase.drop_objection(this);

endtask

endclass

endpackage