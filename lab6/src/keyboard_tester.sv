// -----------------------------------------------------------------------------
// Universidade Federal do Recôncavo da Bahia
// -----------------------------------------------------------------------------
// Author : joaocarlos joaocarlos@ufrb.edu.br
// File   : keyboard_tester.sv
// Create : 2019-09-19 09:23:52
// Editor : Visual Studio Code, tab size (3)
// -----------------------------------------------------------------------------
// Module Purpose:
//    Interface top level de uma placa FPGA DE2-115 para teste do teclado PS/2
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
`default_nettype none

module keyboard_tester
   (
   //////////////////////	Clock Input	 	/////////////////////////////////////// 
   input 	wire 		CLOCK_50, 			//	50 MHz
   //////////////////////	 Push Button   ///////////////////////////////////////
   input	 	wire [3:0]	KEY, 					//	Pushbutton[3:0]
   //////////////////////	 PS/2 Serial   ///////////////////////////////////////
   input	 	wire 	 	PS2_CLK, 			//	PS/2 Clock
   input	 	wire 	 	PS2_DAT, 			//	PS/2 Data
   //////////////////////	7-SEG Display  ///////////////////////////////////////
   output 	logic [6:0]	HEX0, 				// Display de 7-segmentos (HEX0)
   output 	logic [6:0] HEX1, 				// Display de 7-segmentos (HEX1)
   output 	logic [6:0] HEX2, 				// Display de 7-segmentos (HEX2)
   output 	logic [6:0] HEX3, 				// Display de 7-segmentos (HEX3)
   output 	logic [6:0] HEX4, 				// Display de 7-segmentos (HEX4)
   output 	logic [6:0] HEX5 					// Display de 7-segmentos (HEX5)
   
);

   wire [6:0] segments [0:5];
   wire [31:0] keyb_char;

   PS2_Controller PS2 (
      .CLOCK_50		(CLOCK_50),
      .reset			(~KEY[0]),
      .PS2_CLK			(PS2_CLK),
      .PS2_DAT			(PS2_DAT),
      .received_data	(keyb_char)
   );

   displayNdigit #(.NDIG(4)) display (.clock(CLOCK_50), .value(keyb_char), .segments(segments));
   
   assign HEX0 = segments[0];
   assign HEX1 = segments[1];
   assign HEX2 = segments[2];
   assign HEX3 = segments[3];
   assign HEX4 = segments[4];
   assign HEX5 = segments[5];

endmodule
