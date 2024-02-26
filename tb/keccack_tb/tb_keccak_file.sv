`timescale 1ns/1ns

module tb_keccak_file();

localparam WIDTH = 64;

logic           						clk;
logic           						nrst;
logic  [0:4][0:4][WIDTH-1:0]  	Din;
logic           						Din_valid;
logic           						Last_block;

wire            						Ready;
wire   [0:4][0:4][WIDTH-1:0]  	Dout;
wire	 [4:0]							cnt;
wire	 [47:0]							txstate;

logic  [4:0] 							counter;

keccak_xor keccak_xor_i(.*);

localparam FILE_IN   = "TestFile.txt";
localparam FILE_OUT	= "output.txt";

integer result;
integer file_in, file_out;
string  line_in, line_out;

initial begin
    file_in  = $fopen(FILE_IN, "r");
    file_out = $fopen(FILE_OUT, "w");
end


initial begin
   clk = 0;
	nrst = 1;
	counter = 0;
	Din_valid = 1'b0;
	Last_block = 1'b0;

   result  = $fscanf(file_in, "%s\n", line_in);

   while(line_in != ".") begin
		while(line_in != "+") begin
			result      = $sscanf(line_in, "%h", Din[counter%5][counter/5]);
			result      = $fscanf(file_in, "%s\n", line_in);
			repeat (1) @(negedge clk);
			counter = counter + 1;
		end
		counter = 0;
		Din_valid = 1;
		#1 nrst = 0;
		#1 nrst = 1;
			
		repeat (25) @(negedge clk);

      if(Ready) begin
			print();
      end

      $fwrite(file_out,"-\n");

      result  = $fscanf(file_in, "%s\n", line_in);
		if(line_in == ".")
			Last_block = 1'b1;
		Din_valid = 0;
    end
	 Din_valid = 1;
    Last_block = 1'b1;
    $fclose(file_in);
    $fclose(file_out);
	 $stop;
end


initial begin
	forever #1 clk = ~clk;
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
	$display("Hash from function: %h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$sformat(line_out, "%h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$fwrite(file_out, "%s\n", line_out);
endtask
	
endmodule 