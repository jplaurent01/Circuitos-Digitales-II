module  receptor_transacciones (
    //Entradas
    input wire clk_receptor, // Senial de reloj
    input wire rst_receptor, // Senial de reinicio, activa en 1
    input wire [6:0] I2C_ADDR_receptor,//Esta entrada proviene de un registro del CPU y contiene la dirección del receptor de transacciones. Cuando el receptor recibe una transacción, debe cerciorarse de que es una transacción para sí mismo, comparando el valor recibido en SDA_IN con el valor almacenado en este registro.
    input wire SCL,//Entrada de reloj para el I2C. El flanco activo de la señal SCL es el flanco creciente. Observe que SCL es una entrada del receptor, que deberá provenir del generador de transacciones o de un probador que emule su comportamiento.
    input wire SDA_OUT,//Entrada serial. Note que la dirección de esta señal es inversa a la del generador de transacciones. Debe tener el comportamiento especificado por el protocolo I2C para las condiciones de START, STOP y transacciones de escritura y lectura.
    input wire SDA_OE, //Habilitación de SDA_OUT. Entrada serial. Note que la dirección de esta señal es inversa a la del generador de transacciones. Se debe poner en 1 para aquellas porciones de la transacción donde el generador tiene control del bus I2C y ponerse en 0 para las porciones de la transacción donde el receptor tiene control del bus, de acuerdo con las especificaciones del protocolo.
    input wire [15:0] RD_DATA_receptor,//Note que la dirección de esta señal es inversa a la del generador de transacciones. Esta entrada debe producir los 16 bits que se envían desde el receptor de transacciones I2C durante una transacción de lectura recibida en SDA_OUT. Los bits de RD_DATA_receptor se deben enviar a través de SDA_IN de acuerdo con el protocolo.
    //Salidas
    output reg SDA_IN,//Salida serial enviada desde el receptor hacia el generador de transacciones. Debe tener el comportamiento especificado por el protocolo I2C para producir la indicación de ACK, así como proporcionar los datos de entrada en transacciones de lectura.
    output reg [15:0] WR_DATA_receptor //Salida paralela. Note que la dirección de esta señal es inversa a la del generador de transacciones. Contiene los 16 bits que se reciben por la interfaz I2C durante una transacción de escritura de acuerdo a este enunciado
    
);

    //Definicion de los estados del cajero automatico
    parameter IDLE = 0; 
    parameter INICIO = 1;         //Estado inicial
    parameter LECTURA = 2;       // Espera de tarjeta
    parameter ESCRITURA = 3;     // Lectura de pin
    parameter PARADA = 4;       // Verificacion del pin
    parameter RECIBIR_ACK = 5; // Recibo ack
    parameter ENVIAR_ACK = 6; // Recibo ack

    //Variales internas
    reg [2:0] state_receptor, next_state_receptor; //registros del estado actual y siguiente estado
    reg [4:0] contador_bits_receptor;
    reg [4:0] contador_adr_receptor;
    reg ultimo_bit_adr;
    reg flag_comunicacion_receptor;
    reg flag_end_addres;
    reg se_envio_direcion;
    reg [6:0] get_I2C_ADDR;
    localparam [6:0] EXPECTED_I2C_ADDR = 7'b0111101;

    //Transición de estados
    always @(posedge clk_receptor) begin
        if (rst_receptor) begin //Caso inicial y de reinicio, se establecen condiciones iniciales
            state_receptor <= IDLE; //Se establce como estado inicial IDLE
            SDA_IN <= 1;
            flag_comunicacion_receptor <=1;
            flag_end_addres <= 0;
            se_envio_direcion <= 0;

        end else begin
            state_receptor <= next_state_receptor; //Caso actual para a ser el siguiente estado
        end
    end
    
    // Máquina de estados
    always @(*) begin
        next_state_receptor = state_receptor; // Siguiente estado es el estado actual
        case (state_receptor)

            IDLE: begin // Caso inicial maquina estados
            se_envio_direcion = 0;
            if (SCL && ~SDA_OUT) begin
                next_state_receptor = INICIO;
            end
            end

            INICIO: begin // Caso inicial maquina estados
                next_state_receptor = ENVIAR_ACK;
            end

            ENVIAR_ACK: begin //Debo hacer ACK para trama datos 16 bits
                if (contador_adr_receptor == 9 &&  se_envio_direcion == 0) begin //Debo compara direcion recibida con el valor del dispositivo
                    //if (get_I2C_ADDR == EXPECTED_I2C_ADDR) begin
                        if (ultimo_bit_adr == 0) begin // Si RNW es 1, es una transacción de lectura
                            contador_bits_receptor = 0;
                            next_state_receptor = LECTURA;
                        end else if(ultimo_bit_adr == 1) begin // Si RNW es 0, es una transacción de escritura
                            contador_bits_receptor = 0;
                            next_state_receptor = ESCRITURA;
                        end
                    //end
                end

                else if (contador_bits_receptor == 16) begin
                    if (ultimo_bit_adr == 0) begin // Si RNW es 1, es una transacción de lectura
                        contador_bits_receptor = 0;
                        next_state_receptor = LECTURA;
                    end else if(ultimo_bit_adr == 1) begin // Si RNW es 0, es una transacción de escritura
                        contador_bits_receptor = 0;
                        next_state_receptor = ESCRITURA;
                    end
                end
            end
    
            LECTURA: begin //Aqui se envian tramas de 16 bits
                 se_envio_direcion = 1;
                if (contador_bits_receptor <= 15) begin
                    flag_comunicacion_receptor = 1; // Mientras haya bits que leer, la comunicación sigue
                    next_state_receptor = RECIBIR_ACK;
                end 
            end

            ESCRITURA: begin
                 se_envio_direcion = 1;
                if (contador_bits_receptor == 16 ) begin // Mientras haya bits que escribir, la comunicación sigue
                    flag_comunicacion_receptor = 1;
                    next_state_receptor = ENVIAR_ACK;
                end 
            end

            PARADA:begin
                
                next_state_receptor = IDLE;

            end
           
            
        endcase
    end

        // Máquina de estados
    always @(posedge clk_receptor) begin
        if (rst_receptor) begin
            state_receptor <= IDLE; //Se establce como estado inicial IDLE
            SDA_IN <= 1;
            flag_comunicacion_receptor <=1;
        end else begin
            case (state_receptor)

                IDLE: begin // Caso inicial maquina estados
                    SDA_IN <= 0;
                end

                INICIO: begin // Caso inicial maquina estados
                   
                end

                ENVIAR_ACK: begin
                    if (contador_adr_receptor == 9 ) begin
                        flag_end_addres <= 1;
                    end
                end
        
                LECTURA: begin //Aqui se envian tramas de 16 bits
                     
                end

                ESCRITURA: begin
                     
                end

                PARADA:begin
                    SDA_IN <= 1;
                end
                
            endcase
        end
    end


    always @(posedge SCL) begin
        if (rst_receptor) begin

            contador_bits_receptor <= 0;
            contador_adr_receptor <= 0;
            get_I2C_ADDR <= 7'b0; // Inicializar la variable
            ultimo_bit_adr <= 0;
            flag_end_addres <= 0;
            se_envio_direcion <= 0;

        end else begin
            case (state_receptor) // Comportamiento de las salidas ante cambios de estados

                IDLE: begin // Caso inicial maquina estados
                    SDA_IN <= 0;
                end

                INICIO: begin // Caso inicial
                    
                end

                ENVIAR_ACK: begin
                    if (flag_end_addres) begin
                        if (contador_bits_receptor == 16) begin
                            SDA_IN <= 0; // Enviar ACK
                        end
                    end
                    else begin
                        if (contador_adr_receptor <= 6 ) begin // Recolecto los 7 bits de la direccion del receptor
                            // Desplaza los bits de SDA_OUT hacia la derecha e inserta el nuevo bit en get_I2C_ADDR
                            get_I2C_ADDR <= {get_I2C_ADDR[6:0], SDA_OUT};
                            SDA_IN <= SDA_OUT;
                        end
                        if (contador_adr_receptor == 7 ) begin
                            ultimo_bit_adr <= SDA_OUT;
                            SDA_IN <= SDA_OUT;
                        end
                        if (contador_adr_receptor == 8 ) begin
                            SDA_IN <=0; //Envio un ACK
                        end
                        contador_adr_receptor <= contador_adr_receptor + 1; // Incrementar el contador de bits
                        end
                end

            
                LECTURA: begin
                    if (contador_bits_receptor <= 15) begin
                        // Desplaza los bits de RD_DATA a la izquierda e inserta el nuevo bit desde SDA_IN
                        SDA_IN <= {RD_DATA_receptor[14:0], SDA_OUT};
                        
                    end
                    contador_bits_receptor <= contador_bits_receptor + 1; // Incrementar el contador de bits
                    
                end

                ESCRITURA: begin
                    // Durante la escritura, envía los bits de WR_DATA por SDA_OUT uno a uno
                    if (contador_bits_receptor <= 15) begin
                        SDA_IN <= SDA_OUT; // Enviar el bit correspondiente de WR_DATA
                        
                    end
                    contador_bits_receptor <= contador_bits_receptor + 1; // Incrementar el contador de bits
                end

                PARADA: begin
                    // Lógica para manejar el estado de PARADA
                    
                end
            endcase
        end
end

endmodule

