`include "generador.v"
`include "receptor.v"
//`include "tester.v"

module comunicacion_tb;
    // Señales de interconexión
    reg clk;  // Cambiado a reg
    reg rst;  // Cambiado a reg
    reg START_STB;  // Cambiado a reg
    reg RNW;  // Cambiado a reg
    reg [6:0] I2C_ADDR;  // Cambiado a reg
    reg [15:0] WR_DATA_INPUT;  // Cambiado a reg
    wire [15:0] WR_DATA_OUTPUT;  // Cambiado a wire
    wire SDA_IN;  // Permanece como wire
    wire SDA_OE;
    wire SCL;
    wire SDA_OUT;
    reg [15:0] RD_DATA_INPUT;  // Cambiado a reg
    wire [15:0] RD_DATA_OUTPUT;  // Cambiado a wire



    // Creación del archivo VCD para análisis en GTKWave
    initial begin
        $dumpfile("resultados_generador.vcd");
        $dumpvars(0, comunicacion_tb);
    end

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
        WR_DATA_INPUT = 16'h1234;
        RD_DATA_INPUT = 16'h1111;

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
        #10000 $finish;
    end

    // Instancia del módulo generador de transacciones I2C
    generador_transacciones U0 (
        .clk(clk),
        .rst(rst),
        .START_STB(START_STB),
        .RNW(RNW),
        .I2C_ADDR(I2C_ADDR),
        .SDA_IN(SDA_IN),
        .WR_DATA(WR_DATA_INPUT),
        .SDA_OE(SDA_OE),
        .SCL(SCL),
        .SDA_OUT(SDA_OUT),
        .RD_DATA(RD_DATA_OUTPUT)
    );

    receptor_transacciones U1(
        .clk_receptor(clk),
        .rst_receptor(rst),
        .I2C_ADDR_receptor(I2C_ADDR),
        .SCL(SCL),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),
        .SDA_IN(SDA_IN),
        .WR_DATA_receptor(WR_DATA_OUTPUT),
        .RD_DATA_receptor(RD_DATA_INPUT)
    );

/*
    // Instancia del módulo tester
    tester_generador T0 (
        .clk(clk),
        .rst(rst),
        .START_STB(START_STB),
        .RNW(RNW),
        .I2C_ADDR(I2C_ADDR),
        .SDA_IN(SDA_IN),
        .WR_DATA(WR_DATA),
        .SDA_OE(SDA_OE),
        .SCL(SCL),
        .SDA_OUT(SDA_OUT),
        .RD_DATA(RD_DATA)
    );
*/

endmodule

