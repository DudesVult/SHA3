transcript on
 
set UVM_DPI_HOME  C:/questasim64_2021.1//uvm-1.1d/win64
set WORK_HOME     C:/SHA3/base
set RTL     	  C:/SHA3/tb
 
if [file exists work] {
    vdel -all
}
vlib work

vlog  -sv -work work $RTL/AXI_SHA/AXI_SHA.sv $RTL/AXI_SHA/SHA_mode.sv
vlog  -sv -work work $RTL/AXIS/AXI_reg.sv $RTL/AXIS/AXI_Stream_Receiver.sv $RTL/AXIS/AXI_Stream_Transmitter.sv
vlog  -sv -work work $RTL/keccak/keccak_xor

vlog  -sv -work work $WORK_HOME/AXI_SHA_tb/AXI_SHA_tb.sv

vsim -voptargs="+acc" -sv_lib $UVM_DPI_HOME/uvm_dpi work.top  +UVM_TESTNAME=base_test 

run -all
