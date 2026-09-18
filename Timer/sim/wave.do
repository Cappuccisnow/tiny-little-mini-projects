onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_timer/PCLK
add wave -noupdate /tb_timer/PRESETn
add wave -noupdate /tb_timer/PSEL
add wave -noupdate /tb_timer/PENABLE
add wave -noupdate /tb_timer/PWRITE
add wave -noupdate /tb_timer/PWDATA
add wave -noupdate /tb_timer/PADDR
add wave -noupdate /tb_timer/PRDATA
add wave -noupdate /tb_timer/PREADY
add wave -noupdate /tb_timer/PSLVERR
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcnt_clk
add wave -noupdate /tb_timer/u_dut/u_tcnt/rst_n
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcr_load
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcr_enable
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcr_up_dw
add wave -noupdate /tb_timer/u_dut/u_tcnt/tdr_data
add wave -noupdate /tb_timer/u_dut/u_tcnt/tick
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcnt_data
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcnt_udf
add wave -noupdate /tb_timer/u_dut/u_tcnt/tcnt_ovf
add wave -noupdate -divider apb_write
add wave -noupdate /tb_timer/cpu/apb_write/addr
add wave -noupdate /tb_timer/cpu/apb_write/wr_data
add wave -noupdate -divider apb_compare
add wave -noupdate /tb_timer/cpu/apb_read_compare/addr
add wave -noupdate /tb_timer/cpu/apb_read_compare/expected
add wave -noupdate /tb_timer/cpu/apb_read_compare/rd_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {125 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {1 us}
