package slave_sequence_item_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam CH        = 3'b010;
  localparam WRITE_ADD = 3'b000;
  localparam WRITE_DATA = 3'b001;
  localparam READ_ADD  = 3'b110;
  localparam READ_DATA = 3'b111;

  class slave_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(slave_sequence_item)

    rand bit rst_n;
    logic MOSI;
    logic SS_n;
    static bit tx_valid;
    logic [9:0] rx_data;
    logic MISO;
    logic rx_valid;
    logic [7:0] tx_data;
    static logic [10:0] MOSI_bits;
    static logic [10:0] old_MOSI_bits;

    static logic unsigned [4:0] ss_count;
    logic [4:0] maxxx;
    static bit address_completed;
    static int counter;

    function new(string name = "slave_sequence_item");
      super.new(name);
    endfunction

    function string convert2string();
      return $sformatf(
        "rst_n=%0b, MOSI=%0b, MISO=%0b, SS_n=%0b, rx_data=0x%0h, tx_valid=%0b, MOSI_bits=%0b",
        rst_n, MOSI, MISO, SS_n, rx_data, tx_valid, MOSI_bits
      );
    endfunction

    function string conver2string_stimulus();
      return $sformatf(
        "rst_n=0b%b, SS_n=0b%b, MOSI=0b%b, tx_valid=0b%b, rx_data=0b%b ",
        rst_n, SS_n, MOSI, tx_valid, rx_data
      );
    endfunction

    constraint reset_constrain { rst_n dist {0 := 2, 1 := 98}; }

function void post_randomize();
  if (ss_count == maxx) begin
    SS_n = 1;
    ss_count = 0;
  end
  else begin
    SS_n = 0;
    ss_count++;
  end

  if (!rst_n) begin
    counter = maxx - 1;
  end
  else if (rst_n && !SS_n && counter != 0) begin
    if (counter == maxx - 1) begin
      MOSI_bits = old_MOSI_bits;
    end
    counter--;
  end
  else begin
  if (maxxx == 23) begin
    MOSI_bits = old_MOSI_bits;
    MOSI = MOSI_bits[counter - 1];
  end
  else begin
    MOSI_bits = old_MOSI_bits;
    MOSI = MOSI_bits[counter - 1];
  end

  counter--;
end

else if (counter == 0) begin
  counter = maxx - 2;
  if (old_MOSI_bits[10:8] == READ_ADD)
    address_completed = 1;
  else if (old_MOSI_bits[10:8] == READ_DATA)
    address_completed = 0;
end

else if (SS_n) begin
  old_MOSI_bits = $random();
  tx_data = $random();
  if (old_MOSI_bits[10] == 0)
    MOSI_bits[10:8] = ($urandom_range(1,0) == 1) ? WRITE_DATA : WRITE_ADD;

  if (old_MOSI_bits[10] == 1 && address_completed)
    MOSI_bits[10:8] = READ_DATA;
  else if (old_MOSI_bits[10] == 1 && !address_completed)
    MOSI_bits[10:8] = READ_ADD;

  maxx = (MOSI_bits[10:8] == READ_DATA) ? 23 : 13;
  counter = maxx - 1;
  MOSI_bits[7:0] = $random();
end
if (maxx == 23 && ss_count > 13) begin
  tx_valid = 1;
end
else tx_valid = 0;

old_MOSI_bits = MOSI_bits;

endfunction

endclass

endpackage