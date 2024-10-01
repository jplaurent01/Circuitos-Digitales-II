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
        //#30;

        // Simulación de seleccionar deposito (TIPO_TRANS = 0) y monto
        #10 TIPO_TRANS = 0; MONTO = 32'd2000; MONTO_STB = 1;
        #20 MONTO_STB = 0;

        // Espera para procesar el retiro
        #50;

        // Simulación de insertar un PIN incorrecto
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
        
        // Verificar que el sistema se bloquee después del tercer intento
        #50;

        // Fin de la simulación
        #500 $finish;
    end

endmodule
