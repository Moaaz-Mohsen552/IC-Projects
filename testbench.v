module SPI_tb ();
    reg MOSI, SS_n, clk, rst_n;
    wire MISO;
    reg [9:0] MOSI_tb;

    SPI_Wrapper DUT(MOSI, SS_n, clk, rst_n, MISO);

    initial begin
        clk = 0;
        forever #1 clk = ~clk;
    end

    integer i;

    initial begin
        $readmemh ("mem.dat", DUT.m2.mem);
        rst_n = 0 ;
        MOSI = 0 ;
        SS_n = 1 ;
        MOSI_tb = 0 ;
        //Check Reset function
        @(negedge clk);
        if(MISO!=0)begin
            $display("Error");
            $stop;
        end
        //Check Write address function
        rst_n = 1 ;
        SS_n = 0 ;
        @(negedge clk);
        MOSI = 0 ;
        @(negedge clk);
        MOSI_tb = 10'b00_00011100 ; 
        for ( i = 0 ; i < 10 ;  i + 1 ) begin
            MOSI = MOSI_tb[9-i] ;
            @(negedge clk);
        end
        @(negedge clk);
        //Check Write Data function
        SS_n = 1 ;
        @(negedge clk);
        SS_n = 0 ;
        @(negedge clk);
        MOSI = 0 ;
        @(negedge clk);
                MOSI_tb = 10'b01_0110_1100 ; 
        for ( i = 0 ; i < 10 ;  i + 1 ) begin
            MOSI = MOSI_tb[9-i] ;
        end
        @(negedge clk);

        @(negedge clk);
        //Check read address in memory
        SS_n = 1 ;
        @(negedge clk);
        SS_n = 0 ;
        MOSI = 1 ;
        @(negedge clk);
        MOSI_tb = 10'b10_00011100 ; 
        for ( i = 0 ; i < 10 ; i = i + 1 ) begin
            MOSI = MOSI_tb[9-i] ;
        end
        @(negedge clk);

        //Check read data from memory
        SS_n = 1 ;
        @(negedge clk);
        SS_n = 0 ;
        MOSI = 1 ;
        @(negedge clk);
        MOSI_tb = 10'b11_01011100 ;
        for ( i = 0 ; i < 10 ;  i + 1 ) begin
            MOSI = MOSI_tb[9-i] ;
        end
        @(negedge clk);

        repeat(11)@(negedge clk);
        $stop;
    end
endmodule