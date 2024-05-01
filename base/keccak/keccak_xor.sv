module keccak_xor #(parameter WIDTH = 64)(
    input                  				clk,
    input                  				nrst,
    input   [0:4][0:4][WIDTH-1:0]  		Din,
    input                  				Din_valid,
    input                  				Last_block,
	
    output                 				Ready,
	output logic						KEEP,
    output  [0:4][0:4][WIDTH-1:0] 		Dout,
	output reg	[47:0]					txstate);
		
logic [0:4][0:4][WIDTH-1:0]	reg_data, reg_out, RND_IN, RND_OUT, Xin, Xout, D, XOR_REG;
logic [4:0]	cnt_rnd;
logic [4:0]	RCS;
logic		reg_ready;

logic 	[2:0] 	state, nextstate;
localparam RST = 0, INIT_D = 1, PROC = 2, XOR = 3, OUT = 4;

always @(state) begin
	case(state)
		RST		:	txstate = "RST";
		INIT_D	:	txstate = "INIT_D";
		PROC	:	txstate = "PROC";
		XOR		:	txstate = "XOR";
		OUT		:	txstate = "OUT";
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
				  reg_ready 			<= '0;
				  KEEP					<= 1'b0;
				end

			INIT_D:	  begin
				  cnt_rnd               = 5'd0;
				  reg_data 				<= Din;
				  KEEP					<= 1'b0;
				end

			PROC:	  begin
				  cnt_rnd       		<= cnt_rnd + 1;
				  reg_data              <= RND_OUT;
				  reg_out				<= reg_data;
				  KEEP					<= 1'b0;
				  if (cnt_rnd == 23)
					XOR_REG 			<= RND_OUT;
				end

			XOR: begin
					  Xin				<= Din;
					  Xout				<= XOR_REG;
					  reg_data 			<= D;
					  cnt_rnd           <= 5'd0;
					  KEEP				<= 1'b1;

				end

			OUT: begin
					  reg_out			<=	XOR_REG;
					  reg_ready 		<= '1;
					  cnt_rnd           <= 5'd0;
					  KEEP				<= 1'b1;					  
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
				if (Din_valid)
				  nextstate = PROC;
				else
				  nextstate = XOR;
			  end

			OUT:	begin
			if (Din_valid && !Last_block)
			    nextstate = INIT_D;
            else
                nextstate = OUT;
            end

	endcase
end

assign RND_IN 	= reg_data;
assign Dout 	= reg_out;
assign RCS 		= cnt_rnd;
assign Ready 	= reg_ready;

endmodule 