/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

// Se definen las entradas y salidas del probador.
module Tester (clk, mr_main_reset, TXD, TX_EN, TX_ER, tx_code_group);

// Senales de entrada del modulo
output reg clk;
output reg mr_main_reset;
output reg [7:0] TXD;
output reg TX_EN;
output reg TX_ER;

// Senales de salida del modulo
input tx_code_group;

initial begin
    clk = 0;
    TX_EN = 0;
    TXD = 0;
    mr_main_reset = 1;
    #10 mr_main_reset = 0;
    #10 mr_main_reset = 1;
    
    // Se activa el envio de datos
    #50 TX_EN = 1;

    // Datos validos enviados
    #15 TXD = 8'b00000000; 
    #10 TXD = 8'b00011010;
    #10 TXD = 8'b00101111;
    #10 TXD = 8'b01001000; 
    #10 TXD = 8'b01010111;
    #10 TXD = 8'b01110011;
    #10 TXD = 8'b10000011; 
    #10 TXD = 8'b10101011;
    #10 TXD = 8'b11000110; 
    #10 TXD = 8'b00001001; 
    #10 TXD = 8'b11000101; 
    #10 TXD = 8'b10100110; 
    #10 TXD = 8'b10011010;
    #10 TXD = 8'b01010000;
    
    // Se deja de enviar datos
    #10 TX_EN = 0;
    #90 $finish;
end

// Se define el periodo que tendra el reloj.
always begin
  #5 clk = !clk;
end

endmodule