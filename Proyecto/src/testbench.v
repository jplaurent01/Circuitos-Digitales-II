/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

// Se llama a los dos documentos, tanto el DUT como el tester
`include "wrapper.v"
`include "tester.v"

module controller_tb;

// Se definen conexiones dentro del testbench

wire clk;
wire mr_main_reset;
wire [7:0] TXD;
wire TX_EN;
wire TX_ER;

wire tx_code_group;
wire cg_timer_done; // Revisar si puede ser una variable interna)

       // Se definen los comandos para obtener el archivo de Gtkwave.
    initial begin
	    $dumpfile("PCS_waves.vcd");
	    $dumpvars(-1, U0);
    end

    // Instancia del modulo del generador
    Wrapper U0 (
        .clk (clk), 
        .mr_main_reset (mr_main_reset), 
        .TXD (TXD), 
        .TX_EN (TX_EN)
    );

    // Instancia del modulo del receptor
    Tester U1 (
        .clk (clk), 
        .mr_main_reset (mr_main_reset), 
        .TXD (TXD), 
        .TX_EN (TX_EN)
    );

endmodule