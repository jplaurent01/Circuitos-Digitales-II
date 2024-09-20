`include "controlador_RTLIL.v"
`include "tester_sin_retardos.v"

module controlador_estacionamiento_tb;
//Seniales para conectar el tester con el device under teste
    wire clk;
    wire rst;
    wire sensor_vehicule;
    wire sensor_moved_vehicule;
    wire [15:0] password_input;
    wire open_gate;
    wire close_gate;
    wire alarm_wrong_pin;
    wire alarm_blocked;

    //Clave correcta 3761
    //wire [15:0] correct_password = 16'b0011_0111_0110_0001;
    
    //Se crea un archivo resultados.vcd para abrir en gtkwave con las varibales del controlador de estacionamientos
    initial begin
        $dumpfile("resultados_RTLIL.vcd");
        $dumpvars(-1, U0);
    end

    // Instancia del modulo controlador, //Clave correcta 3761 16'b0011_0111_0110_0001
    controlador_estacionamiento  U0 (
        .clk(clk),
        .rst(rst),
        .sensor_vehicule(sensor_vehicule),
        .sensor_moved_vehicule(sensor_moved_vehicule),
        .password_input(password_input),
        //.correct_password(correct_password),
        .open_gate(open_gate),
        .close_gate(close_gate),
        .alarm_wrong_pin(alarm_wrong_pin),
        .alarm_blocked(alarm_blocked)
    );
    
    // Instancia del modulo tester
    tester T0 (
        .clk(clk),
        .rst(rst),
        .sensor_vehicule(sensor_vehicule),
        .sensor_moved_vehicule(sensor_moved_vehicule),
        .password_input(password_input),
        //.correct_password(correct_password),
        .open_gate(open_gate),
        .close_gate(close_gate),
        .alarm_wrong_pin(alarm_wrong_pin),
        .alarm_blocked(alarm_blocked)
    );
endmodule
