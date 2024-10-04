all: yosys cajeroAutomatico cajeroAutomaticoSintetizado 

yosys: cajeroAutomatico.ys
			yosys -s cajeroAutomatico.ys

cajeroAutomatico: testebench.v
			iverilog testebench.v -o file1.out
			vvp file1.out
			gtkwave gtkw_cajero.gtkw &

cajeroAutomaticoSintetizado: testebenchSintetis.v
			iverilog testebenchSintetis.v -o sintetizado.out
			vvp sintetizado.out
			gtkwave gtkw_cajero_sintetico.gtkw &

mostrar_ondas:
		gtkwave gtkw_cajero.gtkw gtkw_cajero_Sintetizado.gtkw &

clean:		
			rm .*.out