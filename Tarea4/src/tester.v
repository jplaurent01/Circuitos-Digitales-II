
module tester_generador(
    output reg clk,
    output reg rst,
    output reg START_STB,
    output reg RNW,
    output reg [6:0] I2C_ADDR,
    output reg [15:0] WR_DATA_INPUT,
    output reg [15:0] RD_DATA_INPUT
);

    // Generación de la señal de reloj (clk) con un período de 20 unidades de tiempo
    always begin
        #10 clk = ~clk;
    end

    initial begin
        // Inicializar señales
        clk = 0;
        rst = 0;
        START_STB = 0;
        RNW = 0;
        I2C_ADDR = 7'b0111101; // Dirección I2C, 61
        WR_DATA_INPUT = 16'h1234;
        RD_DATA_INPUT = 16'h5678;

        // Esperar para desactivar el reset
        #25 rst = 1;

        // Simular una transacción de escritura
        #50 START_STB = 1; RNW = 0; // Iniciar escritura
        #20 START_STB = 0; // Finalizar la señal START_STB

        // Simular una transacción de lectura
        #2200 START_STB = 1; RNW = 1; // Iniciar lectura
        #20 START_STB = 0;

        // Terminar la simulación
        #2200 $finish;
    end
endmodule
