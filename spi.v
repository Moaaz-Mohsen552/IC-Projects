module SPI_Slave (
    input MOSI,
    input SS_n,
    input tx_valid,
    input clk,
    input rst_n,
    input [7:0] tx_data,
    output reg MISO,
    output reg rx_valid,
    output reg [9:0] rx_data
);

    // State parameters
    parameter IDLE = 3'b000;
    parameter CHK_CMD = 3'b001;
    parameter WRITE = 3'b010;
    parameter READ_ADD = 3'b011;
    parameter READ_DATA = 3'b100;

    // Internal signals
    reg address_received; //read flag
    reg [9:0] data_reg;
    reg [3:0] counter; //write counter

    
    reg [2:0] cs, ns;

    // State logic
    always @(*) 
    begin
        case (cs)
            IDLE: ns = (SS_n == 0) ? CHK_CMD : IDLE;
            CHK_CMD: begin
                if (SS_n == 1)
                    ns = IDLE;
                else begin
                    if (MOST == 1) begin
                        if (address_received == 1)
                            ns = READ_DATA;
                        else
                            ns = READ_ADD;
                    end
                    else
                        ns = WRITE;
                end
            end
            WRITE: ns = (SS_n == 1) ? IDLE : WRITE;
            READ_ADD: ns = (SS_n == 1) ? IDLE : READ_ADD;
            READ_DATA: ns = (SS_n == 1) ? IDLE : READ_DATA;
            default: ns = IDLE;
        endcase
    end

// State memory
always @(posedge clk)
begin
    if (~rst_n)
        cs <= IDLE;
    else
        cs <= ns;
end

// output logic
always @(posedge clk)
begin
    if (~rst_n) begin
        MISO <= 0;
        rx_valid <= 0;
        rx_data <= 0;
        data_reg <= 0;
        address_received <= 0;
    end
    else begin
        case (cs)
            IDLE : begin
                rx_valid <= 0;
            end
            CHK_CMD : begin
                counter <= 10;
            end
            WRITE : begin
    if(counter > 0) begin
        data_reg[counter-1] <= MOSI;
        counter <= counter - 1;
    end
    else begin
        rx_valid <= 1;
        rx_data <= data_reg;
    end
end

READ_ADD : begin
    if(counter > 0) begin
        data_reg[counter-1] <= MOSI;
        counter <= counter - 1;
    end
    else begin
        rx_valid <= 1;
        address_received <= 1;
        rx_data <= data_reg;
    end
end

READ_DATA : begin
    if(tx_valid == 1) begin
       
        rx_valid <= 0;
        if(counter == 0) begin
            address_received <= 0;
        end
        else begin
            MISO <= tx_data[counter-1];
            counter <= counter - 1;
        end
    end
    else begin
        if(counter > 0) begin
            data_reg[counter-1] <= MOSI;
            counter <= counter - 1;
        end
        else begin
            rx_valid <= 1;
            rx_data <= data_reg;
            counter <= 10;
        end
    end
end

endcase
    end
end
endmodule