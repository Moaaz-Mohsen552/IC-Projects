module dsp_tb;

    // Input/Output declarations
    reg [17:0] A, B, D, BCIN;
    reg [47:0] C, PCIN;
    reg CLK, CARRYIN, RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, CEA, CEB, CEC, CED, CEM, CEP;
    reg CECARRYIN, CEOPMODE, RSTOPMODE, RSTCARRYIN;
    reg [7:0] OPMODE;

    wire [17:0] BCOUT;
    wire [47:0] PCOUT, P;
    wire [35:0] M;
    wire CARRYOUT, CARRYOUTF;

    // Clock generation
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    // DUT instantiation
    dsp #(
        .A1REG(1),
        .A0REG(0),
        .B0REG(0),
        .B1REG(1),
        .CREG(1),
        .DREG(1),
        .MREG(1),
        .PREG(1),
        .CARRYINREG(1),
        .CARRYOUTREG(1),
        .OPMODEREG(1),
        .CARRYINSEL("OPMODES"),
        .B_INPUT("DIRECT"),
        .RSTTYPE("SYNC")
    ) DUT (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .CLK(CLK),
        .CARRYIN(CARRYIN),
        .OPMODE(OPMODE),
        .RSTA(RSTA),
        .RSTB(RSTB),
        .RSTP(RSTP),
        .RSTM(RSTM),
        .RSTC(RSTC),
        .RSTD(RSTD),
        .RSTCARRYIN(RSTCARRYIN),
        .RSTOPMODE(RSTOPMODE),
        .CEA(CEA),
        .CEB(CEB),
        .CEC(CEC),
        .CED(CED),
        .CEM(CEM),
        .CEP(CEP),
        .CECARRYIN(CECARRYIN),
        .CEOPMODE(CEOPMODE),
        .PCIN(PCIN),
        .P(P),
        .M(M),
        .PCOUT(PCOUT),
        .BCOUT(BCOUT),
        .CARRYOUT(CARRYOUT),
        .CARRYOUTF(CARRYOUTF),
        .BCIN(BCIN)
    );

   
    initial begin
        // Initialize inputs
        A = 0;
        B = 0;
        C = 0;
        D = 0;
        PCIN = 0;
        BCIN = 0;
        CARRYIN = 0;
        OPMODE = 0;

        $display("Verified resets");

        // Assert resets
        RSTA = 1;
        RSTB = 1;
        RSTC = 1;
        RSTD = 1;
        RSTCARRYIN = 1;
        RSTM = 1;
        RSTP = 1;
        RSTOPMODE = 1;

        // Deassert resets and enable clocks
        @(negedge CLK);
        RSTA = 0;
        RSTB = 0;
        RSTC = 0;
        RSTD = 0;
        RSTM = 0;
        RSTP = 0;
        RSTCARRYIN = 0;
        RSTOPMODE = 0;
        CEA = 1;
        CEB = 1;
        CEC = 1;
        CED = 1;
        CEM = 1;
        CEP = 1;
        CECARRYIN = 1;
        CEOPMODE = 1;

        // Test case 1
        OPMODE = 8'b11011101;
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        BCIN = $random;
        PCIN = $random;
        CARRYIN = $random;

        repeat (4) @(negedge CLK);

        if (
            BCOUT == 18'hf &&
            M == 36'h12c &&
            P == 48'h32 &&
            PCOUT == 48'h32 &&
            CARRYOUT == 0 &&
            CARRYOUTF == 0
        ) begin
            $display("Path 1 has passed");
        end else begin
            $display("Test failed for Path 1");
            $stop;
        end

        // Test case 2
        OPMODE = 8'b00010000;
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        BCIN = $random;
        PCIN = $random;
        CARRYIN = $random;

        repeat (3) @(negedge CLK);

        if (
            BCOUT == 18'h23 &&
            M == 36'h2bc &&
            P == 48'h0 &&
            PCOUT == 48'h0 &&
            CARRYOUT == 0 &&
            CARRYOUTF == 0
        ) begin
            $display("Path 2 has passed");
        end else begin
            $display("Test failed for Path 2");
            $stop;
        end

        // Test case 3
        OPMODE = 8'b00001010;
        A = 20;
        B = 10;
        C = 350;
        D = 25;
        BCIN = $random;
        PCIN = $random;
        CARRYIN = $random;

        repeat (3) @(negedge CLK);

        if (
            BCOUT == 18'ha &&
            M == 36'hc8 &&
            P == PCOUT &&
            CARRYOUT == CARRYOUTF
        ) begin
            $display("Path 3 has passed");
        end else begin
            $display("Test failed for Path 3");
            $stop;
        end

        // Test case 4
        OPMODE = 8'b10100111;
        A = 5;
        B = 6;
        C = 350;
        D = 25;
        PCIN = 3000;
        BCIN = $random;
        CARRYIN = $random;

        repeat (3) @(negedge CLK);

        if (
            BCOUT == 18'h6 &&
            M == 36'h1e &&
            P == 48'hfe6fffec0bb1 &&
            CARRYOUT == 1 &&
            CARRYOUTF == 1
        ) begin
            $display("Path 4 has passed");
        end else begin
            $display("Test failed for Path 4");
            $stop;
        end

        $display("All tests completed");
        $finish;
    end

endmodule