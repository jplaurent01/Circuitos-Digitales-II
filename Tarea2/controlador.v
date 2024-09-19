module controlador_estacionamiento (
    input wire clk, //Senial de reloj
    input wire rst, //Senial de reinicio
    input wire sensor_vehicule, //Sensor de vehiculo
    input wire sensor_moved_vehicule, //Sensor de vehiculo desplazado
    //input wire [15:0] correct_password, //Contrasenia correcta
    input wire [15:0] password_input, //Contrasenia de entrada
    output reg open_gate, // Salida compuerta abierta
    output reg close_gate, // Salida compuerta cerrada
    output reg alarm_wrong_pin, // Salida alarma de pin incorrecto
    output reg alarm_blocked // Salida alarma bloqueo
);

    //Definicion de los estados del conrolador de estacionamiento
    parameter IDLE = 3'b000;//Estado inicial
    parameter WAIT_FOR_KEY = 3'b001;//Espera de contrasenia
    parameter CHECK_KEY = 3'b010;//Verificacion contrasenia
    parameter OPEN_GATE = 3'b011;//Abrir compuerta
    parameter CLOSE_GATE = 3'b100;//Cerrar compuerta
    parameter WRONG_KEY = 3'b101;//Clave erronea
    parameter BLOCKED = 3'b110;//Alarma bloqueo

    //Contrasenia por defecto
    parameter correct_password = 16'b0011_0111_0110_0001;// contrasenia correcta 3761
    reg [2:0] state, next_state; //registros del estado actual y siguiente estado
    reg [2:0] counter; // Contador para intentos fallidos


    //Transición de estados
    always @(posedge clk) begin
        if (rst) begin //Caso inicial y de reinicio, se establecen condiciones iniciales
            state <= IDLE; //Se establce como estado inicial IDLE
        end else begin
            state <= next_state; //Caso actual para a ser el siguiente estado
            //asociar valor estado cuando no estan en rst
        end
    end
    
    //máquina de estados
    always @(*) begin
        next_state = state;//Siguiente estado es el estado actual
        case (state)
            IDLE: begin //Caso inicial maquina estados
                if (sensor_vehicule) begin //Si detecto un vehiculo
                    next_state = WAIT_FOR_KEY;//Espero contrasenia
                end
            end
    
            WAIT_FOR_KEY: begin //Caso donde espero contrasenia
                next_state = CHECK_KEY; //Verifico contrasenia
            end
            
            CHECK_KEY: begin //Caso donde verifico contrasenia
                if (password_input == correct_password) begin //Contrsenia correcta
                    next_state = OPEN_GATE; //Abro compuerta
                end else begin //Contrasenia incorrecta
                    next_state = WRONG_KEY;
                end
            end
            
            OPEN_GATE: begin //Caso donde abro compuerta
                if (sensor_moved_vehicule) begin //Verifico si el vehiculo se mueve
                    next_state = CLOSE_GATE; //Cierro compuerta
                end
            end
            
            CLOSE_GATE: begin //Caso donde se cierra compuerta
                next_state = IDLE; //Regreso a estado inicial en espera de un vehiculo
            end
            
            WRONG_KEY: begin //Caso de clave erronea
                if (counter >= 3) begin // Si el contador de intentos es mayor igual a  3
                    next_state = BLOCKED; //Activo alarma de bloqueo
                end else begin //Caso contrario pido que se ingrese contrasenia correcta
                    next_state = WAIT_FOR_KEY;
                end
            end
            
            BLOCKED: begin
                //Permanezco bloqueado hasta reiniciar sistema
            end
        endcase
    end

    //Comportamiento salidas controlador, siempre que exista un cambio
    always @(posedge clk) begin
        if (rst) begin
            open_gate <= 0;
            close_gate <= 0;
            alarm_wrong_pin <= 0;
            alarm_blocked <= 0;
            counter <= 0;
        end else begin

            case (state)//Comportamiento de las salidas ante cambios de estados
                IDLE: begin //Caso inicial
                    open_gate <= 0;
                    close_gate <= 0;
                    alarm_wrong_pin <= 0;
                    alarm_blocked <= 0;
                    counter <= 0;
                end
                
                WAIT_FOR_KEY: begin 
                    //Espero clave
                end
                
                CHECK_KEY: begin
                    //Verifico clave
                end
                
                OPEN_GATE: begin //Abro compuerta
                    open_gate <= 1;//Abro puerta
                    close_gate <= 0;//puerta abierta
                    alarm_wrong_pin <= 0;//No bloqueo
                    alarm_blocked <= 0;//No bloqueo
                end
                
                CLOSE_GATE: begin //Cierro puerta
                    open_gate <= 0;
                    close_gate <= 1;
                end
                
                WRONG_KEY: begin //Caso de introducir mal la contrasenia
                    counter <= counter + 1; //Cuenta un intento
                    if (counter > 2) begin //Verifico si llego a 3 intentos
                        alarm_wrong_pin <= 1; //Activo alarma de pin incorrecto
                    end
                end
                
                BLOCKED: begin //Alarma de bloqueo
                    alarm_blocked <= 1; //activo alarma
                end
            endcase
        end
    end
endmodule
