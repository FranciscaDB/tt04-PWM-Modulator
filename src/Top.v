`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: Top
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module Top(
    input clk,        // Reloj de entrada proveniente del PLL
    //input CLK_EXT,        // Rloj de entrada que proviene de un PIN
    //input CLK_SELECTOR,   // Selecciona si el reloj viene del PLL (0) o de un PIN externo (1)
    input RST,            // senal de reset 
    
    input [5:0] d1,       // Senal 1 que viene del controlador
    input [5:0] d2,       // Senal 2 que viene del controlador
    
    input [3:0] dt,       // Cantidad de periodos que se quieren de tiempo muerto

    input OUTPUT_SELECTOR,// Selecciona si la salida es interna (0) u offchip (1)

    input PMOS1_EXT,      // pulso de activacion offchip para pmos1
    input PMOS2_EXT,      // pulso de activacion offchip para pmos2
    input NMOS1_EXT,      // pulso de activacion offchip para nmos1
    input NMOS2_EXT,      // pulso de activacion offchip para nmos2

    output wire PMOS1,      // Senal de control del transistor NMOS 1
    output wire NMOS2,      // Senal de control del transistor PMOS 1
    output wire PMOS2,      // Senal de control del transistor NMOS 2
    output wire NMOS1,      // Senal de control del transistor PMOS 2

    output CLK_OUT          // Medicion de CLK
);

/* Clock divider innecesario
Clk_Divider Clk_Divider_Inst(
    .clk_in(clk_in),
    .div_clk0(16'd1), 
    .clk0(clk),
    .rst(RST)
);*/

/**************** ETAPA DE MUX CLK ****************/
//wire clk;
//assign clk = CLK_SELECTOR ? CLK_EXT : CLK_PLL;
assign CLK_OUT= clk;


/**************** ETAPA DE TRIANGULARES ****************/

wire [5:0] triangular_1;
Signal_Generator_1 Signal_Generator_1_Inst(
    .clk(clk),
    .rst(RST),
    .count(triangular_1)
);

wire [5:0] triangular_2;
Signal_Generator_2 Signal_Generator_2_Inst(
    .clk(clk),
    .rst(RST),
    .count(triangular_2)
);

/**************** ETAPA DE COMPARACION ****************/

wire Output_Comparison_1;
Comparator Comparator_Inst_1(
    .in1(d1),
    .in2(triangular_1),
    .comparison(Output_Comparison_1)
);

wire Output_Comparison_2;
Comparator Comparator_Inst_2(
    .in1(d2),
    .in2(triangular_2),
    .comparison(Output_Comparison_2)
);

/**************** ETAPA DE DEAD-TIME GENERATOR ****************/

wire pmos1_int; 
Dead_Time_Generator Dead_Time_Generator_inst_1(
    .clk(clk),
    .dt(dt),
    .gi(Output_Comparison_1),
    .go(pmos1_int)
);

wire Not_Output_Comparison_1;
wire nmos2_int;
assign Not_Output_Comparison_1 = ~Output_Comparison_1;
Dead_Time_Generator Dead_Time_Generator_inst_2(
    .clk(clk),
    .dt(dt),
    .gi(Not_Output_Comparison_1),
    .go(nmos2_int)
);

wire pmos2_int;
Dead_Time_Generator Dead_Time_Generator_inst_3(
    .clk(clk),
    .dt(dt),
    .gi(Output_Comparison_2),
    .go(pmos2_int)
);

wire Not_Output_Comparison_2;
wire nmos1_int;
assign Not_Output_Comparison_2 = ~Output_Comparison_2;
Dead_Time_Generator Dead_Time_Generator_inst_4(
    .clk(clk),
    .dt(dt),
    .gi(Not_Output_Comparison_2),
    .go(nmos1_int)
);

/**************** ETAPA DE MUX OUTPUT ****************/

assign PMOS1 = OUTPUT_SELECTOR ? PMOS1_EXT : ~pmos1_int; // TIENE EL NEGADOR POR EL PMOS
assign NMOS2 = OUTPUT_SELECTOR ? NMOS2_EXT : nmos2_int;
assign PMOS2 = OUTPUT_SELECTOR ? PMOS2_EXT : ~pmos2_int; // TIENE EL NEGADOR POR EL PMOS
assign NMOS1 = OUTPUT_SELECTOR ? NMOS1_EXT : nmos1_int;

endmodule
