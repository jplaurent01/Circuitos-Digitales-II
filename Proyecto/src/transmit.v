/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

module Transmit(gtx_clk, mr_main_reset, TXD, TX_EN, TX_ER, tx_code_group);

// Senales de entrada del modulo
input gtx_clk;
input mr_main_reset;
input [7:0] TXD;
input TX_EN;
input TX_ER;

// Senales de salida del modulo
output reg [9:0]tx_code_group;

// Parametros para ingresar a los estados de "Transmit ordered set process"
localparam XMIT_DATA = 7'b0000001;
localparam START_OF_PACKET = 7'b0000010;
localparam TX_PACKET = 7'b0000100;
localparam END_OF_PACKET_NOEXT = 7'b0001000;
localparam EPD2_NOEXT = 7'b0010000;

// Parametros para ingresar a los estados de "Transmit code-group process"
localparam GENERATE_CODE_GROUPS = 7'b0100000;
localparam IDLE_I2B = 7'b1000000;

// Datos validos de 8 bits elegidos para las pruebas
parameter D_0_0 = 8'b00000000; // D0.0
parameter D_26_0 = 8'b00011010; // D26.0
parameter D_15_1 = 8'b00101111; // D15.1
parameter D_8_2 = 8'b01001000; // D8.2
parameter D_23_2 = 8'b01010111; // D28.2
parameter D_19_3 = 8'b01110011; // D19.3
parameter D_3_4 = 8'b10000011; // D3.4
parameter D_11_5 = 8'b10101011; // D11.5
parameter D_6_6 = 8'b11000110; // D6.6
parameter D_9_0 = 8'b00001001; // D9.0
parameter D_5_6 = 8'b11000101; // D5.6
parameter D_6_5 = 8'b10100110; // D6.5
parameter D_26_4 = 8'b10011010; // D26.4
parameter D_16_2 = 8'b01010000; // D16.2

// Datos especiales de 8 bits del estandar
parameter K_28_0 = 8'b00011100; //K28.0 
parameter K_28_1 = 8'b00111100; //K28.1
parameter K_28_2 = 8'b01011100; //K28.2
parameter K_28_3 = 8'b01111100; //K28.3
parameter K_28_4 = 8'b10011100; //K28.4
parameter K_28_5 = 8'b10111100; //K28.5
parameter K_28_6 = 8'b11011100; //K28.6
parameter K_28_7 = 8'b11111100; //K28.7
parameter K_23_7 = 8'b11110111; //K23.7
parameter K_27_7 = 8'b11111011; //K27.7
parameter K_29_7 = 8'b11111101; //K29.7
parameter K_30_7 = 8'b11111110; //K30.7

// Variables internas del controlador para el manejo de condiciones y estados
reg [6:0] state_code, nxt_state_code;
reg [6:0] state_set, nxt_state_set;
reg [7:0] tx_o_set;
reg [2:0] disparity_calculate_result;
reg tx_even, nxt_tx_even;
reg TX_OSET;
reg transmitting;
reg tx_disparity, nxt_tx_disparity;
reg [9:0] rom_pos [255:0]; 
reg [9:0] rom_neg [255:0];

/*
  Se inicializa la simulacion de ROM que almacena los datos que son
  validos para la maquina
*/
initial begin 

// Code groups validos con disparidad negativa
    rom_neg[D_0_0] = 10'b1001110100;
    rom_neg[D_26_0] = 10'b0101101011;
    rom_neg[D_15_1] = 10'b0101111001;
    rom_neg[D_8_2] = 10'b1110010101;
    rom_neg[D_23_2] = 10'b1110100101;
    rom_neg[D_19_3] = 10'b1100101100;
    rom_neg[D_3_4] = 10'b1100011101;
    rom_neg[D_11_5] = 10'b1101001010;
    rom_neg[D_6_6] = 10'b0110010110;
    rom_neg[D_9_0] = 10'b1001011011;
    rom_neg[D_5_6] = 10'b1010010110;
    rom_neg[D_6_5] = 10'b0110011010;
    rom_neg[D_26_4] = 10'b0101101101;
    rom_neg[D_16_2] = 10'b0110110101;
