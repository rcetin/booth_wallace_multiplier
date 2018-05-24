`timescale 1ps / 1fs

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
	reg [15:0] x;
	reg [15:0] y;

	// Outputs
	wire [31:0] product;

	// Instantiate the Unit Under Test (UUT)
	booth_m uut (
		.x(x), 
		.y(y), 
		.product(product)
	);

	initial begin
$display($time, " << Starting the Simulation >>");
#500 x= 16'b1000111010011111; y=16'b1100110001111100; 
end
      
initial
$monitor("time=%.3f ps, x=%b, y=%b, product=%b\n",$realtime,x,y,product);
endmodule
