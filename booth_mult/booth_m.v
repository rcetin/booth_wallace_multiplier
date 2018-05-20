`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:53 05/19/2018 
// Design Name: 
// Module Name:    booth_m 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module booth_m(x, y, p);
input [3:0]x;
input [3:0]y;
output [7:0]p;

wire [2:0]s, d, n;
wire [4:0] pp2d[0:2];
wire [4:0]pp0, pp1, pp2;
wire [4:0] epp2d[0:2];
wire [7:0] fpp0;
wire [5:0] fpp1;
wire [3:0] fpp2;

genvar i, j;

/****** 1. Partial Product Generation ******/
generate
	for (j = 0; j < 3; j = j + 1) begin
		for (i = 0; i < 4; i = i + 1) begin
			case (i)
			1'b0: begin booth_selector bs(.double(d[j]), .shifted(1'b0), .single(s[j]), .y(y[i]), .neg(n[j]), .p(pp2d[j][i]));
						booth_selector bs1(.double(d[j]), .shifted(y[i]), .single(s[j]), .y(y[i+1]), .neg(n[j]), .p(pp2d[j][i+1]));
			end
			2'b11: booth_selector bs(.double(d[j]), .shifted(y[i]), .single(s[j]), .y(1'b0), .neg(n[j]), .p(pp2d[j][i+1]));
			default : booth_selector bs(.double(d[j]), .shifted(y[i]), .single(s[j]), .y(y[i+1]), .neg(n[j]), .p(pp2d[j][i+1]));
			endcase
		end
		ripple_carry_5_bit rca0(.a(pp2d[j]), .b({4'b0000, n[j]}), .cin(1'b0), .sum(epp2d[j]), .cout());
	end
endgenerate

booth_encoder b_e0(.x({x[1], x[0], 1'b0}), .single(s[0]), .double(d[0]), .neg(n[0]));
assign fpp0 = {n[0], n[0], n[0], epp2d[0]};


booth_encoder b_e1(.x({x[3], x[2], x[1]}), .single(s[1]), .double(d[1]), .neg(n[1]));
assign fpp1 = {n[1], epp2d[1]};

booth_encoder b_e2(.x({1'b0, 1'b0, x[3]}), .single(s[2]), .double(d[2]), .neg(n[2]));
assign fpp2 = {epp2d[2][3:0]};
endmodule

/* Booth Encoder */
module booth_encoder (x, single, double, neg);
input [2:0]x;
output single, double, neg;

wire notx0, notx1, notx2, w0, w1;
not(notx0, x[0]);
not(notx1, x[1]);
not(notx2, x[2]);

xor xor0(single, x[0], x[1]);
assign neg = x[2];
assign w0 = x[0] & x[1] & notx2;
assign w1 = notx0 & notx1 & x[2];
or or0(double, w0, w1);
endmodule

module booth_selector (double, shifted, single, y, neg, p);
input double, shifted, single, y, neg;
output p;

assign p = (neg ^ ((y & single) | (shifted & double)));

endmodule

////////////////////////////////////
//4-bit Ripple Carry Adder
////////////////////////////////////
 
module ripple_carry_5_bit(a, b, cin, sum, cout);
input [4:0] a,b;
input cin;
wire c1,c2,c3,c4;
output [4:0] sum;
output cout;
 
full_adder fa0(.a(a[0]), .b(b[0]),.cin(cin), .sum(sum[0]),.cout(c1));
full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1), .sum(sum[1]),.cout(c2));
full_adder fa2(.a(a[2]), .b(b[2]), .cin(c2), .sum(sum[2]),.cout(c3));
full_adder fa3(.a(a[3]), .b(b[3]), .cin(c3), .sum(sum[3]),.cout(c4));
full_adder fa4(.a(a[4]), .b(b[4]), .cin(c4), .sum(sum[4]),.cout(cout));
endmodule
 
//////////////////////////////
//1bit Full Adder
/////////////////////////////
module full_adder(a,b,cin,sum, cout);
input a,b,cin;
output sum, cout;
wire x,y,z;
half_adder h1(.a(a), .b(b), .sum(x), .cout(y));
half_adder h2(.a(x), .b(cin), .sum(sum), .cout(z));
or or_1(cout,z,y);
endmodule
 
///////////////////////////
// 1 bit Half Adder
//////////////////////////
module half_adder( a,b, sum, cout );
input a,b;
output sum, cout;
xor xor_1 (sum,a,b);
and and_1 (cout,a,b);
endmodule
