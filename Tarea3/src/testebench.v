`include "cajeroAutomatico.v"
`include "tester.v"

module cajero_automatico_tb;
    // Seniales para conectar el tester con el DUT
    wire clk;
    wire rst;
    wire TARJETA_RECIBIDA;
    wire TIPO_TRANS;
    wire MONTO_STB;
    wire DIGITO_STB;
    wire [3:0] DIGITO;
    wire [15:0] PIN;
    wire [31:0] MONTO;
    wire [63:0] BALANCE_INICIAL;
    wire BALANCE_ACTUALIZADO;
    wire ENTREGAR_DINERO;
    wire PIN_INCORRECTO;
    wire ADVERTENCIA;
    wire BLOQUEO;
    wire FONDOS_INSUFICIENTES;

    // Archivo para guardar la simulación
    initial begin
        $dumpfile("resultados_cajero_automatico.vcd");
        $dumpvars(-1, U0);
    end

    // Instancia del módulo cajero_automatico (DUT)
    cajero_automatico U0 (
        .clk(clk),
        .rst(rst),
        .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
        .TIPO_TRANS(TIPO_TRANS),
        .MONTO_STB(MONTO_STB),
        .DIGITO_STB(DIGITO_STB),
        .DIGITO(DIGITO),
        .PIN(PIN),
        .MONTO(MONTO),
        .BALANCE_INICIAL(BALANCE_INICIAL),
        .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
        .ENTREGAR_DINERO(ENTREGAR_DINERO),
        .PIN_INCORRECTO(PIN_INCORRECTO),
        .ADVERTENCIA(ADVERTENCIA),
        .BLOQUEO(BLOQUEO),
        .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES)
    );

    // Instancia del módulo tester
    tester T0 (
        .clk(clk),
        .rst(rst),
        .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
        .TIPO_TRANS(TIPO_TRANS),
        .MONTO_STB(MONTO_STB),
        .DIGITO_STB(DIGITO_STB),
        .DIGITO(DIGITO),
        .PIN(PIN),
        .MONTO(MONTO),
        .BALANCE_INICIAL(BALANCE_INICIAL),
        .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
        .ENTREGAR_DINERO(ENTREGAR_DINERO),
        .PIN_INCORRECTO(PIN_INCORRECTO),
        .ADVERTENCIA(ADVERTENCIA),
        .BLOQUEO(BLOQUEO),
        .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES)
    );
endmodule
