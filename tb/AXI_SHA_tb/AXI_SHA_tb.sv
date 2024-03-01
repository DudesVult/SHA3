`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.02.2024 20:42:36
// Design Name: 
// Module Name: AXI_SHA_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI_SHA_tb();
localparam WIDTH = 16;

logic ACLK;
logic ARESETn;
logic [3:0] USER;
logic [1:0] ID;
logic VALID;

logic [15:0] in_data;
logic how_to_last;

logic [15:0] out_data;
logic [4:0][4:0][63:0] D_out;
logic [7:0] i;

logic SHA_valid;

logic Ready;

localparam FILE_OUT      = "output.txt";

integer file_in, file_out;
string  line_in, line_out;

int i,j;

wire   [0:4][0:4][63:0]  	Dout;

AXI_SHA AXI_SHA_i(.*);

always #5 ACLK = !ACLK;

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b0;
    in_data = 16'd0;
    how_to_last = 1'b0;
    USER = 4'b0;
    ID = 2'd0;              // 0 - SHA3-224, 1 - SHA3-256, 2 - SHA3-384, 3 - SHA3-512
    SHA_valid = 1'b0;
    
    i = 8'b0;

    #50 ARESETn = 1'b1;
    USER = 4'd5;
	in_data = 16'd6; // 16'd0
	how_to_last = 1'b1;
	#50 SHA_valid = 1'b1;
	
//    #40;
//	#10 in_data = 16'h0600;
//	#10;
//	how_to_last = 1'b1;
//	#50 SHA_valid = 1'b1;
	
end
	

// always @(posedge ACLK) begin
//     if (ARESETn == 1'b1 && VALID == 1'b1)
//         in_data = in_data + 1;
//         if (in_data == 16'd16)
//             how_to_last = 1'b1;
//         if (how_to_last == 1'b1)
//             USER = USER + 1;
// end

initial begin
	forever begin
	#1;
	for (int i = 0; i<5; i++)
		for (int j = 0; j<5; j++)
			D_out[i][j] = revers_byte(Dout[i][j]);
	end
end

always @(posedge ACLK) begin
	if(Ready == 1'b1 && how_to_last == 1'b1) begin
       $display("Time to stop: ", $time);
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

//initial  
//	#200 $stop;
	
endmodule 