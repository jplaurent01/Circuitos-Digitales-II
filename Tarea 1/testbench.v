`include "controlador.v"
`include "tester.v"

module controlador_estacionamiento_tb;
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
    wire [15:0] correct_password = 16'b0011_0111_0110_0001;
    

    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(-1, U0);
    end

    // Instancia del módulo controlador
    controlador_estacionamiento U0 (
        .clk(clk),
        .rst(rst),
        .sensor_vehicule(sensor_vehicule),
        .sensor_moved_vehicule(sensor_moved_vehicule),
        .password_input(password_input),
        .correct_password(correct_password),
        .open_gate(open_gate),
        .close_gate(close_gate),
        .alarm_wrong_pin(alarm_wrong_pin),
        .alarm_blocked(alarm_blocked)
    );
    
    // Instancia del módulo tester
    tester T0 (
        .clk(clk),
        .rst(rst),
        .sensor_vehicule(sensor_vehicule),
        .sensor_moved_vehicule(sensor_moved_vehicule),
        .password_input(password_input),
        .correct_password(correct_password),
        .open_gate(open_gate),
        .close_gate(close_gate),
        .alarm_wrong_pin(alarm_wrong_pin),
        .alarm_blocked(alarm_blocked)
    );
endmodule

/*
module controlador_estacionamiento_tb;
    //reg clk;
    //reg rst;
    //reg sensor_vehicule;
    //reg sensor_moved_vehicule;
    //reg [15:0] password_input;
    wire clk;
    wire rst;
    wire sensor_vehicule;
    wire sensor_moved_vehicule;
    wire [15:0] password_input;
    reg open_gate;
    reg close_gate;
    reg alarm_wrong_pin;
    reg alarm_blocked;
    
    //Clave correcta 3761
    wire [15:0] correct_password = 16'b0011_0111_0110_0001;
    

    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(-1, U0);
    end

    // Instancia del módulo controlador
    controlador_estacionamiento U0 (
        .clk(clk),
        .rst(rst),
        .sensor_vehicule(sensor_vehicule),
        .sensor_moved_vehicule(sensor_moved_vehicule),
        .password_input(password_input),
        .correct_password(correct_password),
        .open_gate(open_gate),
        .close_gate(close_gate),
        .alarm_wrong_pin(alarm_wrong_pin),
        .alarm_blocked(alarm_blocked)
    );
    
    // Instancia del módulo tester
    tester T0 (
        .clk(clk),
        .rst(rst),
        .sensor_vehicule(sensor_vehicule),
        .sensor_moved_vehicule(sensor_moved_vehicule),
        .password_input(password_input),
        .correct_password(correct_password),
        .open_gate(open_gate),
        .close_gate(close_gate),
        .alarm_wrong_pin(alarm_wrong_pin),
        .alarm_blocked(alarm_blocked)
    );
    endmodule
    // Generación del reloj
    //initial begin
    //    clk = 0;
    //    forever #5 clk = ~clk;
    //end
    
    // Secuencia de prueba
    //initial begin
        // Abre el archivo VCD
    //    $dumpfile("simulation.vcd"); // Nombre del archivo VCD
    //    $dumpvars(0, controlador_estacionamiento_tb);      // Volcado de todas las variables del módulo testbench
        // Reset del sistema
    //    rst = 1; sensor_vehicule = 0; sensor_moved_vehicule = 0; password_input = 0;
    //    #10 rst = 0;

        // Prueba 1: Ingreso de clave correcta
    //    #10 sensor_vehicule = 1;
    //    #20 password_input = 16'b0010_0100_0110_1000; // 2468 en BCD
    //    #10 sensor_moved_vehicule = 1;
    //    #10 sensor_moved_vehicule = 0;
        
    //     #10 sensor_vehicule = 0;
        // Prueba 2: Ingreso de clave incorrecta menos de 3 veces
    //    #10 sensor_vehicule = 1;
    //    #10 password_input = 16'b0001_0010_0011_0101; // 1235 en BCD
        //#10 sensor_vehicule = 0;
    //    #10 sensor_vehicule = 1;
    //    #10 password_input = 16'b0001_0010_0011_0100; // 1234 en BCD
        //#10 sensor_vehicule = 0;
    //    #10 sensor_vehicule = 1;
    //    #10 password_input = 16'b0010_0100_0110_1000; // 2468 en BCD
    //    #10 sensor_vehicule = 1;
    //    #10 sensor_moved_vehicule = 1;
    //    #10 sensor_moved_vehicule = 0;
    //    #10 sensor_vehicule = 0;

        // Prueba 3: Ingreso de clave incorrecta 3 veces
    //    #10 sensor_vehicule = 1;
    //    #10 password_input = 16'b0001_0010_0011_0101; // 1235 en BCD
    //    #10 sensor_vehicule = 1;
    //    #10 sensor_vehicule = 1;
    //    #10 password_input = 16'b0001_0010_0011_0100; // 1234 en BCD
    //    #10 sensor_vehicule = 1;
    //    #10 sensor_vehicule = 1;
    //    #10 password_input = 16'b0001_0011_0110_1000; // 1368 en BCD
        
        // Prueba 4: Activación simultánea de ambos sensores
    //    #50 sensor_vehicule = 1; sensor_moved_vehicule = 1;
        
    //    #50 $finish;
    //end
//endmodule
*/