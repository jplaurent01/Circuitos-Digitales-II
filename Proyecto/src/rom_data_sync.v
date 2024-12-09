/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

module Rom_data_sync (code_group, existence);

    // Senales de entrada y salida del modulo
    input [9:0] code_group;
    output reg existence;

    // Variable y registro interno
    integer i;
    reg [9:0] register[51:0];

    // Se inicializa la ROM
    initial begin 

        register[0] = 10'b1001110100;
        register[1] = 10'b0101101011;
        register[2] = 10'b0101111001;
        register[3] = 10'b1110010101;
        register[4] = 10'b1110100101;
        register[5] = 10'b1100101100;
        register[6] = 10'b1100011101;
        register[7] = 10'b1101001010;
        register[8] = 10'b0110010110;
        register[9] = 10'b1001011011;
        register[10] = 10'b1010010110;
        register[11] = 10'b0110011010;
        register[12] = 10'b0101101101;
        register[13] = 10'b0110110101;
        register[14] = 10'b0011110100;
        register[15] = 10'b0011111001;
        register[16] = 10'b0011110101;
        register[17] = 10'b0011110011;
        register[18] = 10'b0011110010;
        register[19] = 10'b0011111010;
        register[20] = 10'b0011110110;
        register[21] = 10'b0011111000;
        register[22] = 10'b1110101000;
        register[23] = 10'b1101101000;
        register[24] = 10'b1011101000;
        register[25] = 10'b0111101000;
        register[26] = 10'b0110001011;
        register[27] = 10'b0101100100;
        register[28] = 10'b1010001001;
        register[29] = 10'b0001100101;
        register[30] = 10'b0001010101;
        register[31] = 10'b1100100011;
        register[32] = 10'b1100010010;
        register[33] = 10'b1101001010;
        register[34] = 10'b0110010110;
        register[35] = 10'b1001010100;
        register[36] = 10'b1010010110;
        register[37] = 10'b0110011010;
        register[38] = 10'b0101100010;
        register[39] = 10'b1001000101;
        register[40] = 10'b1100001011;
        register[41] = 10'b1100000110;
        register[42] = 10'b1100001010;
        register[43] = 10'b1100001100;
        register[44] = 10'b1100001101;
        register[45] = 10'b1100000101;
        register[46] = 10'b1100001001;
        register[47] = 10'b1100000111;
        register[48] = 10'b0001010111;
        register[49] = 10'b0010010111;
        register[50] = 10'b0100010111;
        register[51] = 10'b1000010111;

    end

/*
  Se crea un bucle que esta constantemente
  revisando los code_groups que llegan desde
  el transmisor al sincronizador para revisar
  si estos son datos validos
*/
always @(*) begin
    existence = 0;
    for (i = 0; i < 52; i = i + 1) begin
        if (register[i] == code_group) begin
            existence = 1;
        end
    end
end
endmodule