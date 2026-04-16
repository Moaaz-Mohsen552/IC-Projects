vlib work
vlog dff.v
 vlog mux.v
 vlog dsp.v
 vlog dsp_tb.v
vsim -voptargs=+acc work.dsp_tb
add wave *
run -all
#quit -sim