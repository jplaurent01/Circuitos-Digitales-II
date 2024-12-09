PCS: testbench.v
		iverilog testbench.v
		vvp a.out
		gtkwave PCS_waves.vcd

sync: testbench_sync.v
		iverilog testbench_sync.v
		vvp a.out
		gtkwave synchronizer_waves.vcd