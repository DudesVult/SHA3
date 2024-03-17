transcript on
 
set UVM_DPI_HOME  C:/questasim64_2021.1//uvm-1.1d/win64
set WORK_HOME     C:/SHA3/tb
set RTL     	  C:/SHA3/base
 
if [file exists work] {
    vdel -all
}
vlib work

vlog  -sv -work work $RTL/AXI_SHA/AXI_SHA.sv $RTL/AXI_SHA/SHA_mode.sv $RTL/AXI_SHA/padding.sv
vlog  -sv -work work $RTL/AXIS/AXI_reg.sv $RTL/AXIS/AXI_Stream_Receiver.sv $RTL/AXIS/AXI_Stream_Transmitter.sv
vlog  -sv -work work $RTL/keccak/XOR_IO.sv $RTL/keccak/big_round.sv $RTL/keccak/keccak_xor.sv

vlog  -sv -work work $WORK_HOME/AXI_SHA_tb/AXI_SHA_tb.sv

vsim -voptargs="+acc" -sv_lib $UVM_DPI_HOME/uvm_dpi work.AXI_SHA_tb  +UVM_TESTNAME=base_test 

run -all
