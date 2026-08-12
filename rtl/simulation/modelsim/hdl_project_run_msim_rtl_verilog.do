transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/TRAN\ QUANG\ NHAT/Documents/HDL/HDL_Project {D:/TRAN QUANG NHAT/Documents/HDL/HDL_Project/vga_sync.v}

vlog -vlog01compat -work work +incdir+D:/TRAN\ QUANG\ NHAT/Documents/HDL/HDL_Project {D:/TRAN QUANG NHAT/Documents/HDL/HDL_Project/tb_vga_sync.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  tb_vga_sync

add wave *
view structure
view signals
run -all
