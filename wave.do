onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label Reset -radix binary /testbench/Reset
add wave -noupdate -label received_data -radix hexadecimal /testbench/received_data
add wave -noupdate -divider keyboard
add wave -noupdate -label Reset -radix binary /testbench/K1/Reset
add wave -noupdate -label received_data -radix hexadecimal /testbench/K1/received_data
add wave -noupdate -label EnterEn -radix binary /testbench/K1/EnterEn
add wave -noupdate -label LeftEn -radix binary /testbench/K1/EnterEn
add wave -noupdate -label RightEn -radix binary /testbench/K1/EnterEn
add wave -noupdate -label received_data_en -radix binary /testbench/K1/received_data_en
add wave -noupdate -label key_data -radix hexadecimal /testbench/K1/key_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {600 ns}




vlib work

vlog keyboard.v testbench.v
vsim testbench

add wave *

run 600ns
update