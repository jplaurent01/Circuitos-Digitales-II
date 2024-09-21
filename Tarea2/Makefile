all: yosys controladorRTLIL controladorSintetizado controladorRetardos

yosys: controlador.ys
			yosys -s controlador.ys

controladorRTLIL: testbench_RTLIL.v
			iverilog testbench_RTLIL.v -o RTLIL.out
			vvp RTLIL.out
			gtkwave ondas_RTLIL.gtkw &

controladorSintetizado: testbench.v
			iverilog testbench.v -o sintetizado.out
			vvp sintetizado.out
			gtkwave ondas.gtkw &

controladorRetardos: testbench_con_retardos.v
			iverilog testbench_con_retardos.v -o sintetizado_retardos.out
			vvp sintetizado_retardos.out
			gtkwave ondas_con_retardos.gtkw &

mostrar_ondas:
		gtkwave ondas_RTLIL.gtkw ondas.gtkw ondas_con_retardos.gtkw &

clean:		
			rm -f *.out
			rm .*.swp