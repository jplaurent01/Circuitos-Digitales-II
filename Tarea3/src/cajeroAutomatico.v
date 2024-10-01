module cajero_automatico (
    //Entradas
    input wire clk, //Senial de reloj
    input wire rst, //Senial de reinicio
    input wire TARJETA_RECIBIDA, //Senial tarjeta recibida
    input wire TIPO_TRANS, //Senial tipo transacion 0 desposito 1 retiro
    input wire MONTO_STB, // Senial de entrada que se pone en 1 durante un solo ciclo de reloj (STB) cuando se ha actualizado el valor del MONTO a través del teclado
    input wire DIGITO_STB, //Senial de entrada que se pone en 1 durante un solo ciclo de reloj (STB) cuando se presiona un botón en el teclado. La lectura del PIN debe compararse con los valores de la entrada DIGITO cuando DIGITO_STB=1.
    input wire [3:0] DIGITO, // Ultimo dígito tecleado por el usuario
    input wire [15:0] PIN, //Entrada de 16 bits donde cada grupo de 4 bits representa un dígito del PIN de la tarjeta que se recibió
    input wire [31:0] MONTO, //Entrada de 32 bits que representa el monto de la transacción expresado en binario.
    input wire [63:0] BALANCE_INICIAL, //Entrada de 64 bits que contiene el balance de la cuenta al inicio de cada transacción. Debe tener su valor actualizado al momento en que se digita el pin correcto. Se debe garantizar que el banco de pruebas se ajuste a este comportamiento. 
    //Salidas
    output reg BALANCE_ACTUALIZADO, //Salida de un bit para indicar que una transacción fue exitosa y que se actualizó el balance en la cuenta, tanto para depósitos como para retiros
    output reg ENTREGAR_DINERO, // Salida de un bit para indicarle al cajero que entregue el MONTO durante una transacción de retiro
    output reg PIN_INCORRECTO, // Senial que indica que el valor del PIN recibido a través del teclado (la entrada DIGITO) es distinto del PIN de la tarjeta especificado en la entrada PIN.
    output reg ADVERTENCIA, // Salida binaria que se enciende cuando el usuario ha introducido el PIN de forma incorrecta dos veces 
    output reg BLOQUEO,//Salida binaria que se enciende cuando el usuario ha introducido el pin de forma incorrecta 3 veces
    output reg FONDOS_INSUFICIENTES // Senial salida cuando no hay suficientes fondos
);

    //Definicion de los estados del cajero automatico
    parameter IDLE = 0;//Estado inicial
    parameter ESPERA_TARJETA = 1;//Espera de tarjeta
    parameter LEER_PIN = 2; //Lectura de pin
    parameter VERIFICAR_PIN = 3;//Verificacion pin
    parameter SELECCIONAR_TRANSACCION = 4;//Seleciono tipo transacion
    parameter PROCESAR_DEPOSITO = 5;//Proceso un deposito
    parameter PROCESAR_RETIRO = 6;//Proceso un retiro
    parameter JUMP_IDLE = 7;
    parameter WRONG_PIN  = 8;//Pin incorrecto
    parameter BLOCKED = 9;//Bloqueo sistema cuando e cuando el usuario ha introducido el pin de forma incorrecta 3 veces

    //Contrasenia por defecto
    //parameter correct_password = 16'b0011_0111_0110_0001;// contrasenia correcta 3761
    reg [2:0] state, next_state; //registros del estado actual y siguiente estado
    reg [1:0] intentos; // Contador para intentos fallidos
    reg [63:0] BALANCE;  //Cotador de balances
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
    
    //máquina de estados
    always @(*) begin
        next_state = state;//Siguiente estado es el estado actual
        case (state)
            IDLE: begin //Caso inicial maquina estados
                if (TARJETA_RECIBIDA) begin //Si detecto una tarjeta
                    next_state = ESPERA_TARJETA;//Espero contrasenia
                end
            end
    
            ESPERA_TARJETA: begin //Caso donde espero por una tarjeta
                next_state = LEER_PIN; //Verifico pin
            end

            LEER_PIN: begin
                if (DIGITO_STB) begin
                    if (digitos_ingresados == 3) begin
                        next_state = VERIFICAR_PIN;
                    end else begin
                        next_state = LEER_PIN;
                    end
                end else begin
                    next_state = LEER_PIN;
                end
                
            end
            
            VERIFICAR_PIN: begin //Caso donde verifico contrasenia
                if (PIN == pin_tecleado) begin //Contrsenia correcta
                    next_state = SELECCIONAR_TRANSACCION; //Verifico el tipo de transacion
                end else begin //Contrasenia incorrecta
                    next_state = WRONG_PIN;
                end
            end
            
            SELECCIONAR_TRANSACCION: begin //Caso donde verifico el tipo de transacion
                if (TIPO_TRANS == 0) begin //Realizo un deposito
                    next_state = PROCESAR_DEPOSITO; 
                end else if (TIPO_TRANS == 1) begin
                    next_state = PROCESAR_RETIRO;//Realizo un retiro
                end else begin
                    next_state = IDLE; //No realizo deposito ni retiro
                end
            end

            PROCESAR_DEPOSITO: begin
                next_state = JUMP_IDLE;
            end
            
            PROCESAR_RETIRO : begin
                next_state = JUMP_IDLE;
            end

            WRONG_PIN: begin //Caso de clave erronea
                if (intentos > 2) begin // Si el contador de intentos es mayor igual a  3
                    next_state = BLOCKED; //Activo alarma de bloqueo
                end else begin //Caso contrario pido que se ingrese contrasenia correcta
                    next_state = VERIFICAR_PIN;
                end
            end

            BLOCKED: begin
                //Permanezco bloqueado hasta reiniciar sistema
            end

            JUMP_IDLE:
             begin
                next_state = IDLE;
             end
            
        endcase
    end

    //Comportamiento salidas cajero_automatico, siempre que exista un cambio en el flanco positivo de la senial de reloj
    always @(posedge clk) begin
        if (rst) begin //Estado inicial seniales de salida
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

            case (state)//Comportamiento de las salidas ante cambios de estados
                IDLE: begin //Caso inicial
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
                        pin_tecleado <= {pin_tecleado[11:0], DIGITO};
                        digitos_ingresados <= digitos_ingresados + 1;
                    end
                end
                
                VERIFICAR_PIN: begin
                    //Cada vez que el usuario presiona un dígito,
                    //la señal DIGITO_STB se pone en 1 durante un ciclo de 
                    //reloj y se actualiza el valor de la entrada DIGITO.
                    //Una vez introducidos los 4 dígitos del número de PIN, el resultado se compara con
                    // el de la entrada PIN.
                end
                
                SELECCIONAR_TRANSACCION: begin 
                    //Verifico tipo de transacion
                end
                
                PROCESAR_DEPOSITO: begin
                    if (MONTO_STB) begin
                        BALANCE <= BALANCE_INICIAL + MONTO;
                        BALANCE_ACTUALIZADO <= 1;
                    end
                end

                PROCESAR_RETIRO: begin
                    if (MONTO_STB) begin
                        if (MONTO <= BALANCE_INICIAL) begin
                            BALANCE <= BALANCE_INICIAL - MONTO;
                            BALANCE_ACTUALIZADO <= 1;
                            ENTREGAR_DINERO <= 1;
                        end else begin
                            FONDOS_INSUFICIENTES <= 1;
                        end
                    end
                end

                WRONG_PIN:begin
                    PIN_INCORRECTO <= 1;
                    intentos <= intentos + 1;
                    if (intentos == 2) begin
                        ADVERTENCIA <= 1;
                    end else if (intentos > 2) begin
                        BLOQUEO <=1;
                    end
                end

                JUMP_IDLE: begin
                
                end
                
            endcase
        end
    end
endmodule
