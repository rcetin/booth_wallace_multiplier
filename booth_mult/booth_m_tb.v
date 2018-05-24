`timescale 1ps / 1fs
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
