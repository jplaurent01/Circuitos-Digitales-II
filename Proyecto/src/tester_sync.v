/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

// Se definen las entradas y salidas del probador.
module Tester (sync_clk, mr_main_reset, tx_code_group);

// Senales de entrada del modulo
output reg sync_clk;
output reg mr_main_reset;
output reg [9:0] tx_code_group;

// Senales de entrada del modulo
input rx_even;

initial begin
    sync_clk = 0;
    mr_main_reset = 1;
    #10 mr_main_reset = 0;
    #10 mr_main_reset = 1;

    /* 
      Se envian datos validos pero el sistema
      no esta sincronizado
    */
    #5 tx_code_group = 10'b1001110100; 
    #10 tx_code_group = 10'b1111111111; 
    #10 tx_code_group = 10'b0101111001; 

    // K28.5
    #10 tx_code_group = 10'b0011111010;

    // Dato valido pero no D16.2
    #10 tx_code_group = 10'b1001110100;

    // K28.5 y D16.2
    #10 tx_code_group = 10'b0011111010;
    #10 tx_code_group = 10'b0110110101;

    // Dato valido
    #10 tx_code_group = 10'b1001110100;
    
    // Dato no valido
    #10 tx_code_group = 10'b1111111111;

    // K28.5 y D16.2
    #10 tx_code_group = 10'b0011111010;
    #10 tx_code_group = 10'b0110110101;
    
    #10 tx_code_group = 10'b0011111010;
    #10 tx_code_group = 10'b0110110101;

    #10 tx_code_group = 10'b0011111010;
    #10 tx_code_group = 10'b0110110101;

    /* 
      Se envian datos validos pero el sistema
      ya esta sincronizado
    */
    #10 tx_code_group = 10'b1001110100;
    #10 tx_code_group = 10'b0101101011;
    #10 tx_code_group = 10'b0101111001;

    // Dato invalido
    #10 tx_code_group = 10'b1111111111;

    // Datos validos
    #10 tx_code_group = 10'b1110010101;
    #10 tx_code_group = 10'b1110100101;
    #10 tx_code_group = 10'b1100101100;
    #10 tx_code_group = 10'b1100011101;
    #10 tx_code_group = 10'b1101001010;
    #10 tx_code_group = 10'b0110010110;
    #10 tx_code_group = 10'b1001011011;
    #10 tx_code_group = 10'b1010010110;
    #10 tx_code_group = 10'b0110011010;
    #10 tx_code_group = 10'b0101101101;
    #10 tx_code_group = 10'b0110110101;       
    #10 $finish;
end

// Se define el periodo que tendra el reloj.
always begin
  #5 sync_clk = !sync_clk;
end

endmodule