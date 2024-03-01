`timescale 1ns/1ns

module tb_keccak_xor();

localparam WIDTH = 64;

logic           						clk;
logic           						nrst;
logic  [0:4][0:4][WIDTH-1:0]  	Din;
logic           						Din_valid;
logic           						Last_block;

wire            						Ready;
logic   [0:4][0:4][WIDTH-1:0] D_out;
wire	 [4:0]							cnt;
wire	 [47:0]							txstate;


localparam FILE_OUT      = "output.txt";

integer file_in, file_out;
string  line_in, line_out;

int i,j;

wire   [0:4][0:4][WIDTH-1:0]  	Dout;

keccak_xor keccak_xor_i(.*);

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
	Din[3][1] = 64'h0000000000000006;	
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

	#20
	
	Last_block = 1;
	
	
	
end

initial begin
	forever #1 clk = ~clk;
end

initial begin
	forever begin
	#1;
	for (int i = 0; i<5; i++)
		for (int j = 0; j<5; j++)
			D_out[i][j] = revers_byte(Dout[i][j]);
	end
end

always @(posedge clk) begin
	if(Ready == 1'b1 && Last_block == 1'b1) begin
//	   $display("Time to stop: ", $time);
		print();
		end
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
	$display("%h%h%h%h", revers_byte(Dout[4][0]), revers_byte(Dout[0][1]), revers_byte(Dout[1][1]), revers_byte(Dout[2][1]));
	$sformat(line_out, "%h%h%h%h[31:0]", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$fwrite(file_out, "%s\n", line_out);
	$fclose(file_out);
	# 10 $stop;
endtask

initial  
	#200 $stop;
	
endmodule 