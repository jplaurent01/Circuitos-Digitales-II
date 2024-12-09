/*
Circuitos Digitales #2 - Proyecto
Heiner Mauricio Obando - B55130
Henry Fabricio Salazar - B87179
Jose Pablo Laurent - B63761
Profesor: Enrique Coen Alfaro
*/

module Synchronizer(sync_clk, mr_main_reset, rx_code_group, code_sync_status, rx_even, SUDI, code_group, existence);

// Senales de entrada del modulo
input sync_clk;
input mr_main_reset;
input [9:0] rx_code_group;
input existence; // Entrada recibida de la rom que indica si el code_group recibido es un dato valido

// Senales de salida del modulo
output reg code_sync_status;
output reg rx_even;
output reg [9:0] SUDI; // Code_group que se envia al receptor
output reg [9:0] code_group; // Code_group que se envia a la rom para ser revisado

// Parametros para ingresar a los diferentes estados en el case
localparam LOSS_OF_SYNC = 9'b000000001; // Estado 1
localparam COMMA_DETECT_1 = 9'b000000010; // Estado 2
localparam ACQUIRE_SYNC_1 = 9'b000000100; // Estado 4
localparam COMMA_DETECT_2 = 9'b000001000; // Estado 8
localparam ACQUIRE_SYNC_2 = 9'b000010000; // Estado 16
localparam COMMA_DETECT_3 = 9'b000100000; // Estado 32
localparam SYNC_ACQUIRED_1 = 9'b001000000; // Estado 64
localparam SYNC_ACQUIRED_2 = 9'b010000000; // Estado 128
localparam SYNC_ACQUIRED_2A = 9'b100000000; // Estado 256

// Variables internas del controlador para el manejo de condiciones y estados
reg [8:0] state_sync, nxt_state_sync; 
reg nxt_rx_even;
reg VALID;
reg [1:0] good_cgs, nxt_good_cgs;
assign COMMA = ((rx_code_group == 10'b0011111010 || rx_code_group == 10'b1100000101)); // Condicion para detectar la COMMA
assign DATA = ((rx_code_group == 10'b0110110101) || rx_code_group == (10'b1001000101)); // Condicion para detectar datos validos

// Se Definen todos los flip flops de la maquina de estados, logica secuencial
always @(posedge sync_clk) begin
    if (~mr_main_reset) begin 
        state_sync <= LOSS_OF_SYNC;
        rx_even <= 0;
        good_cgs <= 0;
        code_sync_status = 0;
    end else begin
        state_sync <= nxt_state_sync; 
        rx_even <= nxt_rx_even;
        good_cgs <= nxt_good_cgs;
    end
end

// Se define logica combinacional del sistema
always @(*) begin

    nxt_state_sync = state_sync;
    nxt_rx_even = !rx_even;
    nxt_good_cgs = good_cgs;
    SUDI = rx_code_group;
    code_group = rx_code_group;
    VALID = existence;

    case (state_sync)

        /*
          Estado inicial se sale de este al 
          momento de detectar la COMMA
        */
        LOSS_OF_SYNC: begin
            code_sync_status = 0;
            if (COMMA) begin
                nxt_state_sync = COMMA_DETECT_1;
                nxt_rx_even = 1;
            end else begin 
                nxt_state_sync = LOSS_OF_SYNC;
            end
        end

        /*
          Estado 2: Se sale de este al recibir
          el dato D16.2, de lo contrario se
          devuelve al primer estado
        */
        COMMA_DETECT_1: begin
            if (DATA) begin
                nxt_state_sync = ACQUIRE_SYNC_1;
            end else begin
                nxt_state_sync = LOSS_OF_SYNC;
            end
        end
    
        /*
          Estado 4: Se avanza al siguiente estado
          al recibir una COMMA en rx_even impar,
          si se recibe un dato valido pero que
          no es COMMA se mantiene en el estado
          y si es un dato no valido se devuelve
          al primer estado.
        */
        ACQUIRE_SYNC_1: begin
            if ((!rx_even) && (COMMA)) begin
                nxt_state_sync = COMMA_DETECT_2;
                nxt_rx_even = 1;
            end else if ((!COMMA) && VALID) begin
                nxt_state_sync = ACQUIRE_SYNC_1;
            end else if (!VALID)
                nxt_state_sync = LOSS_OF_SYNC;
        end

        /*
          Estado 8: Se sale de este al recibir
          el dato D16.2, de lo contrario se
          devuelve al primer estado
        */
        COMMA_DETECT_2: begin
            if (DATA) begin
                nxt_state_sync = ACQUIRE_SYNC_2;
            end else begin
                nxt_state_sync = LOSS_OF_SYNC;
            end
        end

        /*
          Estado 16: Se avanza al siguiente estado
          al recibir una COMMA en rx_even impar,
          si se recibe un dato valido pero que
          no es COMMA se mantiene en el estado
          y si es un dato no valido se devuelve
          al primer estado.
        */
        ACQUIRE_SYNC_2: begin
            if ((!rx_even) && (COMMA)) begin
                nxt_state_sync = COMMA_DETECT_3;
                nxt_rx_even = 1;
            end else if ((!COMMA) && VALID) begin
                nxt_state_sync = ACQUIRE_SYNC_2;
            end else if (!VALID)
                nxt_state_sync = LOSS_OF_SYNC;
        end

        /*
          Estado 32: Se sale de este al recibir
          el dato D16.2, de lo contrario se
          devuelve al primer estado
        */
        COMMA_DETECT_3: begin
            if (DATA) begin
                nxt_state_sync = SYNC_ACQUIRED_1;
            end else begin
                nxt_state_sync = LOSS_OF_SYNC;
            end
        end

        /*
          Estado 64: La maquina ya esta sincronizada
          se mantiene en el estado mientras se reciban
          datos validos
        */
        SYNC_ACQUIRED_1: begin
            code_sync_status = 1;
            if (VALID) begin
                nxt_state_sync = SYNC_ACQUIRED_1;
            end else begin
                nxt_state_sync = SYNC_ACQUIRED_2;
            end
        end

        /*
          Estado 128: Si se recibe un dato valido
          pasa al siguiente estado para mantener 
          sincronizacion, si se recibe dato inva-
          lido el se va a primer estado
        */
        SYNC_ACQUIRED_2: begin
            if (VALID) begin
                nxt_state_sync = SYNC_ACQUIRED_2A;
                nxt_good_cgs = good_cgs + 1;
            end else begin
                nxt_state_sync = LOSS_OF_SYNC;
            end
        end

        /*
          Estado 256: Si el contador de datos validos
          recibidos llega a 2 (es decir se recibieron 3
          datos validos seguidos) se vuelve al estado 64,
          donde se mantiene sincronizacion.
        */
        SYNC_ACQUIRED_2A: begin
            if (VALID && good_cgs == 2) begin
                nxt_state_sync = SYNC_ACQUIRED_1;
            end else if (VALID) begin
                nxt_good_cgs = good_cgs + 1;
                nxt_state_sync = SYNC_ACQUIRED_2A;    
            end else if (!VALID) begin
                nxt_state_sync = LOSS_OF_SYNC;
            end

        end
    endcase
end
endmodule