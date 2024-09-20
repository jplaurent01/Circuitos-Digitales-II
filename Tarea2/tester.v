 module tester (
    output reg clk, //Senial de reloj
    output reg rst, //Senial de reinicio
    output reg sensor_vehicule, //Sensor de vehiculo
    output reg sensor_moved_vehicule, //Sensor de vehiculo desplazado
    //output wire [15:0] correct_password, //Contrasenia correcta
    output reg [15:0] password_input, //Contrasenia de entrada
    input wire open_gate, // Salida compuerta abierta
    input wire close_gate, // Salida compuerta cerrada
    input wire alarm_wrong_pin, // Salida alarma de pin incorrecto
    input wire alarm_blocked // Salida alarma bloqueo
);


    // Generación del reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;//original 5
    end

        // Secuencia de prueba
    initial begin
        //Se inicializan las entradas del controlador
        rst = 1; sensor_vehicule = 0; sensor_moved_vehicule = 0; password_input = 0;
        #10 rst = 0;

        //Prueba 1: Ingreso de clave correcta
        #40 sensor_vehicule = 1; //Llega vehiculo
        #20 password_input = 16'b0011_0111_0110_0001; //Ingreso contrasenia correcta
        #30 sensor_moved_vehicule = 1;//Vehiculo se mueve
        #30 sensor_moved_vehicule = 0;//Vehiculo ya no se mueve
        #20 sensor_vehicule = 0;//Ya no hay vehiculo

        //Prueba 2: Ingreso de clave incorrecta 2 veces contrasenia
        #30 sensor_vehicule = 1; //Llega vehiculo
        #20 password_input = 16'b0001_0010_0011_0101; // Contrasenia incorrecta
        #20 sensor_vehicule = 1; //
        #20 password_input = 16'b0001_0010_0011_0100; // Contrasenia incorrecta
        #20 sensor_vehicule = 1;
        #20 password_input = 16'b0011_0111_0110_0001; // Contrasenia correcta
        #20 sensor_vehicule = 1;
        #20 sensor_moved_vehicule = 1; //Se mueve vehiculo
        #20 sensor_moved_vehicule = 0; //Ya no se mueve vehiculo
        #20 sensor_vehicule = 0; //Ya no hay vehiculo

        // Prueba 3: Ingreso de clave incorrecta 3 veces
        #20 sensor_vehicule = 1; //Llega vehiculo
        #20 password_input = 16'b0001_0010_0011_0101; // constrasenia incorrecta
        #20 sensor_vehicule = 1;
        #20 sensor_vehicule = 1;
        #20 password_input = 16'b0001_0010_0011_0100; // constrasenia incorrecta
        #20 sensor_vehicule = 1;
        #20 sensor_vehicule = 1;
        #20 password_input = 16'b0001_0011_0110_1000; // constrasenia incorrecta
        
        // Prueba 4: Activación simultánea de ambos sensores
        #60 sensor_vehicule = 1; sensor_moved_vehicule = 1;
        #50 sensor_vehicule = 1;
        #20 rst = 1;//Se activa el reset
        #20 rst = 0;
        #20 sensor_moved_vehicule = 0;
        //Se prueba de nuevo el funcionamiento del sistema
        #20 sensor_vehicule = 1; //Llega vehiculo
        #30 password_input = 16'b0011_0111_0110_0001; //Ingreso contrasenia correcta
        #20 sensor_moved_vehicule = 1;//Vehiculo se mueve
        #20 sensor_moved_vehicule = 0;//Vehiculo ya no se mueve
        #20 sensor_vehicule = 0;//Ya no hay vehiculo
        #20 $finish;

    end
endmodule