module assertions (slave_if.dut varf);

    property reset;
        @(posedge varf.clk)
            !varf.rst_n |-> (!varf.MISO && !varf.rx_valid && varf.rx_data == 10'b0);
    endproperty

    sequence write_add_seq;
        $fell(varf.SS_n) ##1 (!varf.MOSI) ##1 (!varf.MOSI) ##1 (!varf.MOSI);
    endsequence

    sequence write_data_seq;
        $fell(varf.SS_n) ##1 (!varf.MOSI) ##1 (!varf.MOSI) ##1 (varf.MOSI);
    endsequence

    sequence read_add_seq;
        $fell(varf.SS_n) ##1 (varf.MOSI) ##1 (varf.MOSI) ##1 (!varf.MOSI);
    endsequence

    sequence read_data_seq;
        $fell(varf.SS_n) ##1 (varf.MOSI) ##1 (varf.MOSI) ##1 (varf.MOSI);
    endsequence

    sequence valid_cmd_seq;
        write_add_seq or write_data_seq or read_add_seq or read_data_seq;
    endsequence

    property rx_valid_after_10;
        @(posedge varf.clk) disable iff (!varf.rst_n)
            (valid_cmd_seq) |-> ##10 (varf.rx_valid && $rose(varf.SS_n)) [*1];
    endproperty
    rx_valid_after_10_assert: assert property (rx_valid_after_10);
reset_assert:             assert property (reset);

rx_valid_after_10_cover:  cover property (rx_valid_after_10);
reset_cover:              cover property (reset);

endmodule