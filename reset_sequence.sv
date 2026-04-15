package seq;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_sequence_item_pkg::*;

    class reset_seq extends uvm_sequence#(slave_sequence_item);

        `uvm_object_utils(reset_seq)
        slave_sequence_item slave_seq;

        function new(string name="reset_seq");
            super.new(name);
        endfunction

        task body();
            slave_seq = slave_sequence_item::type_id::create("slave_seq");
            start_item(slave_seq);
            slave_seq.rst_n = 0;
            slave_seq.tx_valid = 0;
            slave_seq.MOSI = 0;
            slave_seq.SS_n = 1;
            slave_seq.tx_data = 0;
            finish_item(slave_seq);
        endtask

    endclass

endpackage