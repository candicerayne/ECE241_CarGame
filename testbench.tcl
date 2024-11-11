# stop any simulation that is currently running
quit -sim

# create the default 'work' library
vlib work

# compile the verilog source code in the parent folder
vlog keyboard.v

# compile the Verilog code of the testbench
vlog *.v

# start the Simulator, including some libraries
vsim work.testbench -Lf 220model_ver -Lf altera_mf_ver -Lf verilog

# show waveforms specified in wave.do
do wave.do

# advance the simulation the desired amount of time
run 600ns