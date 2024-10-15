module tester_generador (
    output reg clk,
    output reg rst,
    output reg START_STB,
    output reg RNW,
    output reg [6:0] I2C_ADDR,
    output reg SDA_IN,
    output reg [15:0] WR_DATA,
    input wire SDA_OE,
    input wire SCL,
    input wire SDA_OUT,
    input wire [15:0] RD_DATA
);

    // Generación de la señal de reloj (clk) con un período de 20 unidades de tiempo
    always begin
        #10 clk = ~clk;
    end

    initial begin
        // Inicializar señales
        clk = 0;
        rst = 1;
        START_STB = 0;
        RNW = 0;
        //SDA_IN = 1;
        I2C_ADDR = 7'b0111101; // Dirección I2C
        WR_DATA = 16'h1234;

        // Esperar para desactivar el reset
        #25 rst = 0;

        // Simular una transacción de escritura
        #50 START_STB = 1; RNW = 0; // Iniciar escritura
        // Enviar cada bit de I2C_ADDR a SDA_IN
        #50 START_STB = 0; // Finalizar la señal START_STB
        
        // Simular una transacción de lectura
        //#100 START_STB = 1; RNW = 1; // Iniciar lectura
        // Enviar cada bit de I2C_ADDR a SDA_IN de nuevo (si es necesario)
        //#50 START_STB = 0; // Finalizar la señal START_STB
        
        //#25 rst = 1; // Reiniciar para finalizar

        // Terminar la simulación
        #1000 $finish;
    end
endmodule

