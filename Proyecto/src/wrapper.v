/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

`include "transmit.v"
`include "synchronization.v"
`include "rom_data_sync.v"
`include "receive.v"

module Wrapper (clk, mr_main_reset, TXD, TX_EN, TX_ER);

// Senales de entrada del modulo
input clk;
input mr_main_reset;
input [7:0] TXD;
input TX_EN;
input TX_ER;

// Conexiones de los diferentes modulos
wire [9:0] code_group;
wire [9:0] code_group_sync;
wire existence;
wire sync_status;
wire [9:0] SUDI;
wire rx_even;

// Instancia del transmisor
Transmit U0 (
    .tx_code_group(code_group),
    .gtx_clk(clk),
    .mr_main_reset(mr_main_reset),
    .TXD(TXD),
    .TX_EN(TX_EN)
);

// Instancia del sincronizador
Synchronizer U1 (
    .rx_code_group(code_group),
    .sync_clk(clk),
    .mr_main_reset(mr_main_reset),
    .code_group(code_group_sync),
    .existence(existence),
    .code_sync_status(sync_status),
    .SUDI(SUDI),
    .rx_even(rx_even)
);

// Instancia de la ROM del sincronizador
Rom_data_sync U2 (
    .code_group(code_group_sync),
    .existence(existence)
);

// Instancia del receptor
receptor U3 (
    .clk_receptor(clk),
    .mr_main_reset(mr_main_reset),
    .sync_status(sync_status),
    .SUDI_receive(SUDI),
    .rx_even_receive(rx_even)
);


endmodule