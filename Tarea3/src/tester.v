module tester(
    output reg clk,
    output reg rst,
    output reg TARJETA_RECIBIDA,
    output reg TIPO_TRANS,
    output reg MONTO_STB,
    output reg DIGITO_STB,
    output reg [3:0] DIGITO,
    output reg [15:0] PIN,
    output reg [31:0] MONTO,
    output reg [63:0] BALANCE_INICIAL,
    input wire BALANCE_ACTUALIZADO,
    input wire ENTREGAR_DINERO,
    input wire PIN_INCORRECTO,
    input wire ADVERTENCIA,
    input wire BLOQUEO,
    input wire FONDOS_INSUFICIENTES
);

    // Generación de señal de reloj (clk)
    initial clk = 0;
    always #5 clk = ~clk; // Reloj de periodo 10 unidades de tiempo

    // Proceso de pruebas
    // Inicialización de señales
    initial begin
        // Reset inicial
        rst = 1;
        TARJETA_RECIBIDA = 0;
        TIPO_TRANS = 0;
        MONTO_STB = 0;
        DIGITO_STB = 0;
        DIGITO = 0;
        PIN = 16'b0011_0111_0110_0001; // PIN correcto: 3761
        MONTO = 0;
        BALANCE_INICIAL = 64'd10000; // Balance inicial: 10,000
        #10 rst = 0;

        /*************************************** prueba #1 ********************************************************
        Se ingresa un BALANCE_INICIAL de 10 000, se ingresa el pin 3761, se ingresan los digitos
        3,7,6,1, se realiza un deposito MONTO = 2000, por lo que BALANCE = 12 000 y se espera poner en 1 las
        senial BALANCE_ACTUALIZADO = 1. */

        // Simulación de insertar tarjeta
        #10 TARJETA_RECIBIDA = 1;
        // Simulación de ingreso de PIN correcto
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd7; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd6; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        // Espera para verificar el PIN
        #5;
        // Simulación de seleccionar deposito (TIPO_TRANS = 0) y monto
        #10 TIPO_TRANS = 0; MONTO = 32'd2000; MONTO_STB = 1; //Monto 2000
        #15 MONTO_STB = 0; //Se duplica el tiempo de esta senial
        // Espera para procesar el deposito
        #50;
        //************************************** Fin prueba #1 ********************************************************

        /************************************** prueba #2 ********************************************************
        Se ingresa un BALANCE_INICIAL de 10 000, se ingresa el pin 3761, se ingresan los digitos
        3,7,6,1, se realiza un retiro MONTO = 2000, por lo que BALANCE = 8000 y se espera poner en 1 las
        senial BALANCE_ACTUALIZADO = 1 y  ENTREGAR_DINERO = 1. */

        // Simulación de insertar tarjeta
        #10 TARJETA_RECIBIDA = 1;
        // Simulación de ingreso de PIN correcto
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd7; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd6; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        // Espera para verificar el PIN
        #5;
        // Simulación de seleccionar retiro (TIPO_TRANS = 1) y monto
        #10 TIPO_TRANS = 1; MONTO = 32'd2000; MONTO_STB = 1; //Monto 2000
        #15 MONTO_STB = 0; //Se duplica el tiempo de esta senial
        // Espera para procesar el retiro
        #50;
        //************************************** Fin prueba #2 ********************************************************

        
        /*************************************** prueba #3 ********************************************************
        Se ingresa un BALANCE_INICIAL de 0, se ingresa el pin 3761, se ingresan los digitos
        3,7,6,1, se realiza un retiro MONTO = 2000, por lo que FONDOS_INSUFICIENTES = 1.*/

        #10 BALANCE_INICIAL = 64'd00000; // Balance inicial: 10,000
        // Simulación de insertar tarjeta
        #10 TARJETA_RECIBIDA = 1;
        // Simulación de ingreso de PIN correcto
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd7; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd6; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        // Espera para verificar el PIN
        #5;
        // Simulación de seleccionar retiro (TIPO_TRANS = 1) y monto
        #10 TIPO_TRANS = 1; MONTO = 32'd2000; MONTO_STB = 1; //Monto 2000
        #15 MONTO_STB = 0; //Se duplica el tiempo de esta senial
        // Espera para procesar el retiro
        #50;
        //************************************** Fin prueba #3 ********************************************************

        /************************************** prueba #4 ********************************************************
        En este prueba se ingresan tres veces pines erroneos para activar señales de PIN_INCORRECTO, ADVERTENCIA y BLOQUEO.*/

        //Pin incorrecto #1
        #100 rst = 1; #10 rst = 0; // Resetear para la siguiente prueba
        #20 TARJETA_RECIBIDA = 1;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;

        // Espera para verificar el PIN incorrecto
        #30;

        // Simulación de repetir PIN incorrecto dos veces más
        #50;
        #20 DIGITO = 4'd2; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd2; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd2; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd2; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        // Verificar que el sistema se bloquee después del tercer intento
        #50;
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        //************************************** Fin prueba #4 ********************************************************
        
        /************************************** prueba #5 ********************************************************
        En este prueba se activa la señal de RESET para desactivar el estado de bloqueo y reiniciar el cajero
        Luego se realiza un intento incorrecto del pin y luego otro intento correcto del pin para realizar un retiro*/
        #50 rst = 1;
        #10 rst = 0;
        #10 BALANCE_INICIAL = 64'd10000; // Balance inicial: 10,000
        //Pin incorrecto #1
        #20 TARJETA_RECIBIDA = 1;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;

        // Espera para verificar el PIN incorrecto
        #30;

        // Simulación de ingreso de PIN correcto
        #20 DIGITO = 4'd3; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd7; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd6; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        #20 DIGITO = 4'd1; DIGITO_STB = 1;
        #10 DIGITO_STB = 0;
        // Espera para verificar el PIN
        #5;
        
        // Simulación de seleccionar retiro (TIPO_TRANS = 1) y monto
        #10 TIPO_TRANS = 1; MONTO = 32'd2000; MONTO_STB = 1; //Monto 2000
        #15 MONTO_STB = 0; //Se duplica el tiempo de esta senial
        // Espera para procesar el deposito
        #50;

        // Fin de la simulación
        #100 $finish;
    end

endmodule
