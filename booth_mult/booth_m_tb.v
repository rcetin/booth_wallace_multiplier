`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:15:07 05/20/2018
// Design Name:   booth_m
// Module Name:   /home/rcetin/workspace/ISE_workspace/booth_mult/booth_m_tb.v
// Project Name:  booth_mult
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: booth_m
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module booth_m_tb;

	// Inputs
	reg [3:0] x;
	reg [3:0] y;

	// Outputs
	wire [7:0] p;

	// Instantiate the Unit Under Test (UUT)
	booth_m uut (
		.x(x), 
		.y(y), 
		.p(p)
	);

	initial begin
		// Initialize Inputs
		x = 0;
		y = 0;

		// Wait 100 ns for global reset to finish
		#100;
      
		x = 4'b1000; y = 4'b1100;
		// Add stimulus here

	end
      
endmodule

