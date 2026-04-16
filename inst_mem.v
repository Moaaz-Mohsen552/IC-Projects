module instruction_memory(
    input  [31:0] address,
    output [31:0] instruction
);
    reg [31:0] mem[0:255];
    integer i;  // module-level declaration

    initial begin
        // Arithmetic / Logic
        mem[0]  = {6'b001000, 5'd0, 5'd1, 16'd10};   // addi r1, r0, 10
        mem[1]  = {6'b001000, 5'd0, 5'd2, 16'd20};   // addi r2, r0, 20
        mem[2]  = {6'b000000, 5'd1, 5'd2, 5'd3, 5'd0, 6'b100000}; // add
        mem[3]  = {6'b000000, 5'd2, 5'd1, 5'd4, 5'd0, 6'b100010}; // sub
        mem[4]  = {6'b000000, 5'd1, 5'd2, 5'd5, 5'd0, 6'b100100}; // and
        mem[5]  = {6'b000000, 5'd1, 5'd2, 5'd6, 5'd0, 6'b100101}; // or
        mem[6]  = {6'b001100, 5'd2, 5'd7, 16'd15};   // andi
        mem[7]  = {6'b000000, 5'd1, 5'd2, 5'd8, 5'd0, 6'b101010}; // slt

        // Memory
        mem[8]  = {6'b101011, 5'd0, 5'd3, 16'd0};    // sw r3,0(r0)
        mem[9]  = {6'b100011, 5'd0, 5'd9, 16'd0};    // lw r9,0(r0)

        // Branch & jump
        mem[10] = {6'b000100, 5'd9, 5'd3, 16'd1};    // beq r9,r3,+1
        mem[11] = {6'b001000, 5'd1, 5'd1, 16'd1};    // skipped
        mem[12] = {6'b000010, 26'd14};               // j L2
        mem[13] = {6'b001000, 5'd2, 5'd2, 16'd1};    // skipped

        // SWI
        mem[14] = {6'b100010, 5'd1, 5'd3, 16'd4};    // swi r3,4(r1)

        // JMN
        mem[15] = {6'b001000, 5'd0, 5'd4, 16'd40};   // addi r4,40
        mem[16] = {6'b101011, 5'd0, 5'd4, 16'd16};   // sw r4,16(r0)
        mem[17] = {6'b100001, 5'd0, 5'd0, 16'd16};   // jmn 16(r0)

        // PMC
        mem[18] = {6'b100000, 5'd1, 5'd0, 16'd8};    // pmc r1,8(r0)

        // NOP
        mem[19] = 32'd0;

        // Clear rest of memory
        for (i = 20; i < 256; i = i + 1)
            mem[i] = 32'd0;
    end

    assign instruction = mem[address[9:2]];

endmodule