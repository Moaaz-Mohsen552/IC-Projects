vlib work
vlog -f src_files.list +cover -covercells +define+SIM
vsim -voptargs=+acc work.top1 -classdebug -uvmcontrol=all
add wave /top/varf/*
run -all