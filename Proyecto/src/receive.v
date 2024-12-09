/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

module receptor (

    //Entradas al receptor
    input wire clk_receptor,
    input wire mr_main_reset,
    input wire sync_status,
    input wire [9:0] SUDI_receive, 
    input wire rx_even_receive,

    //Salidas del receptor
    output reg [7:0] RXD,
    output reg RX_DV,
    output reg RX_ER
    );

    //Definicion de los estados del Receptor
    parameter LINK_FAILED      = 10'b0000000001; // 1
    parameter WAIT_FOR_K       = 10'b0000000010; // 2
    parameter RX_K             = 10'b0000000100; // 4
    parameter IDLE_D           = 10'b0000001000; // 8 Se combina estado IDLE_D + CARRIER_DETECT
    parameter START_OF_PACKET  = 10'b0000010000; // 16
    parameter RECEIVE          = 10'b0000100000; // 32
    parameter TRI_RRI          = 10'b0001000000; // 64
     
    //Definicion de las variables del code-group
    //IDLE 2: K_28.5 y D_16.2

    parameter K_28_5 = 8'b10111100;
    parameter K_28_5_POS = 10'b1100000101;
    parameter K_28_5_NEG = 10'b0011111010;
    parameter D_16_2 = 8'b01010000;
    parameter D_16_2_NEG = 10'b0110110101;
    parameter D_16_2_POS = 10'b1001000101;
    
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

    // Datos especiales de 8 bits del estandar

    parameter K_28_0 = 8'b00011100; //K_28.0 
    parameter K_28_1 = 8'b00111100; //K_28.1
    parameter K_28_2 = 8'b01011100; //K_28.2
    parameter K_28_3 = 8'b01111100; //K_28.3
    parameter K_28_4 = 8'b10011100; //K_28.4
    parameter K_28_6 = 8'b11011100; //K_28.6
    parameter K_28_7 = 8'b11111100; //K_28.7
    parameter K_23_7 = 8'b11110111; //K23.7
    parameter K_27_7 = 8'b11111011; //K27.7
    parameter K_29_7 = 8'b11111101; //K29.7
    parameter K_30_7 = 8'b11111110; //K30.7
    
    // Code groups validos con disparidad negativa

    parameter D_0_0_NEG = 10'b1001110100;
    parameter D_26_0_NEG = 10'b0101101011;
    parameter D_15_1_NEG = 10'b0101111001;
    parameter D_8_2_NEG = 10'b1110010101;
    parameter D_23_2_NEG = 10'b1110100101;
    parameter D_19_3_NEG = 10'b1100101100;
    parameter D_3_4_NEG = 10'b1100011101;
    parameter D_11_5_NEG = 10'b1101001010;
    parameter D_6_6_NEG = 10'b0110010110;
    parameter D_9_0_NEG = 10'b1001011011;
    parameter D_5_6_NEG = 10'b1010010110;
    parameter D_6_5_NEG = 10'b0110011010;
    parameter D_26_4_NEG = 10'b0101101101;

    // Code groups especiales con disparidad negativa

    parameter K_28_0_NEG = 10'b0011110100;
    parameter K_28_1_NEG = 10'b0011111001;
    parameter K_28_2_NEG = 10'b0011110101;
    parameter K_28_3_NEG = 10'b0011110011;
    parameter K_28_4_NEG = 10'b0011110010;
    //K_28_5_NEG = 10'b0011111010;
    parameter K_28_6_NEG = 10'b0011110110;
    parameter K_28_7_NEG = 10'b0011111000;
    parameter K_23_7_NEG = 10'b1110101000;
    parameter K_27_7_NEG = 10'b1101101000;
    parameter K_29_7_NEG = 10'b1011101000;
    parameter K_30_7_NEG = 10'b0111101000;

    // Code groups validos con disparidad positiva

    parameter D_0_0_POS = 10'b0110001011;
    parameter D_26_0_POS = 10'b0101100100;
    parameter D_15_1_POS = 10'b1010001001;
    parameter D_8_2_POS = 10'b0001100101;
    parameter D_23_2_POS = 10'b0001010101;
    parameter D_19_3_POS = 10'b1100100011;
    parameter D_3_4_POS = 10'b1100010010;
    parameter D_11_5_POS = 10'b1101001010;
    parameter D_6_6_POS = 10'b0110010110;
    parameter D_9_0_POS = 10'b1001010100;
    parameter D_5_6_POS = 10'b1010010110;
    parameter D_6_5_POS = 10'b0110011010;
    parameter D_26_4_POS = 10'b0101100010;

    // Code groups especiales con disparidad positiva

    parameter K_28_0_POS = 10'b1100001011; 
    parameter K_28_1_POS = 10'b1100000110; 
    parameter K_28_2_POS = 10'b1100001010;
    parameter K_28_3_POS = 10'b1100001100;
    parameter K_28_4_POS = 10'b1100001101;
    parameter K_28_6_POS = 10'b1100001001;
    parameter K_28_7_POS = 10'b1100000111;
    parameter K_23_7_POS = 10'b0001010111; 
    parameter K_27_7_POS = 10'b0010010111;
    parameter K_29_7_POS = 10'b0100010111;
    parameter K_30_7_POS = 10'b1000010111;
    
    // Variables internas del receptor
    parameter FAIL = 1'b0;
    parameter TRUE = 1'b1;
    parameter FALSE = 1'b0;
    reg [9:0] state, next_state; // Registros del estado actual y siguiente estado
    reg [9:0] SUDI, SUDI_d; // Se agrega como variable interna un SUDI y un SUDI delay
    reg rx_even; 
    reg receiving;
    reg rx_lpi_active;
    reg [29:0] end_bits;
    reg [999:0] sudi_storage; // Variable que almacena hasta 1000 bits del sudi, que se utilizan dentro de la funcion check_end
    reg [7:0] next_RXD;
    
    // ###############################
    // # MAQUINA DE ESTOS DE RECEIVE #
    // ###############################
  
    //Flip flops, siempre que tenga un flanco positivo del reloj clk_receptor ocurre algo, logica secuencial

    always @(posedge clk_receptor) begin
        if (mr_main_reset == FALSE) begin // Caso inicial y de reinicio
            sudi_storage <= 1000'b0; // Inicializa en 0 al resetear el almacenador de SUDI
            state <= WAIT_FOR_K; // Estado inicial
            SUDI <= SUDI_receive; // Se retrasa un ciclo de reloj el contenido de SUDI
            RXD <= 0; // Valor inicial de la señal de salida
            rx_even <= rx_even_receive; // Se retrasa un ciclo de reloj la señal rx_even
            SUDI_d <= SUDI; // Se retrasa 2 ciclos de reloj el contenido de SUDI_d
        end else begin
            state <= next_state; // Avanza al siguiente estado
            SUDI <= SUDI_receive; // Se retrasa un ciclo de reloj el contenido de SUDI
            RXD <= next_RXD;
            rx_even <= rx_even_receive; // Se retrasa un ciclo de reloj la señal rx_even
            SUDI_d <= SUDI; // Se retrasa 2 ciclos de reloj el contenido de SUDI_d
        end
    end
 
    //Logica combinacional, siempre que ocurren un cambio en alguna de las entradas

    always @(*) begin
        next_state = state; // Siguiente estado es el estado actual
        next_RXD = RXD; // Siguiente RXD

        case (state)

            /*
            Estado 1: Maquina de estado inicia en estado donde
            se pierde sincornizacion (estado opcional)
            */
            LINK_FAILED: begin
                rx_lpi_active = FALSE;
                if (receiving == TRUE) begin
                    receiving = FALSE;
                    RX_ER = TRUE;
                end else begin
                    RX_DV = FALSE;
                    RX_ER = FALSE;
                end

                if (sync_status != FAIL) begin
                    next_state = WAIT_FOR_K;
                end
            end

            /*
            Estado 2: La maquina pregunta si el contenido de 
            SUDI y SUDI_d es un carcater de /K28.5/ de secuencia
            positiva o negativa.
            */
            WAIT_FOR_K: begin
                end_bits = 0;
                RX_DV = FALSE; RX_ER = FALSE; receiving = FALSE;
                if (rx_even == FALSE) begin 
                    if (SUDI == K_28_5_POS || SUDI == K_28_5_NEG) begin
                        next_state = RX_K;
                    end else if (SUDI_d == K_28_5_POS || SUDI_d == K_28_5_NEG) begin
                        next_state = RX_K;
                    end
                end
            end

            /*
            Estado 4: La maquina pregunta si el contenido de 
            SUDI y SUDI_d pertence al grupo /D/ Y además que estos sean distintos a
            /D21.5/ y /D2.2/
            */  
            RX_K:begin
                RX_DV = FALSE; RX_ER = FALSE; receiving = FALSE;
                if ((rx_even == TRUE) &&
                (SUDI == D_0_0_NEG || SUDI == D_26_0_NEG || SUDI == D_15_1_NEG || SUDI == D_8_2_NEG ||
                 SUDI == D_23_2_NEG || SUDI == D_19_3_NEG || SUDI == D_3_4_NEG || SUDI == D_11_5_NEG ||
                 SUDI == D_6_6_NEG || SUDI == D_9_0_NEG || SUDI == D_5_6_NEG || SUDI == D_6_5_NEG ||
                 SUDI == D_26_4_NEG || SUDI == D_16_2_NEG || SUDI == D_0_0_POS || SUDI == D_26_0_POS ||
                 SUDI == D_15_1_POS || SUDI == D_8_2_POS || SUDI == D_23_2_POS || SUDI == D_19_3_POS ||
                 SUDI == D_3_4_POS || SUDI == D_11_5_POS || SUDI == D_6_6_POS || SUDI == D_9_0_POS ||
                 SUDI == D_5_6_POS || SUDI == D_6_5_POS || SUDI == D_26_4_POS || SUDI == D_16_2_POS)
                && (SUDI != 10'b1010101010 || SUDI != 10'b1010101010)
                && (SUDI != 10'b1011010101 || SUDI != 10'b0100100101) ) begin
                    next_state = IDLE_D;
                end else if ((rx_even == TRUE) &&
                (SUDI_d == D_0_0_NEG || SUDI_d  == D_26_0_NEG || SUDI_d  == D_15_1_NEG || SUDI_d  == D_8_2_NEG ||
                 SUDI_d == D_23_2_NEG || SUDI_d == D_19_3_NEG || SUDI_d == D_3_4_NEG || SUDI_d == D_11_5_NEG ||
                 SUDI_d == D_6_6_NEG || SUDI_d == D_9_0_NEG || SUDI_d == D_5_6_NEG || SUDI_d == D_6_5_NEG ||
                 SUDI_d == D_26_4_NEG || SUDI_d == D_16_2_NEG || SUDI_d == D_0_0_POS || SUDI_d == D_26_0_POS ||
                 SUDI_d == D_15_1_POS || SUDI_d == D_8_2_POS || SUDI_d == D_23_2_POS || SUDI_d == D_19_3_POS ||
                 SUDI_d == D_3_4_POS || SUDI_d == D_11_5_POS || SUDI_d == D_6_6_POS || SUDI_d == D_9_0_POS ||
                 SUDI_d == D_5_6_POS || SUDI_d == D_6_5_POS || SUDI_d == D_26_4_POS || SUDI_d == D_16_2_POS)
                && (SUDI_d != 10'b1010101010 || SUDI_d != 10'b1010101010)
                && (SUDI_d != 10'b1011010101 || SUDI_d != 10'b0100100101)) begin
                    next_state = IDLE_D;
                end
            end 
            
            /*
            Estado 8:  Se combina estado IDLE_D + CARRIER_DETECT.
            La maquina pregunta si el contenido de de SUDI y SUDI_d es /K28.5/
            para volver al estado RX_K. Caso contrario pregunta por el caracter /s/
            para moverse al estado START_OF_PACKET
            */
            IDLE_D: begin
                RX_DV = FALSE; RX_ER = FALSE; receiving = FALSE; rx_lpi_active = FALSE;
                
                    if (SUDI == K_28_5_POS || SUDI == K_28_5_NEG) begin
                        next_state = RX_K;
                    end else if (SUDI_d == K_28_5_POS || SUDI_d == K_28_5_NEG) begin
                        next_state = RX_K;
                    end else if (SUDI == K_27_7_POS || SUDI == K_27_7_NEG) begin
                        receiving = TRUE;
                        next_state = START_OF_PACKET;
                        next_RXD = 8'b01010101;
                    end
            end
            
            /*
            Estado 16:  Se pasa al estado RECEIVE
            */
            START_OF_PACKET: begin
                receiving = TRUE; RX_DV = TRUE; RX_ER = FALSE; 
                next_RXD = DECODE(SUDI);
                next_state = RECEIVE;
            end

            /*
            Estado 32:  Se evalua si se obtiene la combinacion /T/R/K28.5 dentro de la funcion check_end
            para pasar al estado de TRI_RRI. Caso contrario, evalua si SUDI pertence al conjunto /D/ para 
            decodificar su contenido en 8 bits.
            */
            RECEIVE: begin
                receiving = TRUE;
                // Concatenar el valor actual de SUDI al registro sudi_storage
                sudi_storage = {sudi_storage[989:0], SUDI}; // Desplazar los bits y agregar el nuevo SUDI

                if ((end_bits[29:20] != K_29_7_POS && end_bits[29:20] != K_29_7_NEG) && 
                (end_bits[19:10] != K_23_7_NEG && end_bits[19:10] != K_23_7_POS) && 
                (end_bits[9:0] != K_28_5_POS && end_bits[9:0] != K_28_5_NEG)) begin
                    end_bits = check_end(sudi_storage); // Variable end_bits almacena ultimos 30 bits del registro de 1000 bits
                end

                if (rx_even == FALSE && (end_bits[29:20] == K_29_7_POS || end_bits[29:20] == K_29_7_NEG) && (end_bits[19:10] == K_23_7_NEG || end_bits[19:10] == K_23_7_POS) &&  (end_bits[9:0] == K_28_5_POS || end_bits[9:0] ==  K_28_5_NEG)) begin //Debo ir almacenando los datos en la variable check_end
                    next_state = TRI_RRI;

                end else if (
                SUDI == D_0_0_NEG || SUDI == D_26_0_NEG || SUDI == D_15_1_NEG || SUDI == D_8_2_NEG || SUDI == D_23_2_NEG ||
                SUDI == D_19_3_NEG || SUDI == D_3_4_NEG || SUDI == D_11_5_NEG || SUDI == D_6_6_NEG || SUDI == D_9_0_NEG || SUDI == D_5_6_NEG ||
                SUDI == D_6_5_NEG || SUDI == D_26_4_NEG || SUDI == D_16_2_NEG || SUDI == D_0_0_POS || SUDI == D_26_0_POS || SUDI == D_15_1_POS ||
                SUDI == D_8_2_POS || SUDI == D_23_2_POS || SUDI == D_19_3_POS || SUDI == D_3_4_POS || SUDI == D_11_5_POS || SUDI == D_6_6_POS ||
                SUDI == D_9_0_POS || SUDI == D_5_6_POS || SUDI == D_6_5_POS || SUDI == D_26_4_POS || SUDI == D_16_2_POS ) begin //SUDI E[/D/]
                    RX_ER = FALSE;
                    next_RXD = DECODE(SUDI); // Esta funcion retorna el equivalente del sudi en 8 bits
                    next_state = RECEIVE;  

                end
            end

            /*
            Estado 64:  Para salir de este estado el contenido de SUDI
            debe ser igual a /K28.5/ para poder retornar al estado RX_K.
            */
            TRI_RRI: begin
                receiving = FALSE; RX_DV = FALSE; RX_ER = FALSE;
                sudi_storage = 1000'b0; // Reinicia el registro a 0
                if (rx_even == FALSE) begin 
                    if (SUDI == K_28_5_POS || SUDI == K_28_5_NEG) begin
                        next_state = RX_K;
                    end else if (SUDI_d == K_28_5_POS || SUDI_d == K_28_5_NEG) begin
                        next_state = RX_K;
                    end
                end
            end

        endcase
    end

    // ################################################################################################################
    // # FUNCION DECODE(X) QUE PASA DE 10 A 8 BITS, DEPENDIENDO DEL SUDI DE 10 BITS DEVUELVE SU EQUIVALENTE EL 8 BITS #
    // ################################################################################################################

    function [7:0] DECODE;
        input [9:0] SUDI; // Entrada de 10 bits
        begin
            if ( SUDI == D_0_0_NEG || SUDI == D_0_0_POS) begin
                DECODE =  D_0_0;
            end

            if (SUDI == D_26_0_NEG || SUDI == D_26_0_POS) begin
                DECODE = D_26_0;
            end 
            
            if (SUDI == D_15_1_NEG || SUDI == D_15_1_POS) begin
                DECODE = D_15_1;
            end
            
            if (SUDI == D_8_2_NEG || SUDI == D_8_2_POS) begin
                DECODE = D_8_2;
            end

            if (SUDI == D_23_2_NEG || SUDI == D_23_2_POS) begin
               DECODE = D_23_2;
            end 

            if (SUDI == D_19_3_NEG || SUDI == D_19_3_NEG) begin
                DECODE = D_19_3;
            end 

            if (SUDI == D_3_4_NEG || SUDI == D_3_4_POS) begin
                DECODE = D_3_4;
            end 

            if (SUDI == D_11_5_NEG || SUDI == D_11_5_POS) begin
                DECODE = D_11_5;
            end 
            
            if (SUDI == D_6_6_NEG || SUDI == D_6_6_POS) begin
                DECODE = D_6_6;
            end

            if (SUDI == D_9_0_NEG || SUDI == D_9_0_POS) begin
                DECODE = D_9_0;
            end 

            if (SUDI == D_5_6_NEG || SUDI == D_5_6_POS) begin
                DECODE = D_5_6;
            end 

            if (SUDI == D_6_5_NEG || SUDI == D_6_5_POS) begin
                DECODE = D_6_5;
            end 

            if (SUDI == D_26_4_NEG || SUDI == D_26_4_POS) begin
                DECODE = D_26_4;
            end 

            if (SUDI == D_16_2_NEG || SUDI == D_16_2_POS) begin
                DECODE = D_16_2;
            end

            if (SUDI == K_28_0_NEG || SUDI == K_28_0_POS) begin
                DECODE = K_28_0;
            end

            if (SUDI == K_28_1_NEG || SUDI == K_28_1_POS) begin
                DECODE = K_28_1;
            end  
            
            if (SUDI == K_28_2_NEG || SUDI == K_28_2_POS) begin
                DECODE = K_28_2;
            end

            if (SUDI == K_28_3_NEG || SUDI == K_28_3_POS) begin
                DECODE = K_28_3;
            end

            if (SUDI == K_28_4_NEG || SUDI == K_28_4_POS) begin
                DECODE = K_28_4;
            end

            if (SUDI == K_28_5_NEG || SUDI == K_28_5_POS) begin
                DECODE = K_28_5;
            end 

            if (SUDI == K_28_6_NEG || SUDI == K_28_6_POS) begin
                DECODE = K_28_6;
            end

            if (SUDI == K_28_7_NEG || SUDI == K_28_7_POS) begin
                DECODE = K_28_7;
            end 
         
            if (SUDI == K_23_7_NEG || SUDI == K_23_7_POS ) begin
                DECODE = K_23_7;
            end 

            if (SUDI ==  K_27_7_NEG || SUDI == K_27_7_POS) begin
                DECODE = K_27_7; 
            end 
            
            if (SUDI == K_29_7_NEG || SUDI == K_29_7_POS) begin
                DECODE = K_29_7;
            end
            
            if (SUDI == K_30_7_NEG || SUDI == K_30_7_POS) begin
                DECODE = K_30_7;
            end
              
        end
        
    endfunction

    // #######################################################################################
    // # FUNCION CHECK_END(storage), RETORNA LOS ULTIMOS 30 BITS DEL REGISTRO "sudi_storage" #
    // #######################################################################################

    function [29:0] check_end;
    input [999:0] storage;
    begin
        check_end = storage[29:0]; // Retorna los últimos 30 bits
    end
    endfunction

endmodule