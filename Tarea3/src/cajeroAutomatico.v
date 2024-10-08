module cajero_automatico (
    //Entradas
    input wire clk, // Senial de reloj
    input wire rst, // Senial de reinicio
    input wire TARJETA_RECIBIDA, // Senial tarjeta recibida
    input wire TIPO_TRANS, // Senial tipo transacion 0 desposito 1 retiro
    input wire MONTO_STB, // Senial de entrada que se pone en 1 durante un solo ciclo de reloj (STB) cuando se ha actualizado el valor del MONTO a través del teclado
    input wire DIGITO_STB, // Senial de entrada que se pone en 1 durante un solo ciclo de reloj (STB) cuando se presiona un botón en el teclado. La lectura del PIN debe compararse con los valores de la entrada DIGITO cuando DIGITO_STB=1.
    input wire [3:0] DIGITO, // Ultimo dígito tecleado por el usuario
    input wire [15:0] PIN, // Entrada de 16 bits donde cada grupo de 4 bits representa un dígito del PIN de la tarjeta que se recibió
    input wire [31:0] MONTO, // Entrada de 32 bits que representa el monto de la transacción expresado en binario.
    input wire [63:0] BALANCE_INICIAL, // Entrada de 64 bits que contiene el balance de la cuenta al inicio de cada transacción. Debe tener su valor actualizado al momento en que se digita el pin correcto. Se debe garantizar que el banco de pruebas se ajuste a este comportamiento. 
    //Salidas
    output reg BALANCE_ACTUALIZADO, // Salida de un bit para indicar que una transacción fue exitosa y que se actualizó el balance en la cuenta, tanto para depósitos como para retiros
    output reg ENTREGAR_DINERO, // Salida de un bit para indicarle al cajero que entregue el MONTO durante una transacción de retiro
    output reg PIN_INCORRECTO, // Senial que indica que el valor del PIN recibido a través del teclado (la entrada DIGITO) es distinto del PIN de la tarjeta especificado en la entrada PIN.
    output reg ADVERTENCIA, // Salida binaria que se enciende cuando el usuario ha introducido el PIN de forma incorrecta dos veces 
    output reg BLOQUEO,// Salida binaria que se enciende cuando el usuario ha introducido el pin de forma incorrecta 3 veces
    output reg FONDOS_INSUFICIENTES // Senial salida cuando no hay suficientes fondos
);

    //Definicion de los estados del cajero automatico
    parameter IDLE = 4'b0000;                 // Estado inicial
    parameter ESPERA_TARJETA = 4'b0001;       // Espera de tarjeta
    parameter LEER_PIN = 4'b0010;             // Lectura de pin
    parameter VERIFICAR_PIN = 4'b0011;        // Verificacion del pin
    parameter SELECCIONAR_TRANSACCION = 4'b0100; // Seleccion de tipo de transaccion
    parameter PROCESAR_OPERACION = 4'b0101;   // Procesamiento desposito o retiro
    parameter WRONG_PIN = 4'b0110;            // Pin incorrecto

    //Variales internas
    reg [2:0] state, next_state; //registros del estado actual y siguiente estado
    reg [1:0] intentos; // Contador para intentos fallidos
    reg [63:0] BALANCE;  // Cotador de balances
    reg [15:0] pin_tecleado;        // PIN tecleado por el usuario
    reg [1:0] digitos_ingresados;   // Número de dígitos ingresados

    //Transición de estados
    always @(posedge clk) begin
        if (rst) begin //Caso inicial y de reinicio, se establecen condiciones iniciales
            state <= IDLE; //Se establce como estado inicial IDLE
        end else begin
            state <= next_state; //Caso actual para a ser el siguiente estado
        end
    end
    
    // Máquina de estados
    always @(*) begin
        next_state = state; // Siguiente estado es el estado actual
        case (state)
            IDLE: begin // Caso inicial maquina estados
                if (TARJETA_RECIBIDA) begin // Si detecto una tarjeta
                    next_state = ESPERA_TARJETA;// Espero tarjeta
                end
            end
    
            ESPERA_TARJETA: begin // Caso donde espero por una tarjeta
                next_state = LEER_PIN; // Leo un digito del pin
            end

            LEER_PIN: begin // Leo los digitos del pin 
                if (DIGITO_STB) begin // Siempre que DIGITO_STB este en alto
                    if (digitos_ingresados == 3) begin
                        next_state = VERIFICAR_PIN; // Una vez se digitan todos los digito verifico pin
                    end else begin
                        next_state = LEER_PIN; // Continuo leyendo digitos
                    end
                end else begin
                    next_state = LEER_PIN; // Continuo leyendo digitos
                end
                
            end
            
            VERIFICAR_PIN: begin // Caso donde verifico Pin
                if (PIN == pin_tecleado) begin // Pin correcta
                    next_state = SELECCIONAR_TRANSACCION; // Verifico el tipo de transacion
                end else begin // Pin incorrecta
                    next_state = WRONG_PIN;
                end
            end
            
            SELECCIONAR_TRANSACCION: begin //Caso donde seleciono el tipo de operacion
                next_state = PROCESAR_OPERACION;
            end

            PROCESAR_OPERACION: begin // Proceso el tipo de operacio
                next_state = IDLE; // Retorna al estado base
            end

            WRONG_PIN: begin // Caso de Pin erroneo
                next_state = LEER_PIN; //Continuo leyendo un pin
            end
            
        endcase
    end

    //Comportamiento salidas cajero_automatico, siempre que exista un cambio en el flanco positivo de la senial de reloj
    always @(posedge clk) begin
        if (rst) begin
            // Estado inicial seniales de salida y variables interns 
            BALANCE_ACTUALIZADO <= 0;
            ENTREGAR_DINERO <= 0;
            PIN_INCORRECTO <= 0;
            ADVERTENCIA <= 0;
            BLOQUEO <= 0;
            FONDOS_INSUFICIENTES <= 0;
            intentos <= 0;
            BALANCE <= 0;
            pin_tecleado <= 0;
            digitos_ingresados <= 0; 

        end else begin

            case (state)// Comportamiento de las salidas ante cambios de estados
                IDLE: begin //Caso inicial, reinicio salidas y variables internas
                    BALANCE_ACTUALIZADO <= 0;
                    ENTREGAR_DINERO <= 0;
                    PIN_INCORRECTO <= 0;
                    ADVERTENCIA <= 0;
                    BLOQUEO <= 0;
                    FONDOS_INSUFICIENTES <= 0;
                    intentos <= 0;
                    BALANCE <= 0;
                    pin_tecleado <= 0;
                    digitos_ingresados <= 0; 
                end
                
                ESPERA_TARJETA: begin 
                    //Espero pin
                end

                LEER_PIN: begin
                    // Se almacena cada dígito del PIN tecleado
                    if (DIGITO_STB) begin
                        pin_tecleado <= {pin_tecleado[11:0], DIGITO}; // realiza una concatenación de bits y asigna el resultado a la señal pin_tecleado
                        digitos_ingresados <= digitos_ingresados + 1; // Incremento en 1 el contador de datos ingresados hasta llegar a 3
                    end
                end
                
                VERIFICAR_PIN: begin
                    //Verifico pin
                end
                
                SELECCIONAR_TRANSACCION: begin 
                    //Verifico tipo de transacion
                end

                PROCESAR_OPERACION: begin
                    // Caso de deposito
                    if (MONTO_STB && TIPO_TRANS == 1'b0) begin
                        BALANCE <= BALANCE_INICIAL + MONTO; //Sumo balance inicial y monto y almaceno en balance
                        BALANCE_ACTUALIZADO <= 1; // Activo senial salida
                    // Caso de retiro
                    end if (MONTO_STB && TIPO_TRANS == 1'b1) begin
                        // Caso de fondos suficientes
                        if (MONTO <= BALANCE_INICIAL) begin
                            BALANCE <= BALANCE_INICIAL - MONTO; // Retiro dinero
                            BALANCE_ACTUALIZADO <= 1; // Activo senial salida
                            ENTREGAR_DINERO <= 1; // Activo senial salida

                         // Caso de fondos insuficientes
                        end else begin
                            FONDOS_INSUFICIENTES <= 1;// Activo senial salida
                        end
                    end
                end

                //Se ingresa pin incorrecto
                WRONG_PIN:begin
                     // Se actualizan los intentos
                    if (intentos == 0) begin // Si ya falló una vez (el valor anterior a este ciclo era 1)
                        PIN_INCORRECTO <= 1;    // Activamos la advertencia
                    end 
                    intentos <= intentos + 1;
                    if (intentos == 1) begin // Si ya falló una vez (el valor anterior a este ciclo era 1)
                        PIN_INCORRECTO <= 0;
                        ADVERTENCIA <= 1;     // Activamos la advertencia
                    end 
                    if (intentos >= 2) begin // Si ya falló tres veces (valor anterior era 2)
                        ADVERTENCIA <= 0;   
                        BLOQUEO <= 1;         // Activamos el bloqueo
                    end
                end
                
                
            endcase
        end
    end
endmodule
