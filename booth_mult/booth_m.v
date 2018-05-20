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

assign fpp0 = {n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], n[0], epp2d[0]};
assign fpp1 = {n[1], n[1], n[1], n[1], n[1], n[1], n[1], n[1], n[1], n[1], n[1], n[1], n[1], epp2d[1]};
assign fpp2 = {n[2], n[2], n[2], n[2], n[2], n[2], n[2], n[2], n[2], n[2], n[2], epp2d[2]};
assign fpp3 = {n[3], n[3], n[3], n[3], n[3], n[3], n[3], n[3], n[3], epp2d[3]};
assign fpp4 = {n[4], n[4], n[4], n[4], n[4], n[4], n[4], epp2d[4]};
assign fpp5 = {n[5], n[5], n[5], n[5], n[5], epp2d[5]};
assign fpp6 = {n[6], n[6], n[6], epp2d[6]};
assign fpp7 = {n[7], epp2d[7]};
assign fpp8 = {epp2d[8]};

//assign product[0] = fpp0[0];
//assign product[1] = fpp0[1];

/////////////// STAGE 1 ///////////////////

wire has00, hac00, has01, hac01, has10, has11, has20, has21, hac10, hac11, hac20, hac21;
wire [27:0] fas0, fac0;
wire [21:0] fas1, fac1;
wire [15:0] fas2, fac2;

wire [31:0] st00;
wire [29:0] st01;
wire [25:0] st02;
wire [23:0] st03;
wire [19:0] st04;
wire [17:0] st05;

half_adder ha0s0210(.a(fpp0[2]), .b(fpp1[0]) , .sum(has00), .cout(hac00));
half_adder ha0s0311(.a(fpp0[3]), .b(fpp1[1]) , .sum(has01), .cout(hac01));

generate
	for (i = 0; i < 28; i = i + 1) begin
		full_adder fa00(.a(fpp0[i + 4]), .b(fpp1[i + 2]), .cin(fpp2[i]), .sum(fas0[i]), .cout(fac0[i]));
	end
endgenerate

half_adder ha0s3240(.a(fpp3[2]), .b(fpp4[0]) , .sum(has10), .cout(hac10));
half_adder ha0s3341(.a(fpp3[3]), .b(fpp4[1]) , .sum(has11), .cout(hac11));

generate
	for (i = 0; i < 22; i = i + 1) begin
		full_adder fa01(.a(fpp3[i + 4]), .b(fpp4[i + 2]), .cin(fpp5[i]), .sum(fas1[i]), .cout(fac1[i]));
	end
endgenerate

half_adder ha0s6270(.a(fpp6[2]), .b(fpp7[0]) , .sum(has20), .cout(hac20));
half_adder ha0s6371(.a(fpp6[3]), .b(fpp7[1]) , .sum(has21), .cout(hac21));

generate
	for (i = 0; i < 16; i = i + 1) begin
		full_adder fa02(.a(fpp6[i + 4]), .b(fpp7[i + 2]), .cin(fpp8[i]), .sum(fas2[i]), .cout(fac2[i]));
	end
endgenerate

assign st00 = {fas0, has01, has00, fpp0[1], fpp0[0]};	// 32 bit
assign st01 = {fac0, hac01, hac00};						// 30 bit

assign st02 = {fas1, has11, has10, fpp3[1], fpp3[0]};	// 26 bit
assign st03 = {fac1, hac11, hac10};						// 24 bit

assign st04 = {fas2, has21, has20, fpp6[1], fpp6[0]};	// 20 bit
assign st05 = {fac2, hac21, hac20};						// 18 bit

/////////////// STAGE 2 ///////////////////
wire ha1ss00, ha1ss01, ha1ss02, ha1ss03, ha1sc01, ha1sc02, ha1sc03, ha1sc04, ha1ss10, ha1ss11, ha1sc10, ha1sc11;
wire [25:0] fa1ss0, fa1sc0;
wire [17:0] fa1ss1, fa1sc1;
wire [31:0] st10;
wire [29:0] st11;
wire [23:0] st12;
wire [19:0] st13;

half_adder ha1s0210(.a(st00[2]), .b(st01[0]) , .sum(ha1ss00), .cout(ha1sc01));
half_adder ha1s0311(.a(st00[3]), .b(st01[1]) , .sum(ha1ss01), .cout(ha1sc02));
half_adder ha1s0412(.a(st00[4]), .b(st01[2]) , .sum(ha1ss02), .cout(ha1sc03));
half_adder ha1s0513(.a(st00[5]), .b(st01[3]) , .sum(ha1ss03), .cout(ha1sc04));

generate
	for (i = 0; i < 26; i = i + 1) begin
		full_adder fa03(.a(st00[i + 6]), .b(st01[i + 4]), .cin(st02[i]), .sum(fa1ss0[i]), .cout(fa1sc0[i]));
	end
endgenerate

half_adder ha1s3440(.a(st03[4]), .b(st04[0]) , .sum(ha1ss10), .cout(ha1sc10));
half_adder ha1s3541(.a(st03[5]), .b(st04[1]) , .sum(ha1ss11), .cout(ha1sc11));

generate
	for (i = 0; i < 18; i = i + 1) begin
		full_adder fa04(.a(st03[i + 6]), .b(st04[i + 2]), .cin(st05[i]), .sum(fa1ss1[i]), .cout(fa1sc1[i]));
	end
endgenerate

