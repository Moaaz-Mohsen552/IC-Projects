interface slave_if(input bit clk);

    logic MOSI, MISO, SS_n, tx_valid, rx_valid, rst_n, ref_rx_valid;
    logic [7:0] tx_data;
    logic [9:0] rx_data;

    modport dut (
        input  clk, rst_n, MOSI, SS_n, tx_valid, tx_data,
        output MISO, rx_data, rx_valid
    );

endinterface