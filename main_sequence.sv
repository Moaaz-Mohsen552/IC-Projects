package slave_main_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_sequence_item_pkg::*;

    class slave_main_seq extends uvm_sequence#(slave_sequence_item);

        `uvm_object_utils(slave_main_seq)
        slave_sequence_item req;
        bit check;

        function new(string name="slave_main_seq");
            super.new(name);
        endfunction

        task body();
            req = slave_sequence_item::type_id::create("req");
            req.counter = 11;
            req.old_MOSI_bits = 0;
            req.SS_n = 1;
            req.ss_count = 0;
            req.maxx = 13;

            repeat (10000) begin
                start_item(req);
                assert (req.randomize());
                finish_item(req);
            end
        endtask

    endclass

endpackage