assign st10 = {fa1ss0, ha1ss03, ha1ss02, ha1ss01, ha1ss00, st00[1], st00[0]};	// 32 bit
assign st11 = {fa1sc0, ha1sc04, ha1sc03, ha1sc02, ha1sc01};						// 30 bit

assign st12 = {fa1ss1, ha1ss11, ha1ss10, st03[3], st03[2], st03[1], st03[0]};	// 24 bit
assign st13 = {fa1sc1, ha1sc11, ha1sc10};										// 20 bit

/////////////// STAGE 3 ///////////////////
wire ha2ss00, ha2ss01, ha2ss02, ha2ss03, ha2ss04, ha2ss05, ha2sc01, ha2sc02, ha2sc03, ha2sc04, ha2sc05, ha2sc06;
wire [23:0] fa2ss0, fa2sc0;
wire [31:0] st20;
wire [29:0] st21;
wire [19:0] st22;

half_adder ha2s0210(.a(st10[2]), .b(st11[0]) , .sum(ha2ss00), .cout(ha2sc01));
half_adder ha2s0311(.a(st10[3]), .b(st11[1]) , .sum(ha2ss01), .cout(ha2sc02));
half_adder ha2s0412(.a(st10[4]), .b(st11[2]) , .sum(ha2ss02), .cout(ha2sc03));
half_adder ha2s0513(.a(st10[5]), .b(st11[3]) , .sum(ha2ss03), .cout(ha2sc04));
half_adder ha2s0614(.a(st10[6]), .b(st11[4]) , .sum(ha2ss04), .cout(ha2sc05));
half_adder ha2s0715(.a(st10[7]), .b(st11[5]) , .sum(ha2ss05), .cout(ha2sc06));

generate
	for (i = 0; i < 24; i = i + 1) begin
		full_adder fa05(.a(st10[i + 8]), .b(st11[i + 6]), .cin(st12[i]), .sum(fa2ss0[i]), .cout(fa2sc0[i]));
	end
endgenerate

assign st20 = {fa2ss0, ha2ss05, ha2ss04, ha2ss03, ha2ss02, ha2ss01, ha2ss00, st10[1], st10[0]};	// 32 bit
assign st21 = {fa2sc0, ha2sc06, ha2sc05, ha2sc04, ha2sc03, ha2sc02, ha2sc01};					// 30 bit

assign st22 = st13;

/////////////// STAGE 4 ///////////////////
wire ha3ss00, ha3ss01, ha3ss02, ha3ss03, ha3ss04, ha3ss05, ha3ss06, ha3ss07, ha3ss08, ha3ss09;
wire ha3sc01, ha3sc02, ha3sc03, ha3sc04, ha3sc05, ha3sc06, ha3sc07, ha3sc08, ha3sc09, ha3sc010;
wire [19:0] fa3ss0, fa3sc0;
wire [31:0] st30;
wire [29:0] st31;

half_adder ha3s0210(.a(st20[2]), .b(st21[0]) , .sum(ha3ss00), .cout(ha3sc01));
half_adder ha3s0311(.a(st20[3]), .b(st21[1]) , .sum(ha3ss01), .cout(ha3sc02));
half_adder ha3s0412(.a(st20[4]), .b(st21[2]) , .sum(ha3ss02), .cout(ha3sc03));
half_adder ha3s0513(.a(st20[5]), .b(st21[3]) , .sum(ha3ss03), .cout(ha3sc04));
half_adder ha3s0614(.a(st20[6]), .b(st21[4]) , .sum(ha3ss04), .cout(ha3sc05));
half_adder ha3s0715(.a(st20[7]), .b(st21[5]) , .sum(ha3ss05), .cout(ha3sc06));
half_adder ha3s0816(.a(st20[8]), .b(st21[6]) , .sum(ha3ss06), .cout(ha3sc07));
half_adder ha3s0917(.a(st20[9]), .b(st21[7]) , .sum(ha3ss07), .cout(ha3sc08));
half_adder ha3s01018(.a(st20[10]), .b(st21[8]) , .sum(ha3ss08), .cout(ha3sc09));
half_adder ha3s01119(.a(st20[11]), .b(st21[9]) , .sum(ha3ss09), .cout(ha3sc010));

generate
	for (i = 0; i < 20; i = i + 1) begin
		full_adder fa06(.a(st20[i + 12]), .b(st21[i + 10]), .cin(st22[i]), .sum(fa3ss0[i]), .cout(fa3sc0[i]));
	end
endgenerate

assign st30 = {fa3ss0, ha3ss09, ha3ss08, ha3ss07, ha3ss06, ha3ss05, ha3ss04, ha3ss03, ha3ss02, ha3ss01, ha3ss00, st20[1], st20[0]};	// 32 bit
assign st31 = {fa3sc0, ha3sc010, ha3sc09, ha3sc08, ha3sc07, ha3sc06, ha3sc05, ha3sc04, ha3sc03, ha3sc02, ha3sc01};					// 30 bit

/////////////// STAGE 5 ///////////////////
wire [29:0] fa4ss0, fa4sc0;
wire [31:0] st40;
full_adder fa07(.a(st30[2]), .b(st31[0]), .cin(1'b0), .sum(fa4ss0[0]), .cout(fa4sc0[0]));

generate
	for (i = 0; i < 29; i = i + 1) begin
		full_adder fa08(.a(st30[i + 3]), .b(st31[i + 1]), .cin(fa4sc0[i]), .sum(fa4ss0[i+1]), .cout(fa4sc0[i + 1]));
	end
endgenerate

assign st40 = {fa4ss0, st30[1], st30[0]};
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
