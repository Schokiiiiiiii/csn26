onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /det_clic_dblclic_top_tb/UUT/nReset_i
add wave -noupdate /det_clic_dblclic_top_tb/UUT/reset_s
add wave -noupdate /det_clic_dblclic_top_tb/UUT/clock_i
add wave -noupdate /det_clic_dblclic_top_tb/UUT/button_i
add wave -noupdate /det_clic_dblclic_top_tb/UUT/top_ms_i
add wave -noupdate /det_clic_dblclic_top_tb/UUT/start_delai_s
add wave -noupdate /det_clic_dblclic_top_tb/UUT/trigger1_s
add wave -noupdate /det_clic_dblclic_top_tb/UUT/trigger2_s
add wave -noupdate /det_clic_dblclic_top_tb/UUT/clic_o
add wave -noupdate /det_clic_dblclic_top_tb/UUT/clic_lg_o
add wave -noupdate /det_clic_dblclic_top_tb/UUT/dbl_clic_o
add wave -noupdate /det_clic_dblclic_top_tb/UUT/dbl_clic_lg_o
add wave -noupdate /det_clic_dblclic_top_tb/tester/clic_check_s
add wave -noupdate /det_clic_dblclic_top_tb/tester/dbl_clic_check_s
add wave -noupdate -divider {Assertions du tester}
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pclick
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pclick1
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pclick2
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pclick4
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pclick5
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pclick6
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__plgclick
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__plgdblclick
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pdblclick
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pdblclick1
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pdblclick2
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pdblclick3
add wave -noupdate /det_clic_dblclic_top_tb/tester/assert__pdblclick5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8152599779 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 320
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {5146935296 ns}
