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
module booth_m(x, y, product);
parameter group_cnt = 9;
parameter bit_cnt = 16;

input [bit_cnt - 1:0] x;
input [bit_cnt - 1:0] y;
output [(bit_cnt * 2) - 1:0] product;

wire [group_cnt - 1:0]s, d, n;
wire [bit_cnt:0] pp2d[0:group_cnt - 1];
wire [bit_cnt:0] epp2d[0:group_cnt - 1];
wire [31:0] fpp0;
wire [29:0] fpp1;
wire [27:0] fpp2;
wire [25:0] fpp3;
wire [23:0] fpp4;
wire [21:0] fpp5;
wire [19:0] fpp6;
wire [17:0] fpp7;
wire [15:0] fpp8;


genvar i, j;

/****** 1. Partial Product Generation ******/
generate
	for (j = 0; j < group_cnt; j = j + 1) begin
		case (j)
			1'b0: booth_encoder b_e0(.x({x[1], x[0], 1'b0}), .single(s[j]), .double(d[j]), .neg(n[j]));
			4'b1000: booth_encoder b_e2(.x({1'b0, 1'b0, x[bit_cnt - 1]}), .single(s[j]), .double(d[j]), .neg(n[j]));
			default : booth_encoder b_e1(.x({x[2*j + 1], x[2*j], x[2*j -1]}), .single(s[j]), .double(d[j]), .neg(n[j]));

		endcase
		for (i = 0; i < bit_cnt; i = i + 1) begin
			case (i)
			1'b0: begin booth_selector bs(.double(d[j]), .shifted(1'b0), .single(s[j]), .y(y[i]), .neg(n[j]), .p(pp2d[j][i]));
						booth_selector bs1(.double(d[j]), .shifted(y[i]), .single(s[j]), .y(y[i+1]), .neg(n[j]), .p(pp2d[j][i+1]));
			end
			4'b1111: booth_selector bs(.double(d[j]), .shifted(y[i]), .single(s[j]), .y(1'b0), .neg(n[j]), .p(pp2d[j][i+1]));
			default : booth_selector bs(.double(d[j]), .shifted(y[i]), .single(s[j]), .y(y[i+1]), .neg(n[j]), .p(pp2d[j][i+1]));
			endcase
		end
		ripple_carry_adder #(17) rca(.a(pp2d[j]), .b({16'b0000000000000000, n[j]}), .cin(1'b0), .sum(epp2d[j]), .cout());
	end
endgenerate

//booth_encoder b_e0(.x({x[1], x[0], 1'b0}), .single(s[0]), .double(d[0]), .neg(n[0]));
assign fpp0 = {n[0], n[0], n[0], epp2d[0]};


//booth_encoder b_e1(.x({x[3], x[2], x[1]}), .single(s[1]), .double(d[1]), .neg(n[1]));
assign fpp1 = {n[1], epp2d[1]};

//booth_encoder b_e2(.x({1'b0, 1'b0, x[3]}), .single(s[2]), .double(d[2]), .neg(n[2]));
assign fpp2 = {epp2d[2][3:0]};

assign product[0] = fpp0[0];
assign product[1] = fpp0[1];

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
 
module ripple_carry_adder #(parameter width = 4) (a, b, cin, sum, cout);
input [width - 1:0] a,b;
input cin;
wire [width -1: 0] c;
output [width - 1:0] sum;
output cout;
 
genvar i;
generate
	for (i = 0; i < width; i = i + 1) begin
		case (i)
			1'b0: full_adder fa(.a(a[i]), .b(b[i]),.cin(cin), .sum(sum[i]),.cout(c[i]));
			default : full_adder fa(.a(a[i]), .b(b[i]),.cin(c[i - 1]), .sum(sum[i]),.cout(c[i]));
		endcase
	end
endgenerate

assign cout = c[width - 1];
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
