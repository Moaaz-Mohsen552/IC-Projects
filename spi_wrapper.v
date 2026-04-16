module SPI_Wrapper (input MOSI, SS_n, clk, rst_n, output MISO);
    wire [9:0] rx_data;
    wire [7:0] tx_data;
    wire rx_valid, tx_valid;

    SPI_Slave m1(MOSI, SS_n, tx_valid, clk, rst_n, 
    tx_data, MISO, rx_valid, rx_data);
    RAM m2(clk, rst_n, rx_valid, rx_data, tx_valid, tx_data);

endmodule