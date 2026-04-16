module data_memory_dualaddr_sync (
    input            clk,
    input            memwrite,
    input            MemRead,
    input  [31:0]    write_addr,
    input  [31:0]    write_data,
    input  [31:0]    read_addr,
    output reg [31:0] read_data
);

    reg [31:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (memwrite)
            mem[write_addr[9:2]] <= write_data;

        if (MemRead)
            read_data <= mem[read_addr[9:2]];
    end

endmodule
