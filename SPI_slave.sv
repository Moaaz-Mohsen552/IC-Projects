module SLAVE (slave_if.dut varf);

    localparam IDLE     = 3'b000;
    localparam WRITE    = 3'b001;
    localparam CHK_CMD  = 3'b010;
    localparam READ_ADD = 3'b110;
    localparam READ_DATA = 3'b111;

    reg [3:0] counter;
    reg received_address;
    reg [2:0] cs, ns;

    // FSM: state register
    always @(posedge varf.clk) begin
        if (~varf.rst_n)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // FSM: next-state logic
    always @(*) begin
        case (cs)
            IDLE     : ns = (varf.SS_n) ? IDLE : CHK_CMD;
            CHK_CMD  : begin
                if (varf.SS_n)
                    ns = IDLE;
                else if (~varf.MOSI)
                    ns = WRITE;
                else
                    ns = (received_address) ? READ_DATA : READ_ADD;
            end
            WRITE    : ns = (varf.SS_n) ? IDLE : WRITE;
            READ_ADD : ns = (varf.SS_n) ? IDLE : READ_ADD;
            READ_DATA: ns = (varf.SS_n) ? IDLE : READ_DATA;
            default  : ns = IDLE;
        endcase
    end

always @(posedge varf.clk) begin
    if (~varf.rst_n) begin
        counter        <= 10;
        varf.rx_data   <= 0;
        varf.rx_valid  <= 0;
        received_address <= 0;
        varf.MISO      <= 0;
    end
    else begin
        varf.rx_valid <= 1'b0;
        case (cs)
            IDLE: begin
                counter     <= 4'b10;
                varf.rx_valid <= 1'b0;
                varf.MISO   <= 1'b0;
            end

            CHK_CMD : counter <= 10;

            WRITE : begin
                if (counter > 0) begin
                    varf.rx_data[counter-1] <= varf.MOSI;
                    counter <= counter - 1;
                end
                else
                    varf.rx_valid <= 1;
            end
READ_ADD : begin
    if (counter > 0) begin
        varf.rx_data[counter-1] <= varf.MOSI;
        counter <= counter - 1;
    end
    else begin
        varf.rx_valid <= 1;
        received_address <= 1;
    end
end

READ_DATA : begin
    if (varf.tx_valid) begin
        varf.rx_valid <= 0;
        if (counter > 0) begin
            varf.MISO <= varf.tx_data[counter-1];
            counter <= counter - 1;
        end
        else
            received_address <= 0;
    end
    else begin
        if (counter > 0) begin
            varf.rx_data[counter-1] <= varf.MOSI;
            counter <= counter - 1;
        end
        else begin
            varf.rx_valid <= 1;
            counter <= 8;
        end
    end
end
default : varf.rx_valid <= 0;
endcase
    end
end
`ifdef SIM

    property IDLE_to_CHK_CMD;
        @(posedge varf.clk) disable iff(!varf.rst_n)
            (cs == IDLE && !varf.SS_n)
            |-> cs == CHK_CMD;
    endproperty

    property CHK_CMD_to_WRITE;
        @(posedge varf.clk) disable iff(!varf.rst_n)
            (cs == CHK_CMD && !varf.SS_n && !varf.MOSI)
            |-> cs == WRITE;
    endproperty

    property CHK_CMD_to_READ_ADD;
        @(posedge varf.clk) disable iff(!varf.rst_n)
            (cs == CHK_CMD && !varf.SS_n && varf.MOSI && !received_address)
            |-> cs == READ_ADD;
    endproperty

    property CHK_CMD_to_READ_DATA;
        @(posedge varf.clk) disable iff(!varf.rst_n)
            (cs == CHK_CMD && !varf.SS_n && varf.MOSI && received_address)
            |-> cs == READ_DATA;
    endproperty

    IDLE_to_CHK_CMD_assert:     assert property (IDLE_to_CHK_CMD);
    CHK_CMD_to_WRITE_assert:    assert property (CHK_CMD_to_WRITE);
    CHK_CMD_to_READ_ADD_assert: assert property (CHK_CMD_to_READ_ADD);
    CHK_CMD_to_READ_DATA_assert:assert property (CHK_CMD_to_READ_DATA);

    IDLE_to_CHK_CMD_cover:      cover property (IDLE_to_CHK_CMD);
    CHK_CMD_to_WRITE_cover:     cover property (CHK_CMD_to_WRITE);
    CHK_CMD_to_READ_ADD_cover:  cover property (CHK_CMD_to_READ_ADD);
    CHK_CMD_to_READ_DATA_cover: cover property (CHK_CMD_to_READ_DATA);

`endif

endmodule

