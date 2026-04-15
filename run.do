vlib work
vlog  FIFO_interface.sv FIFO.sv FIFO_transaction_pkg.sv shared_pkg.sv FIFO_coverage_pkg.sv FIFO_scoreboard_pkg.sv FIFO_monitor.sv FIFO_top.sv FIFO_tb.sv +define+SIM +cover -covercells
vsim -voptargs=+acc work.FIFO_top -cover
add wave /FIFO_top/FIFO_if/*
coverage save  FIFO_top.ucdb -onexit
run -all