// Code groups especiales con disparidad negativa
    rom_neg[K_28_0] = 10'b0011110100;
    rom_neg[K_28_1] = 10'b0011111001;
    rom_neg[K_28_2] = 10'b0011110101;
    rom_neg[K_28_3] = 10'b0011110011;
    rom_neg[K_28_4] = 10'b0011110010;
    rom_neg[K_28_5] = 10'b0011111010;
    rom_neg[K_28_6] = 10'b0011110110;
    rom_neg[K_28_7] = 10'b0011111000;
    rom_neg[K_23_7] = 10'b1110101000;
    rom_neg[K_27_7] = 10'b1101101000;
    rom_neg[K_29_7] = 10'b1011101000;
    rom_neg[K_30_7] = 10'b0111101000;


// Code groups validos con disparidad positiva
    rom_pos[D_0_0] = 10'b0110001011;
    rom_pos[D_26_0] = 10'b0101100100;
    rom_pos[D_15_1] = 10'b1010001001;
    rom_pos[D_8_2] = 10'b0001100101;
    rom_pos[D_23_2] = 10'b0001010101;
    rom_pos[D_19_3] = 10'b1100100011;
    rom_pos[D_3_4] = 10'b1100010010;
    rom_pos[D_11_5] = 10'b1101001010;
    rom_pos[D_6_6] = 10'b0110010110;
    rom_pos[D_9_0] = 10'b1001010100;
    rom_pos[D_5_6] = 10'b1010010110;
    rom_pos[D_6_5] = 10'b0110011010;
    rom_pos[D_26_4] = 10'b0101100010;
    rom_pos[D_16_2] = 10'b1001000101;
// Code groups especiales con disparidad negativa
    rom_pos[K_28_0] = 10'b1100001011; 
    rom_pos[K_28_1] = 10'b1100000110; 
    rom_pos[K_28_2] = 10'b1100001010;
    rom_pos[K_28_3] = 10'b1100001100;
    rom_pos[K_28_4] = 10'b1100001101;
    rom_pos[K_28_5] = 10'b1100000101;
    rom_pos[K_28_6] = 10'b1100001001;
    rom_pos[K_28_7] = 10'b1100000111;
    rom_pos[K_23_7] = 10'b0001010111; 
    rom_pos[K_27_7] = 10'b0010010111;
    rom_pos[K_29_7] = 10'b0100010111;
    rom_pos[K_30_7] = 10'b1000010111;
end

// ####################################################
// # MAQUINA DE ESTOS DE TRANSMIT ORDERED SET PROCESS #
// ####################################################

//Se Definen todos los flip flops de la maquina de estados "Transmit ordered set process", logica secuencial
always @(posedge gtx_clk) begin
    if (~mr_main_reset) begin 
        state_set <= XMIT_DATA;
    end else begin
        state_set <= nxt_state_set; 
    end
end

// Se define logica combinacional de la maquina de estados para "Transmit ordered set process".
always @(*) begin

    // Se define el valor de senales por defecto de la maquina de estados.
    nxt_state_set = state_set;
    case(state_set) 

        /*
          Estado 1: La maquina esta enviando
          constantemente IDLEs. Se pasa al
          siguiente estado si la senal TX_EN
          se habilita, y la segunda maquina de
          estado habilidad el TX_OSET.
        */
        XMIT_DATA: begin
            if (TX_EN == 1 && TX_OSET == 1) begin
                nxt_state_set = START_OF_PACKET;
            end else begin
                if (state_code == GENERATE_CODE_GROUPS) begin
                    tx_o_set = K_28_5;  
                end else if (state_code == IDLE_I2B) begin
                    tx_o_set = D_16_2;
                end
            end
        end

        /*
          Estado 2: La maquina comienza un paquete
          por lo tanto envia el dato especial /S/.
        */
        START_OF_PACKET: begin
            transmitting = 1;
            tx_o_set = K_27_7;
            if (TX_OSET == 1) begin
                nxt_state_set = (TX_PACKET);
            end else begin
                nxt_state_set = (START_OF_PACKET);
            end
        end

        /*
          Estado:4 Se envian datos mientras la senal
          TX_EN este activa, en cada envio de datos
          se debe recibir la senal TX_OSET para con-
          tinuar. 
        */
        TX_PACKET: begin
            transmitting = 1;
            if (TX_EN == 1) begin
                tx_o_set = TXD;
                if (TX_OSET == 1) begin
                    nxt_state_set = TX_PACKET;
                end 
            end else begin
                nxt_state_set = END_OF_PACKET_NOEXT;
            end
        end

        /*
          Estado 8: Se envia el dato especial /T/
          cuando se recibe la activacion de TX_OSET
          el sistema pasa al siguiente estado.
        */
        END_OF_PACKET_NOEXT: begin
            if (tx_even == 0) begin
                transmitting = 0;
            end 
            tx_o_set = K_29_7;
            if (TX_OSET == 1) begin
                nxt_state_set = EPD2_NOEXT;
            end else begin
                nxt_state_set = END_OF_PACKET_NOEXT;
            end
        end

        /*
          Estado 16: Se envia el dato especial /R/
          y cuando se recibe la activacion de la
          senal TX_OSET el sistema se envia al 
          primer estado.
        */
        EPD2_NOEXT: begin
            tx_o_set = K_23_7; 
            transmitting = 0;
            if(TX_OSET == 1) begin
                nxt_state_set = XMIT_DATA;
            end else begin
                nxt_state_set = EPD2_NOEXT;
            end
        end

    endcase
