`timescale 1ns/1ns

module tb_keccak_big();

localparam WIDTH = 64;

logic           						clk;
logic           						nrst;
logic  [0:4][0:4][WIDTH-1:0]  	Din;
logic           						Din_valid;
logic           						Last_block;
logic  [0:4][0:4][WIDTH-1:0]  	Dreg;

wire            						Ready;
wire   [0:4][0:4][WIDTH-1:0]  	Dout;
wire	 [4:0]							cnt;
wire	 [63:0]							txstate;


localparam FILE_OUT      = "output.txt";

integer file_in, file_out;
string  line_in, line_out;


keccak_big keccak_big_i(.*);

initial begin
	clk = 0;
	nrst = 0;
	Last_block = 0;
	Din[0][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[1][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[2][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[3][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[4][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[0][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[1][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[2][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[3][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[4][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[0][2] = 64'hA3A3A3A3A3A3A3A3;	
	Din[1][2] = 64'hA3A3A3A3A3A3A3A3;	
	Din[2][2] = 64'hA3A3A3A3A3A3A3A3;	
	Din[3][2] = 64'hA3A3A3A3A3A3A3A3;	
	Din[4][2] = 64'hA3A3A3A3A3A3A3A3;	
	Din[0][3] = 64'hA3A3A3A3A3A3A3A3;	
	Din[1][3] = 64'hA3A3A3A3A3A3A3A3;	
	Din[2][3] = 64'h0000000000000000;	
	Din[3][3] = 64'h0000000000000000;	
	Din[4][3] = 64'h0000000000000000;	
	Din[0][4] = 64'h0000000000000000;	
	Din[1][4] = 64'h0000000000000000;	
	Din[2][4] = 64'h0000000000000000;	
	Din[3][4] = 64'h0000000000000000;	
	Din[4][4] = 64'h0000000000000000;
	#1 nrst = 0;
	#1 nrst = 1;	
	Din_valid = 1;

	
	#52
	Din[0][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[1][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[2][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[3][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[4][0] = 64'hA3A3A3A3A3A3A3A3;	
	Din[0][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[1][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[2][1] = 64'hA3A3A3A3A3A3A3A3;	
	Din[3][1] = 64'h00000000000000C3;	
	Din[4][1] = 64'h0000000000000000;	
	Din[0][2] = 64'h0000000000000000;	
	Din[1][2] = 64'h0000000000000000;	
	Din[2][2] = 64'h0000000000000000;	
	Din[3][2] = 64'h0000000000000000;	
	Din[4][2] = 64'h0000000000000000;	
	Din[0][3] = 64'h0000000000000000;	
	Din[1][3] = 64'h8000000000000000;	
	Din[2][3] = 64'h0000000000000000;	
	Din[3][3] = 64'h0000000000000000;	
	Din[4][3] = 64'h0000000000000000;	
	Din[0][4] = 64'h0000000000000000;	
	Din[1][4] = 64'h0000000000000000;	
	Din[2][4] = 64'h0000000000000000;	
	Din[3][4] = 64'h0000000000000000;	
	Din[4][4] = 64'h0000000000000000;  
	
	
//	Din[0][0] = Dreg[0][0] ^ Dout[0][0];
//	Din[1][0] = Dreg[1][0] ^ Dout[1][0];
//	Din[2][0] = Dreg[2][0] ^ Dout[2][0];
//	Din[3][0] = Dreg[3][0] ^ Dout[3][0];
//	Din[4][0] = Dreg[4][0] ^ Dout[4][0];
//	Din[0][1] = Dreg[0][1] ^ Dout[0][1];
//	Din[1][1] = Dreg[1][1] ^ Dout[1][1];
//	Din[2][1] = Dreg[2][1] ^ Dout[2][1];
//	Din[3][1] = Dreg[3][1] ^ Dout[3][1];
//	Din[4][1] = Dreg[4][1] ^ Dout[4][1];
//	Din[0][2] = Dreg[0][2] ^ Dout[0][2];
//	Din[1][2] = Dreg[1][2] ^ Dout[1][2];
//	Din[2][2] = Dreg[2][2] ^ Dout[2][2];
//	Din[3][2] = Dreg[3][2] ^ Dout[3][2];
//	Din[4][2] = Dreg[4][2] ^ Dout[4][2];
//	Din[0][3] = Dreg[0][3] ^ Dout[0][3];
//	Din[1][3] = Dreg[1][3] ^ Dout[1][3];
//	Din[2][3] = Dreg[2][3] ^ Dout[2][3];
//	Din[3][3] = Dreg[3][3] ^ Dout[3][3];
//	Din[4][3] = Dreg[4][3] ^ Dout[4][3];
//	Din[0][4] = Dreg[0][4] ^ Dout[0][4];
//	Din[1][4] = Dreg[1][4] ^ Dout[1][4];
//	Din[2][4] = Dreg[2][4] ^ Dout[2][4];
//	Din[3][4] = Dreg[3][4] ^ Dout[3][4];
//	Din[4][4] = Dreg[4][4] ^ Dout[4][4];
	
end

initial begin
	forever #1 clk = ~clk;
end

always @(posedge clk) begin
	if(Ready == 1'b1 && Last_block == 1'b1)
		print();
end

function logic [63:0] revers_byte(logic [63:0] data);
	logic [63:0] res;

	begin
		res = data;
		res = ((res<<32)  & 64'hFFFFFFFF00000000)|((res>>32) & 64'h00000000FFFFFFFF);
		res = ((res<<16)  & 64'hFFFF0000FFFF0000)|((res>>16) & 64'h0000FFFF0000FFFF);
		res = ((res<<8)   & 64'hFF00FF00FF00FF00)|((res>>8)  & 63'h00FF00FF00FF00FF);
		return res;
	end
endfunction  

task print;
	file_out = $fopen(FILE_OUT, "w");
	$display("Hash from function: %h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$sformat(line_out, "%h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$fwrite(file_out, "%s\n", line_out);
	$fclose(file_out);
	# 10 $stop;
endtask

initial  
	#200 $stop;
	
endmodule 