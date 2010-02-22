rm -rf work
vlib work
vcom source/i2c_decode.vhd
vcom source/matcher_8b.vhd
vcom source/edge_detector.vhd
vcom source/tb_i2c_decode.vhd
vsim -i -coverage work.tb_i2c_decode
add wave *
run 60000 ns
