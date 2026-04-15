package slave_scoreboard_pkg;
  import slave_sequence_item_pkg::*;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import slave_object_pkg::*;
  import sequencer_slave_pkg::*;
  import slave_agent_pkg::*;

  class slave_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(slave_scoreboard)
    uvm_analysis_export #(slave_sequence_item) sb;
    uvm_tlm_analysis_fifo #(slave_sequence_item) fi;
    slave_sequence_item slave_sequence_item_i;
    virtual slave_if varf;

    int error_count = 0;
    int pass_count = 0;

    function new(string name="slave_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb = new("sb", this);
      fi = new("fi", this);
      if (!uvm_config_db#(virtual slave_if)::get(this, "", "s_if", varf)) begin
        `uvm_fatal("SCOREBOARD", "virtual interface not set for slave_scoreboard")
      end
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sb.connect(fi.analysis_export);
    endfunction

logic [3:0] reading_count;
logic [3:0] input_count;
logic [2:0] cs, ns;
logic [9:0] SR_reg;
logic [9:0] rx_data_ref;
logic [7:0] RS_reg;
bit read_add_completed;
logic ref_MISO;

localparam IDLE     = 3'b000;
localparam WRITE    = 3'b001;
localparam CHK_MD   = 3'b010;
localparam READ_ADD = 3'b110;
localparam READ_DATA = 3'b111;

task golden_model(slave_sequence_item f);
  case (cs)
    IDLE: begin
      if (!f.SS_n) ns = CHK_MD;
      else ns = IDLE;
    end

    CHK_MD: begin
      if (f.SS_n) ns = IDLE;
      else if (f.MOSI == 0) ns = WRITE;
      else if (read_add_completed) ns = READ_DATA;
      else ns = READ_ADD;
    end

    WRITE : ns = (f.SS_n) ? IDLE : WRITE;
    READ_ADD : ns = (f.SS_n) ? IDLE : READ_ADD;
    READ_DATA : ns = (f.SS_n) ? IDLE : READ_DATA;

  endcase
if (!f.rst_n) begin
  rx_data_ref = 0;
end else begin
  case (cs)
    IDLE: begin
      reading_count = 0;
      input_count = 0;
      ref_MISO = 0;
    end
    CHK_MD: begin
  input_count = 0;
  reading_count = 0;
end

WRITE: begin
  if (input_count < 10) begin
    rx_data_ref = {rx_data_ref[8:0], f.MOSI};
    input_count = input_count + 1;
  end
end

READ_ADD: begin
  if (input_count < 10) begin
    rx_data_ref = {rx_data_ref[8:0], f.MOSI};
    input_count = input_count + 1;
  end
  else read_add_completed = 1;
end

READ_DATA: begin
  if (f.tx_valid) begin
    if (reading_count < 8) begin
      ref_MISO = f.tx_data[7 - reading_count];
      reading_count = reading_count + 1;
    end
    else
      read_add_completed = 0;
  end
  else begin
    if (input_count < 10) begin
      rx_data_ref = {rx_data_ref[8:0], f.MOSI};
      input_count = input_count + 1;
    end
    else begin
      reading_count = 0;
    end
  end
end

default: begin
  input_count = 0;
  reading_count = 0;
  rx_data_ref = 0;
  ref_MISO = 0;
end

CHK_MD: begin
  input_count = 0;
  reading_count = 0;
end

WRITE: begin
  if (input_count < 10) begin
    rx_data_ref = {rx_data_ref[8:0], f.MOSI};
    input_count = input_count + 1;
  end
end

READ_ADD: begin
  if (input_count < 10) begin
    rx_data_ref = {rx_data_ref[8:0], f.MOSI};
    input_count = input_count + 1;
  end
  else read_add_completed = 1;
end
READ_DATA: begin
  if (f.tx_valid) begin
    if (reading_count < 8) begin
      ref_MISO = f.tx_data[7 - reading_count];
      reading_count = reading_count + 1;
    end
    else
      read_add_completed = 0;
  end
  else begin
    if (input_count < 10) begin
      rx_data_ref = {rx_data_ref[8:0], f.MOSI};
      input_count = input_count + 1;
    end
    else begin
      reading_count = 0;
    end
  end
end

default: begin
  input_count = 0;
  reading_count = 0;
  rx_data_ref = 0;
  ref_MISO = 0;
end
endcase
end

if (!f.rst_n) begin
  rx_data_ref = 0;
  RS_reg = 0;
  input_count = 0;
  reading_count = 0;
  rx_data_ref = 0;
  ref_MISO = 0;
  read_add_completed = 0;
  cs = IDLE;
end else 
  cs = ns;
if (f.tx_valid) begin
  if (f.MISO != ref_MISO) begin
    `uvm_error("run_phase", $sformatf("comparison error, dut :%b while the reference is out : %b, %s",
      f.MISO, ref_MISO, f.convert2string_stimulus()));
    error_count++;
  end
  else begin
    `uvm_info("run_phase", $sformatf("correct output : %s, rx_data_ref=%b", f.convert2string_stimulus(), rx_data_ref), UVM_HIGH);
    pass_count++;
  end
end

if (f.rx_valid) begin
  if (f.rx_data != rx_data_ref) begin
    `uvm_error("run_phase", $sformatf("comparison error, dut :%s while the reference is out : %b, cs=%h, ns=%h, PPPP=%b, %s",
      f.convert2string_stimulus(), rx_data_ref, cs, ns, read_add_completed));
    error_count++;
  end
  else begin
    `uvm_info("run_phase", $sformatf("correct output : %s, rx_data_ref=%b", f.convert2string_stimulus(), rx_data_ref), UVM_HIGH);
    pass_count++;
  end
end
endtask
task run_phase(uvm_phase phase);
    super.run_phase(phase);
    cs=IDLE;
    ns=IDLE;
    forever begin
        f1.get(slave_sequence_item_i);
        golden_model(slave_sequence_item_i);
    end
endtask

function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("report_phase", $sformatf("total correct counter=%0d", pass_count), UVM_NONE);
    `uvm_info("report_phase", $sformatf("total error counter=%0d", error_count), UVM_NONE);
endfunction

endclass
endpackage
