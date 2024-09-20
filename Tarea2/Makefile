all: yosys controladorRTLIL controladorSintetizado controladorRetardos

yosys: controlador.ys
			yosys -s controlador.ys

controladorRTLIL: testbench_RTLIL.v
			iverilog testbench_RTLIL.v -o RTLIL.out
			vvp RTLIL.out
			gtkwave resultados_RTLIL.vcd &

controladorSintetizado: testbench.v
			iverilog testbench.v -o sintetizado.out
			vvp sintetizado.out
			gtkwave resultados.vcd &

controladorRetardos: testbench_con_retardos.v
			iverilog testbench_con_retardos.v -o sintetizado_retardos.out
			vvp sintetizado_retardos.out
			gtkwave resultados_retardos.vcd &

mostrar_ondas:
		gtkwave resultados_RTLIL.vcd  resultados.vcd resultados_retardos.vcd &

clean:		
			rm -f *.out
			rm .*.swp