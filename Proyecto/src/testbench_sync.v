/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

`include "synchronization.v"
`include "tester_sync.v"
`include "rom_data_sync.v"

module controller_tb;

// Se definen conexiones dentro del testbench
wire sync_clk;
wire mr_main_reset;
wire [9:0] tx_code_group;
wire [9:0] code_group;
wire existence;

    // Se definen los comandos para obtener el archivo de Gtkwave.
    initial begin
	    $dumpfile("synchronizer_waves.vcd");
	    $dumpvars(-1, U0);
    end

    // Instancia del modulo para el sincronizador
    Synchronizer U0 (
        .rx_code_group(tx_code_group),
        .sync_clk(sync_clk),
        .mr_main_reset(mr_main_reset),
        .code_group(code_group),
        .existence(existence)
    );

    // Instancia del modulo de la rom para el sincronizador
    Rom_data_sync U2 (
        .code_group(code_group),
        .existence(existence)
    );

    // Instancia del modulo del tester
    Tester U1 (
        .sync_clk(sync_clk), 
        .mr_main_reset (mr_main_reset), 
        .tx_code_group (tx_code_group)
    );

endmodule