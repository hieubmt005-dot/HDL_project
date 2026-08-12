onerror {quit -f}
vlib work
vlog -work work hdl_project.vo
vlog -work work hdl_project.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.clk_divider_vlg_vec_tst
vcd file -direction hdl_project.msim.vcd
vcd add -internal clk_divider_vlg_vec_tst/*
vcd add -internal clk_divider_vlg_vec_tst/i1/*
add wave /*
run -all
