`include "generador.v"
`include "receptor.v"
`include "tester.v"

module comunicacion_tb;
    // Señales de interconexión
    wire clk;
    wire rst;
    wire START_STB;
    wire RNW;
    wire [6:0] I2C_ADDR;
    wire SDA_IN;
    wire [15:0] WR_DATA;
    wire SDA_OE;
    wire SCL;
    wire SDA_OUT;
    wire [15:0] RD_DATA;

    // Instancia del módulo generador de transacciones I2C
    generador_transacciones U0 (
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

    receptor_transacciones U1(
        .clk_receptor(clk),
        .rst_receptor(rst),
        .I2C_ADDR_receptor(I2C_ADDR),
        .SCL(SCL),
        .SDA_OUT(SDA_OUT),
        .SDA_OE(SDA_OE),
        .SDA_IN(SDA_IN),
        .WR_DATA_receptor(WR_DATA),
        .RD_DATA_receptor(RD_DATA)
    );

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

    // Creación del archivo VCD para análisis en GTKWave
    initial begin
        $dumpfile("resultados_generador.vcd");
        $dumpvars(0, comunicacion_tb);
    end
endmodule

