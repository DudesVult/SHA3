module keccak_xor #(parameter WIDTH = 64)(
    input                  				clk,
    input                  				nrst,
    input   [0:4][0:4][WIDTH-1:0]  		Din,
    input                  				Din_valid,
    input                  				Last_block,
	
    output                 				Ready,
    output  [0:4][0:4][WIDTH-1:0] 		Dout,
	 output	[4:0]								cnt,
	 output reg	[47:0]						txstate);
		
logic [0:4][0:4][WIDTH-1:0]	reg_data, reg_out, RND_IN, RND_OUT, Xin, Xout,D, XOR_REG;
logic [255:0]   					reg_data_vector;
logic [4:0]     					cnt_rnd;
logic           					din_buffer_full;
logic [4:0]			   			RCS;
logic           					permutation_computed;
logic									reg_ready;
logic									reg_cnt;

logic	[4:0]							count;

logic 	[2:0] 					state, nextstate;
	 
genvar x,i,col,row;

localparam RST = 0, INIT_D = 1, PROC = 2, XOR = 3, OUT = 4, WAIT = 5;

always @(state) begin
	case(state)
		RST		:	txstate = "RST";
		INIT_D	:	txstate = "INIT_D";
		PROC		:	txstate = "PROC";
		XOR		:	txstate = "XOR";
		OUT		:	txstate = "OUT";
		WAIT		:	txstate = "WAIT";
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
	 
XOR_IO XOR_IO_i(
	.Xin,
	.Xout,
	.D);

always @(posedge clk)
	begin
		case (state)
			RST:	  begin
				  cnt_rnd               = 5'd0;
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
				  if (cnt_rnd == 23)
						XOR_REG <= RND_OUT;
				end

			XOR: begin
					  Xin						<= Din;
					  Xout					<=	XOR_REG;
					  reg_data 				<= D;
					  cnt_rnd            <= 5'd0;
				end

			OUT: begin
					  reg_out				<=	XOR_REG;
					  reg_ready 			<= '1;
					  cnt_rnd              <= 5'd0;					  
				end
				
            WAIT : begin
                      cnt_rnd               = 5'd0;
                      reg_ready 			<= '0;				  
				end

	endcase
end


always @(posedge clk)
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
				  nextstate = PROC;
			  end

			OUT:	begin
			if (Din_valid)
			    nextstate = INIT_D;
            else
                nextstate = WAIT;
            end

			WAIT:	begin
			if (Din_valid)
			    nextstate = INIT_D;
            else
                nextstate = WAIT;
            end

	endcase
end

assign RND_IN 	= reg_data;
assign Dout 	= reg_out;
assign RCS 		= cnt_rnd;
assign cnt 		= cnt_rnd;
assign Ready 	= reg_ready;

endmodule 