module generador_transacciones (

    //Entradas
    input wire clk, // Senial de reloj
    input wire rst, // Senial de reinicio, activo en bajo
    input wire START_STB,//Strobe (pulso de un ciclo de reloj). Indica al generador que el CPU quiere iniciar una transacción de I2C
    input wire RNW,//Esta señal indica la dirección de la transacción que deseaejecutar el CPU. Cuando RNW=1 se trata de una transacción de lectura y cuando RNW=0 se trata de una escritura.
    input wire [6:0] I2C_ADDR, //– Esta entrada proviene de un registro del CPU y contiene la dirección del receptor de transacciones con quien el generador se quiere comunicar.
    input wire SDA_IN, //Entrada serie proveniente del probador. Debe tener el comportamiento especificado por el protocolo I2C para producir la indicación de ACK, así como proporcionar los datos de entrada en transacciones de lectura
    input wire [15:0] WR_DATA,//– Entrada paralela. Contiene los 16 bits que se deben enviar por la interfaz I2C durante una transacción de escritura de acuerdo a este enunciado.
    
    //Salidas
    output reg SDA_OE, //Habilitación de SDA_OUT. Se debe poner en 1 para aquellas porciones de la transacción donde el generador tiene control del bus I2C y ponerse en 0 para las porciones de la transacción donde el receptor tiene control del bus, de acuerdo con las especificaciones del protocolo.
    output wire SCL, //Salida de reloj para el I2C. El flanco activo de la señal SCL es el flanco creciente. Observe que SCL es una salida del generador, que deberá tener una frecuencia del 25% de la frecuencia de la entrada CLK. El generador debe generar SCL con la frecuencia correcta para cualquier posible valor de la frecuencia de entrada CLK.
    output reg SDA_OUT, //Salida serial. Debe tener el comportamiento especificado por el protocolo I2C para las condiciones de INICIO, STOP y transacciones de escritura y lectura.
    output reg[15:0] RD_DATA//Esta salida debe producir los 16 bits que se reciben desde el receptor de transacciones I2C durante una transacción de lectura recibida en SDA_IN. Una vez que se ha recibido los 16 bits completos, el generador de transacciones debe enviar la condición de STOP de acuerdo al protocolo I2C.
);

    //Definicion de los estados del generador
    parameter INICIO = 0;  // Aqui se produce un condicion de inicio, se debe bajar SDA mientras el SCL permanece en alto (transacion no ocurre en un flanco del SCL)
    parameter ENVIAR_DIR_RECEPTOR = 1; // Se envia direccion del receptor
    parameter ESCRITURA = 2; // Escritura
    parameter LECTURA = 3; // Lectura
    parameter PARADA = 4;   // Indicacion de parar
    parameter RECIBIR_ACK = 5; // Recibo ack
    parameter ENVIAR_ACK = 6; // Recibo ack

    //Variables intermedias
    reg [2:0] state, next_state; // Registros del estado actual y siguiente estado
    reg [4:0] contador_bits; // Contador de bits para proceso de lectura o escritura
    reg [4:0] contador_adr;// Contador de bits de la direcion del recepetor
    reg [4:0] contador_WR_DATA; // Contador de bits de WR_DATA 
    reg [4:0] contador_RD_DATA; // Contador de bits de RD_DATA 
    reg flag_comunicacion;// Bandera que indica si se mantiene o no la comunicacion
    reg flag_end_addres; // Bandera de que se termino de enviar direccion
    reg condicion_scl;// Selector de conmutacion reloj o señal permanece unicamente en alto
    reg condicion_de_parada; // Determino si realizo una parada
    reg clk_div2; // Registro que divide la frecuencia del reloj a la mitad.
    wire clk_div4; // Señal que divide la frecuencia del reloj por cuatro.
    reg [1:0] count_clock; // Contador de 2 bits para llevar un seguimiento del ciclo del reloj.

    //Fip flops
    always @(posedge clk) begin
        if (~rst) begin //Caso inicial y de reinicio, se establecen condiciones iniciales
            state <= INICIO; // Se establce como estado inicial INICIO
            flag_comunicacion <= 0; // No existe comunicacion
            flag_end_addres <= 0; // Bandera de que se termino de enviar la direcion
            condicion_scl <= 0; // Reloj permanece en alto inicialmente
            condicion_de_parada <= 0; // Condicion parada en cero
            contador_bits <= 0; // Contador bits en 0
            contador_adr <= 0; // Contador bits de la direcion del receptor en 0
            clk_div2    <= 0; // Cuando rst está activo, se reinicia clk_div2 y el contador a 0.
            count_clock <= 0; // Contador del divisor de frecuencia en cero
            contador_WR_DATA <= 0;
            
        end else begin
            state <= next_state; //Caso actual para a ser el siguiente estado
            clk_div2 <= ~clk_div2; // Invertir clk_div2 en cada flanco positivo del reloj para dividir su frecuencia.
            count_clock <= count_clock+1; // Incrementar el contador de reloj.

            case (state)
                INICIO: begin // Caso inicial maquina estados
                    SDA_OUT <= 0; //Pongo SDA_OUT en bajo
                end

                ENVIAR_ACK: begin 
                    if (contador_adr == 9 ) begin
                        flag_end_addres <= 1; //Se termino de enviar direccion si contador_adr_receptor == 9 
                    end
                end
                
                PARADA:begin
                //Actualizo SDA_OUT en alto, Contador bits en 0, Contador bits de la direcion del receptor en 0
                    SDA_OUT <= 1; contador_bits <= 0; contador_adr <= 0; contador_WR_DATA <= 0; contador_RD_DATA <= 0;
                end
                
            endcase

        end
    end
    
    //Logica combinacional
    always @(*) begin
        next_state = state; // Siguiente estado es el estado actual
        case (state)
            INICIO: begin // Caso inicial maquina estados
                if (START_STB && SCL) begin //Se inicia comunicacion el generador de transacciones debe producir la  condición de inicio. Es decir, debe bajar la señal SDA mientras el SCL permanece en alto.  Note que esta transición NO ocurre en un flanco del SCL.
                    condicion_scl = 1; // Reloj conmuta
                    next_state = ENVIAR_DIR_RECEPTOR; // Envio direcion del receptor en cada flanco positivo de SCL
                end
                
            end

            ENVIAR_DIR_RECEPTOR: begin // Envio direcion del receptor
                if (contador_adr == 9) begin // Si contador_adr es igual a 9 epero un ACK
                    next_state = RECIBIR_ACK; 
                end
            end

            RECIBIR_ACK: begin // Recibo ack cuando contador adress == 9 o contador bits == 9
                contador_bits = 0; // Reinicio el contador de bits de datos
                if (contador_WR_DATA == 17) begin //Si ACK en alto voy a Parada
                    flag_comunicacion = 0; //Termino comunicacion
                    next_state = PARADA; // Voy a condicion de parada
                end else  if (~SDA_IN) begin //Si recibo un ACK
                    if (RNW) begin // Si RNW es 1, es una transacción de lectura
                        next_state = LECTURA;
                    end else begin // Si RNW es 0, es una transacción de escritura
                        next_state = ESCRITURA;
                    end
                end 
            end

            ENVIAR_ACK: begin
                if (contador_WR_DATA == 17) begin
                    next_state = PARADA;
                end else if (contador_bits == 9) begin
                    if (~RNW) begin // Si RNW es 0, es una transacción de ESCRITURA
                        contador_bits = 0; // Re inicio contadro bits del receptor
                        next_state = ESCRITURA;
                    end else if(RNW) begin // Si RNW es 1, es una transacción de LECTURA
                        contador_bits = 0; // Re inicio contadro bits del receptor
                        next_state = LECTURA;
                    end
                end 
            end
            
            LECTURA: begin // Aqui se envian tramas de 16 bits
                if (contador_bits == 9 || contador_WR_DATA == 17 ) begin // Mientras haya bits que escribir, la comunicación sigue
                    flag_comunicacion = 1;
                    next_state = ENVIAR_ACK;
                end 
            end

            ESCRITURA: begin
                if (contador_bits == 9 || contador_WR_DATA == 17) begin // Mientras haya bits que escribir, la comunicación sigue
                    flag_comunicacion = 1; // Continua la comunicacion
                    next_state = RECIBIR_ACK; // Verifico si recibo un ACK
                end
            end

            PARADA:begin // Condicion parada
                condicion_scl = 0; // Señal SCL permanece en alto
                if (condicion_scl == 0) begin
                    next_state = INICIO; //Porximo estado INICIO
                end
            
            end
            
        endcase
    end

    assign clk_div4 = count_clock[1]; // La señal `clk_div4` se genera tomando el segundo bit del contador, dividiendo así la frecuencia del reloj por 4.
    assign SCL = condicion_scl ? count_clock[1] : 1'b1; // Seleciono si reloj conmuta o permanece en alto.

   always @(posedge SCL) begin //Cada vez que se da un flanco positivo del reloj SCL hago algo
    if (~rst || START_STB) begin // Caso de un reset, reinicion contadores y condicion parada
        contador_bits <= 0; contador_adr <= 0; contador_WR_DATA <= 0; condicion_de_parada <= 0; flag_end_addres <= 0;
    end else begin
        case (state) // Comportamiento de las salidas ante cambios de estados
            INICIO: begin 
            end

            ENVIAR_DIR_RECEPTOR: begin // Envio de datos
                if (contador_adr <= 6) begin // Si contador es menor o igual a 6 bits
                    SDA_OUT <= I2C_ADDR[6 - contador_adr]; // SDA out transmite contenido de WR_DATA
                end
                if (contador_adr == 7 && RNW) begin // Si deseo LEER ultimo bit es 1
                    SDA_OUT <= 1'b1; // Enviar 1 si RW LECTURA
                end
                if (contador_adr == 7 && ~RNW) begin // Si deseo escribir último bit es 0
                    SDA_OUT <= 1'b0; // Enviar 0 si RW ESCRITURA
                end
                contador_adr <= contador_adr + 1; //Contador de bits direcion incrementa en 1.
                
            end

            RECIBIR_ACK: begin
                SDA_OE <= 0; // No tengo control bus
                if (~SDA_IN) begin // Si SDA_IN en bajo actualizo SDA_OUT
                    SDA_OUT <= 0;
                end else begin
                    SDA_OUT <= 1;
                end
            end

            ENVIAR_ACK: begin
                if (flag_end_addres) begin // Si ya termine de leer los bit de la direccion
                    if (contador_bits == 9 || contador_WR_DATA == 16) begin
                        SDA_OUT <= 0; // Enviar ACK
                    end
                end
            end
            
            LECTURA: begin // Lectura
                // Durante la lectura, recibo los bits de RD_DATA por SDA_IN uno a uno
                    if (contador_bits <= 8) begin
                        SDA_OUT <= SDA_IN; // Enviar el bit correspondiente de RD_DATA
                        RD_DATA <= {RD_DATA[16:0], SDA_IN};
                        contador_WR_DATA <= contador_WR_DATA + 1;
                    end
                    contador_bits <= contador_bits + 1; // Incrementar el contador de bits
                
            end

            ESCRITURA: begin // Durante la escritura, envía los bits de WR_DATA por SDA_OUT uno a uno
                if (contador_bits <= 8) begin // Si contador_bits es menor o igual a 15
                    if (contador_WR_DATA <= 15) begin
                        SDA_OUT <= WR_DATA[15 - contador_WR_DATA]; // Enviar el bit correspondiente de WR_DATA
                    end
                    if (contador_WR_DATA == 16) begin
                        SDA_OUT <= WR_DATA[15 - 15]; // Enviar el bit correspondiente de WR_DATA
                    end
                    SDA_OE <= 1;  // Habilitar la salida SDA
                    contador_WR_DATA <= contador_WR_DATA + 1;
                end
                contador_bits <= contador_bits + 1; // Incrementar el contador de bits
            end

            PARADA: begin // Lógica para manejar el estado de PARADA
                SDA_OE <= 0;  // Asegurar que la salida esté deshabilitada en PARADA
            end
        endcase
    end
end

endmodule
