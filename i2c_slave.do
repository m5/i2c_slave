rm -rf work
vlib work

vcom source/sync.vhd
vcom source/matcher_8b.vhd
vcom source/edge_detector.vhd
vcom source/op_register_8b.vhd

vcom source/i2c_decode.vhd
vcom source/i2c_sda_sel.vhd
vcom source/i2c_scl_cntr.vhd
vcom source/i2c_slave_ctrl.vhd
vcom source/rxsr_8bit.vhd
vcom source/tx_fifo.vhd
vcom source/txsr_8bit.vhd

vcom source/i2c_slave.vhd

#vcom source/tb_i2c_decode.vhd
#vsim -i -coverage work.tb_i2c_decode
add wave *
run 60000 ns