end

// ###################################################
// # FUNCION QUE REALIZA EL CALCULO DE LA DISPARIDAD #
// ###################################################

function [2:0] disparity_calculate;
    
    input [9:0] tx_code_group; // Code group que recibe la funcion.
    integer i; // Dato entero para el for utilizado.
    reg [2:0] disparity_calculate_temp_6_bits, disparity_calculate_temp_4_bits; //Registro que devuelven un resultado.
    reg signed [4:0] count; // Contador, es una variable con signo.
    
    /*
      Se calcula primeramente la disparidad en los primeros 6 bits
      se revisa si se reciben alguno de los dos conjuntos de datos
      que obligatoriamente colocan la disparidad positiva o negativa.
      De lo contrario por medio de un for de cuentan los 0s y 1s
      encontrados.
      La salida que es disparity_temp_6 bits significa lo siguiente:
      001: Disparidad positiva.
      010: Disparidad negativa.
      100: Se mantiene la disparidad anterior.
    */
    begin
        count = 0;
        if (tx_code_group[9:4] == 6'b000111) begin
            disparity_calculate_temp_6_bits = 3'b001;
        end else if (tx_code_group[9:4] == 6'b111000) begin
            disparity_calculate_temp_6_bits = 3'b010;
        end else begin
            for (i = 9; i >= 4; i = i-1) begin
                if (tx_code_group[i] == 1) begin
                    count = count + 1;
                end else begin
                    count = count - 1;
                end
            end
            if (count > 0) begin
                disparity_calculate_temp_6_bits = 3'b001;
            end else if (count < 0) begin
                disparity_calculate_temp_6_bits = 3'b010;
            end else if (count == 0) begin
                disparity_calculate_temp_6_bits = 3'b100;
            end
        end

        /*
          Se calcula la disparidad en los siguientes 4 bits
          se revisa si se reciben alguno de los dos conjuntos de datos
          que obligatoriamente colocan la disparidad positiva o negativa.
          De lo contrario por medio de un for de cuentan los 0s y 1s
          encontrados.
          La salida que es disparity_temp_4 bits significa lo siguiente:
          001: Disparidad positiva.
          010: Disparidad negativa.
          100: Se mantiene la disparidad anterior (Disparidad en los 6 bits).
        */
        count = 0;
        if (tx_code_group[9:4] == 6'b0011) begin
            disparity_calculate_temp_4_bits = 3'b001;
        end else if (tx_code_group[9:4] == 6'b1100) begin
            disparity_calculate_temp_4_bits = 3'b010;
        end else begin
            for (i = 3; i >= 0; i = i-1) begin
                if (tx_code_group[i] == 1) begin
                    count = count + 1;
                end else begin
                    count = count - 1;
                end
            end
            if (count > 0) begin
                disparity_calculate_temp_4_bits = 3'b001;
            end else if (count < 0) begin
                disparity_calculate_temp_4_bits = 3'b010;
            end else if (count == 0) begin
                disparity_calculate_temp_4_bits = disparity_calculate_temp_6_bits;
            end
        end
        // Se devuelve la disparidad de los ultimos 4 bits, ya que contempla todo.
        disparity_calculate = disparity_calculate_temp_4_bits;
    end
endfunction

// ###################################################
// # MAQUINA DE ESTOS DE TRANSMIT CODE-GROUP PROCESS #
// ###################################################

//Se Definen todos los flip flops de la maquina de estados "Transmit code-group process", logica secuencial
always @(posedge gtx_clk) begin
    if (~mr_main_reset) begin 
        state_code <= GENERATE_CODE_GROUPS;
        tx_disparity <= 0;
        tx_even <= 0;
        TX_OSET = 0;
    end else begin
        state_code <= nxt_state_code; 
        tx_disparity <= nxt_tx_disparity;
        tx_even <= nxt_tx_even;
    end
end

// Se define logica combinacional de la maquina de estados para "Transmit code-group process".
always @(*) begin

    // Se define el valor de senales por defecto de la maquina de estados.
    nxt_state_code = state_code;
    nxt_tx_disparity = tx_disparity;
    nxt_tx_even = tx_even;

    case(state_code) 

        /*
          Estado 32: Este estado se encarga de codificar
          los datos de 8 bits a 10 bits, ya sean datos
          especiales o no, esto por medio de condiciones
          con respecto a los estados de la primer maquina.
          El unico dato que no codifica es el D16.2, ya que
          esto lo hace el estado 64.
          Este estado define las salidas de tx_even y TX_OSET.
        */
        GENERATE_CODE_GROUPS: begin
            if ((state_set == START_OF_PACKET && tx_o_set == K_27_7) || (state_set == END_OF_PACKET_NOEXT && tx_o_set == K_29_7) || (state_set == EPD2_NOEXT && tx_o_set == K_23_7)) begin
                if (tx_disparity == 0) begin
                    tx_code_group = rom_neg[tx_o_set];
                end else begin 
                    tx_code_group = rom_pos[tx_o_set];
                end
                nxt_tx_even = ~tx_even;
                nxt_state_code = GENERATE_CODE_GROUPS;
                TX_OSET = 1;
                
            end else if (state_set == XMIT_DATA && tx_o_set == K_28_5) begin
                tx_even = 1;
                if (tx_disparity == 0) begin
                    tx_code_group = rom_neg[K_28_5];
                end else begin
                    tx_code_group = rom_pos[K_28_5];
                end
                nxt_tx_even = 0;
                nxt_state_code = IDLE_I2B;

            end else if (state_set == TX_PACKET) begin
                if (tx_disparity == 0) begin
                    tx_code_group = rom_neg[tx_o_set];
                end else begin 
                    tx_code_group = rom_pos[tx_o_set];
                end
                nxt_tx_even = ~tx_even;
                nxt_state_code = GENERATE_CODE_GROUPS;
                TX_OSET = 1;
            end

            /*
              Se llama a la funcion que calcula la disparidad del siguiente dato.
            */
            disparity_calculate_result = disparity_calculate(tx_code_group);

            /*
              Dependiendo del resultado obtenido con la funcion
              asi sera la disparidad del siguiente dato.
            */
            if (disparity_calculate_result == 3'b001) begin
                nxt_tx_disparity = 1;
            end else if (disparity_calculate_result == 3'b010) begin
                nxt_tx_disparity = 0;
            end else if (disparity_calculate_result == 3'b100) begin
                nxt_tx_disparity = tx_disparity;
            end
        end

        /*
          Estado 64: Este estado codifica el dato D16.2 que termina
          el IDLE, cual realiza este proceso vuelve al estado 32.
          Este estado define las salidas de tx_even y TX_OSET.
        */
        IDLE_I2B: begin
            if (tx_disparity == 0) begin
                tx_code_group = rom_neg[D_16_2];
            end else begin
                tx_code_group = rom_pos[D_16_2];
            end
            nxt_tx_even = 1;
            nxt_state_code = GENERATE_CODE_GROUPS;
            TX_OSET = 1;

            /*
              Se llama a la funcion que calcula la disparidad del siguiente dato.
            */
            disparity_calculate_result = disparity_calculate(tx_code_group);

            /*
              Dependiendo del resultado obtenido con la funcion
              asi sera la disparidad del siguiente dato.
            */
            if (disparity_calculate_result == 3'b001) begin
                nxt_tx_disparity = 1;
            end else if (disparity_calculate_result == 3'b010) begin
                nxt_tx_disparity = 0;
            end else if (disparity_calculate_result == 3'b100) begin
                nxt_tx_disparity = tx_disparity;
            end
        end

    endcase
end

endmodule