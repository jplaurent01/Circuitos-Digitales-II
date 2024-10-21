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
    parameter IDLE = 0;            // Estado antes de inicio
    parameter INICIO = 1;         //Estado inicial
    parameter ESCRITURA = 2;     // Lectura de pin
    parameter LECTURA = 3;       // Espera de tarjeta
    parameter PARADA = 4;       // Verificacion del pin
    parameter RECIBIR_ACK = 5; // Recibo ack
    parameter ENVIAR_ACK = 6; // Recibo ack

    //Variales internas
    reg [2:0] state_receptor, next_state_receptor; // registros del estado actual y siguiente estado
    reg [4:0] contador_bits_receptor; // Contador de bits del receptor
    reg [4:0] contador_adr_receptor; // Contador de bits del adress
    reg [4:0] contador_WR_DATA_receptor; // Contador de bits de para llenar señal contador_WR_DATA
    reg [4:0] contador_RD_DATA_receptor; // Contador de bits de para enviar señal contador_RD_DATA
    reg ultimo_bit_adr; // Contiene el octavo bit indica si es lectura o escritura
    reg flag_comunicacion_receptor; // Evalua si hay comunicacion en el receptor
    reg flag_end_addres; // Bandera de que se termino de enviar direccion
    reg se_envio_direcion; // Determina si se envio direccion
    reg [6:0] get_I2C_ADDR; // Almacena el valor del I2C_ADDR enviada del generador
    localparam [6:0] EXPECTED_I2C_ADDR = 7'b0111101; // Valor de la direccion del generador 61

    //Transición de estados
    always @(posedge clk_receptor) begin
        if (~rst_receptor) begin //Caso inicial y de reinicio, se establecen condiciones iniciales
            state_receptor <= IDLE; //Se establce como estado inicial IDLE
            SDA_IN <= 1; // SDA_IN inidiacilzada en alto 
            flag_comunicacion_receptor <=1; // Comunicacion con generador en alto
            flag_end_addres <= 0; // Bandera de que se termino de enviar la direcion
            se_envio_direcion <= 0; // Se determina si se envio direcion
            contador_WR_DATA_receptor <= 0;
            contador_RD_DATA_receptor <= 0;
        end else begin
            state_receptor <= next_state_receptor; //Caso actual para a ser el siguiente estado
             case (state_receptor)

                IDLE: begin // Caso inicial maquina estados
                    SDA_IN <= SDA_OUT;
                    flag_end_addres <= 0; 
                end

                ENVIAR_ACK: begin 
                    if (contador_adr_receptor == 9 ) begin
                        flag_end_addres <= 1; //Se termino de enviar direccion si contador_adr_receptor == 9 
                    end
                end

                PARADA:begin
                    SDA_IN <= 1; // Se  actualiza SDA_IN en alto luego de que SCL este en alto.
                    contador_bits_receptor <= 0;
                    contador_adr_receptor <= 0;
                    contador_WR_DATA_receptor <= 0;
                end
                
            endcase
        end
    end
    
    // Máquina de estados
    always @(*) begin
        next_state_receptor = state_receptor; // Siguiente estado es el estado actual
        case (state_receptor)

            IDLE: begin // Caso inicial maquina estados
                se_envio_direcion = 0;
                if (SCL && ~SDA_OUT) begin // Caso de SCL en alto y sda_out bajo
                    get_I2C_ADDR = 7'b0;
                    next_state_receptor = INICIO;
                end
            end

            INICIO: begin // Caso inicial maquina estados
                next_state_receptor = ENVIAR_ACK;
            end

            ENVIAR_ACK: begin //Debo hacer ACK para trama datos 16 bits
                if (contador_adr_receptor == 9 &&  se_envio_direcion == 0) begin //Debo compara direcion recibida con el valor del dispositivo
                    if (get_I2C_ADDR == EXPECTED_I2C_ADDR) begin //TENGO PROBLEMA VERIFICAR LA DIRECION OBTENIDA
                        if (ultimo_bit_adr == 0) begin // Si RNW es 1, es una transacción de lectura
                            contador_bits_receptor = 0; // Re inicio contadro bits del receptor
                            next_state_receptor = ESCRITURA;
                        end else if(ultimo_bit_adr == 1) begin // Si RNW es 0, es una transacción de escritura
                            contador_bits_receptor = 0; // Re inicio contadro bits del receptor
                            next_state_receptor = LECTURA;
                        end
                    end
                end

                else if (contador_bits_receptor == 9) begin
                    if (ultimo_bit_adr == 0) begin // Si RNW es 1, es una transacción de lectura
                        contador_bits_receptor = 0; // Re inicio contadro bits del receptor
                        next_state_receptor = ESCRITURA;
                    end else if(ultimo_bit_adr == 1) begin // Si RNW es 0, es una transacción de escritura
                        contador_bits_receptor = 0; // Re inicio contadro bits del receptor
                        next_state_receptor = LECTURA;
                    end
                end else if (contador_WR_DATA_receptor == 17) begin
                    next_state_receptor = PARADA;
                end
            end

            RECIBIR_ACK: begin
                contador_bits_receptor = 0; // Reinicio el contador de bits de datos
                if (contador_RD_DATA_receptor == 17) begin //Si ACK en alto voy a Parada
                    flag_comunicacion_receptor = 0; //Termino comunicacion
                    next_state_receptor = PARADA; // Voy a condicion de parada
                end else  if (~SDA_OUT) begin //Si recibo un ACK
                    if (ultimo_bit_adr) begin // Si RNW es 1, es una transacción de lectura
                        next_state_receptor = LECTURA;
                    end else begin // Si RNW es 0, es una transacción de escritura
                        next_state_receptor = ESCRITURA;
                    end
                end 
            end
    
            LECTURA: begin //Aqui se envian tramas de 16 bits
                 se_envio_direcion = 1;
                if (contador_bits_receptor == 9 || contador_RD_DATA_receptor == 17) begin
                    flag_comunicacion_receptor = 1; // Mientras haya bits que leer, la comunicación sigue
                    next_state_receptor = RECIBIR_ACK;
                end 
            end

            ESCRITURA: begin
                 se_envio_direcion = 1;
                if (contador_bits_receptor == 9 || contador_WR_DATA_receptor == 17 ) begin // Mientras haya bits que escribir, la comunicación sigue
                    flag_comunicacion_receptor = 1;
                    next_state_receptor = ENVIAR_ACK;
                end 
            end

            PARADA:begin
                if (~SDA_OUT) begin
                    next_state_receptor = IDLE;
                end
            end
           
        endcase
    end

    always @(posedge SCL) begin
        if (~rst_receptor) begin // Inicio variables internas
            contador_bits_receptor <= 0; contador_adr_receptor <= 0; get_I2C_ADDR <= 7'b0; ultimo_bit_adr <= 0; flag_end_addres <= 0; se_envio_direcion <= 0;

        end else begin
            case (state_receptor) // Comportamiento de las salidas ante cambios de estados

                IDLE: begin // Caso inicial maquina estados
                    SDA_IN <= 0;
                end


                ENVIAR_ACK: begin
                    if (flag_end_addres) begin // Si ya termine de leer los bit de la direccion
                        if (contador_bits_receptor == 9 || contador_WR_DATA_receptor == 16) begin
                            SDA_IN <= 0; // Enviar ACK
                        end
                    end
                    else begin
                        if (contador_adr_receptor <= 7 ) begin // Recolecto los 7 bits de la direccion del receptor
                            // Desplaza los bits de SDA_OUT hacia la derecha e inserta el nuevo bit en get_I2C_ADDR
                            get_I2C_ADDR <= {get_I2C_ADDR[5:0], SDA_OUT}; // Concatenacion
                            SDA_IN <= SDA_OUT;
                        end
                        if (contador_adr_receptor == 8 ) begin
                            ultimo_bit_adr <= SDA_OUT; //PROBLEMA LEER ULTIMO BIT
                            SDA_IN <=0; //Envio un ACK
                        end
                        contador_adr_receptor <= contador_adr_receptor + 1; // Incrementar el contador de bits
                        end
                end

                LECTURA: begin
                    if (contador_bits_receptor <= 8) begin // Si contador_bits es menor o igual a 15
                        if (contador_RD_DATA_receptor <= 15) begin
                            SDA_IN <= RD_DATA_receptor[15 - contador_RD_DATA_receptor]; // Enviar el bit correspondiente de WR_DATA
                        end
                        if (contador_RD_DATA_receptor == 16) begin
                            SDA_IN <= RD_DATA_receptor[15 - 15]; // Enviar el bit correspondiente de WR_DATA
                        end
                        contador_RD_DATA_receptor <= contador_RD_DATA_receptor + 1;
                    end
                    contador_bits_receptor <= contador_bits_receptor + 1; // Incrementar el contador de bits
                
                end

                RECIBIR_ACK: begin
                    if (~SDA_OUT) begin // Si SDA_IN en bajo actualizo SDA_OUT
                        SDA_IN <= 0;
                    end else begin
                        SDA_IN <= 1;
                    end 
                end

                ESCRITURA: begin
                    // Durante la escritura, envía los bits de WR_DATA por SDA_OUT uno a uno
                    if (contador_bits_receptor <= 8) begin
                        SDA_IN <= SDA_OUT; // Enviar el bit correspondiente de WR_DATA
                        WR_DATA_receptor <= {WR_DATA_receptor[16:0], SDA_OUT};
                        contador_WR_DATA_receptor <= contador_WR_DATA_receptor + 1;
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

