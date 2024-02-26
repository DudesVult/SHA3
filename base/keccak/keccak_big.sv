module keccak_big #(parameter WIDTH = 64)(
    input                  				clk,
    input                  				nrst,
    input   [0:4][0:4][WIDTH-1:0]  		Din,
    input                  				Din_valid,
    input                  				Last_block,
	
    output                 				Ready,
    output  [0:4][0:4][WIDTH-1:0] 		Dout,
	 output	[4:0]								cnt,
	 output reg	[63:0]						txstate);
		
reg	[0:4][0:4][WIDTH-1:0]	reg_data, reg_out, RND_IN, RND_OUT;
logic [255:0]   					reg_data_vector;
logic [4:0]     					cnt_rnd;
logic           					din_buffer_full;
logic [4:0]			   			RCS;
logic [1023:0]  					din_buffer_out;
logic           					permutation_computed;
logic									reg_ready;
logic									reg_cnt;

logic	[4:0]							count;

reg 	[1:0] 						state, nextstate;
reg 	[2:0] 						st;
	 
genvar x,i,col,row;

localparam RST = 0, INIT_D = 1, PROC = 2, XOR = 3, OUT = 4;

always @(state) begin
	case(state)
		RST		:	txstate = "RST";
		INIT_D	:	txstate = "INIT_D";
		PROC		:	txstate = "PROC";
		XOR		:	txstate = "XOR";
		OUT		:	txstate = "OUT";
		//WAIT state? 
	endcase
end

always @(posedge clk or negedge nrst) begin
	if (!nrst) 
		state <= RST;
	else 
		state <= nextstate;
end


big_round big_round_i(
    .RND_IN,
    .RCS,
    .RND_OUT);

always @(posedge clk)
	begin
		case (state)
			RST:	  begin
				  cnt_rnd               = 5'd26;
				  reg_ready 				<= '0;
				end

			INIT_D:	  begin
				  cnt_rnd               = 5'd0;
				  reg_data 					<= Din;
				end

			PROC:	  begin
				  cnt_rnd       			<= cnt_rnd + 1;
				  reg_data              <= RND_OUT;
				  reg_out					<= reg_data;
				end

			XOR: begin
					  reg_data 				<= Din^RND_OUT;
					  reg_out				<=	reg_data;
					  cnt_rnd				<= '0;
				end

			OUT: begin
				     reg_data 				<= Din;
					  cnt_rnd				<= '0;
					  reg_out				<=	reg_data;
					  reg_ready 			<= '1;
				end

//			WAIT: begin

//				end

	endcase
end


always @(posedge clk or negedge nrst)
	begin
		case (state)
			RST:	begin
			  if (nrst)
				  nextstate = INIT_D;
			  else
				  nextstate = RST;
			  end

			INIT_D:	begin
			  if (Din_valid)
				  nextstate = PROC;
			  else
				  nextstate = INIT_D;
			  end

			PROC:	begin
			  if (cnt_rnd < 24)
				  nextstate = PROC;
			  else 
					if (!Last_block)
				  nextstate = XOR;
					else
				  nextstate = OUT;
			  end

			XOR:	begin
				  nextstate = INIT_D;
			  end

			OUT:	begin
				  nextstate = INIT_D;
			  end

//			WAIT:	begin

//			  end

	endcase
end

assign RND_IN 	= reg_data;
assign Dout 	= reg_out;
assign RCS 		= cnt_rnd;
assign cnt 		= cnt_rnd;
assign Ready 	= reg_ready;

endmodule 