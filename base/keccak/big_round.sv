module big_round(RND_IN, RCS, RND_OUT);

parameter WIDTH = 64;
parameter ROUND = 24; //


input	 [4:0] RCS;
input  [0:4][0:4][WIDTH-1:0] RND_IN;

output [0:4][0:4][WIDTH-1:0] RND_OUT;

reg [0:4][0:4][WIDTH-1:0] 		A;
reg [0:4][0:4][WIDTH-1:0] 		B;
reg [0:4][WIDTH-1:0] 			C;
reg [0:4][WIDTH-1:0] 			D;

reg [0:4][0:4][WIDTH-1:0] 		A_reg;

reg [0:23][WIDTH-1:0]			RC;

reg [0:4][0:4][WIDTH-1:0] 		rho_out;
reg [0:4][0:4][WIDTH-1:0] 		theta_out;

genvar x, y;

assign  A  = RND_IN;		
						
//Rotation Constant
assign RC[0]  = 64'h0000000000000001;	
assign RC[1]  = 64'h0000000000008082;	
assign RC[2]  = 64'h800000000000808A;	
assign RC[3]  = 64'h8000000080008000;	
assign RC[4]  = 64'h000000000000808B;	
assign RC[5]  = 64'h0000000080000001;	
assign RC[6]  = 64'h8000000080008081;	
assign RC[7]  = 64'h8000000000008009;	
assign RC[8]  = 64'h000000000000008A;	
assign RC[9]  = 64'h0000000000000088;	
assign RC[10] = 64'h0000000080008009;
assign RC[11] = 64'h000000008000000A;
assign RC[12] = 64'h000000008000808B;
assign RC[13] = 64'h800000000000008B;
assign RC[14] = 64'h8000000000008089;
assign RC[15] = 64'h8000000000008003;
assign RC[16] = 64'h8000000000008002;
assign RC[17] = 64'h8000000000000080;
assign RC[18] = 64'h000000000000800A;
assign RC[19] = 64'h800000008000000A;
assign RC[20] = 64'h8000000080008081;
assign RC[21] = 64'h8000000000008080;
assign RC[22] = 64'h0000000080000001;
assign RC[23] = 64'h8000000080008008;

function int ABS (int numberIn);
  ABS = (numberIn < 0) ? -numberIn : numberIn;
endfunction
			
//theta
generate
	for(x = 0; x <= 4; x++) begin : loop1
		assign C[x] = A[x][0] ^ A[x][1] ^ A[x][2] ^ A[x][3] ^ A[x][4];
	end
endgenerate

generate
	for(x = 1; x <= 4; x++) begin : loop2
		assign D[x] = C[(x-1)] ^ ({C[(x+1)%5][62:0],C[(x+1)%5][63]});
	end
endgenerate

generate
	assign D[0] = C[(4)] ^ ({C[(1)%5][62:0],C[(1)][63]});
endgenerate

generate
	for(x = 0; x <= 4; x++) begin : loop3
		for(y = 0; y <= 4; y++) begin : loop4
			assign theta_out[x][y] = A[x][y] ^ D[x];
		end
	end
endgenerate

//rho and pi

// Rho

assign   rho_out[0][0] =  theta_out [0][0];
assign   rho_out[0][1] =  {theta_out[0][1][WIDTH-1-36:0],theta_out[0][1][WIDTH-1:WIDTH-36]};
assign   rho_out[0][2] =  {theta_out[0][2][WIDTH-1-3:0],theta_out[0][2][WIDTH-1:WIDTH-3]};
assign   rho_out[0][3] =  {theta_out[0][3][WIDTH-1-41:0],theta_out[0][3][WIDTH-1:WIDTH-41]};
assign   rho_out[0][4] =  {theta_out[0][4][WIDTH-1-18:0],theta_out[0][4][WIDTH-1:WIDTH-18]};
                
assign	rho_out[1][0] =  {theta_out[1][0][WIDTH-1-1:0],	theta_out[1][0][WIDTH-1]};
assign	rho_out[1][1] =  {theta_out[1][1][WIDTH-1-44:0],theta_out[1][1][WIDTH-1:WIDTH-44]};
assign	rho_out[1][2] =  {theta_out[1][2][WIDTH-1-10:0],theta_out[1][2][WIDTH-1:WIDTH-10]};
assign	rho_out[1][3] =  {theta_out[1][3][WIDTH-1-45:0],theta_out[1][3][WIDTH-1:WIDTH-45]};
assign	rho_out[1][4] =  {theta_out[1][4][WIDTH-1-2:0],	theta_out[1][4][WIDTH-1:WIDTH-2]};
                
assign	rho_out[2][0] =  {theta_out[2][0][WIDTH-1-62:0],theta_out[2][0][WIDTH-1:WIDTH-62]};
assign	rho_out[2][1] =  {theta_out[2][1][WIDTH-1-6:0],	theta_out[2][1][WIDTH-1:WIDTH-6]};
assign	rho_out[2][2] =  {theta_out[2][2][WIDTH-1-43:0],theta_out[2][2][WIDTH-1:WIDTH-43]};
assign	rho_out[2][3] =  {theta_out[2][3][WIDTH-1-15:0],theta_out[2][3][WIDTH-1:WIDTH-15]};
assign	rho_out[2][4] =  {theta_out[2][4][WIDTH-1-61:0],theta_out[2][4][WIDTH-1:WIDTH-61]};
                
assign	rho_out[3][0] =  {theta_out[3][0][WIDTH-1-28:0],theta_out[3][0][WIDTH-1:WIDTH-28]};
assign	rho_out[3][1] =  {theta_out[3][1][WIDTH-1-55:0],theta_out[3][1][WIDTH-1:WIDTH-55]};
assign	rho_out[3][2] =  {theta_out[3][2][WIDTH-1-25:0],theta_out[3][2][WIDTH-1:WIDTH-25]};
assign	rho_out[3][3] =  {theta_out[3][3][WIDTH-1-21:0],theta_out[3][3][WIDTH-1:WIDTH-21]};
assign	rho_out[3][4] =  {theta_out[3][4][WIDTH-1-56:0],theta_out[3][4][WIDTH-1:WIDTH-56]};
                
assign	rho_out[4][0] =  {theta_out[4][0][WIDTH-1-27:0],theta_out[4][0][WIDTH-1:WIDTH-27]};
assign	rho_out[4][1] =  {theta_out[4][1][WIDTH-1-20:0],theta_out[4][1][WIDTH-1:WIDTH-20]};
assign	rho_out[4][2] =  {theta_out[4][2][WIDTH-1-39:0],theta_out[4][2][WIDTH-1:WIDTH-39]};
assign	rho_out[4][3] =  {theta_out[4][3][WIDTH-1-8:0],	theta_out[4][3][WIDTH-1:WIDTH-8]};
assign	rho_out[4][4] =  {theta_out[4][4][WIDTH-1-14:0],theta_out[4][4][WIDTH-1:WIDTH-14]};

//Pi

generate
	for (x = 0; x <= 4; x++) begin : loop5
		for(y = 0; y <= 4; y++) begin : loop6
			assign B[y][(2*x+3*y) % 5] = rho_out[x][y];
		end
	end
endgenerate

//chi
// A[x,y] = B[x,y] ^ (!B[x+1,y] & B[x+2,y]);

generate
	for (x = 0; x <= 4; x++) begin : loop8
		for(y = 0; y <= 4; y++) begin : loop9
			if(x == 0 && y == 0)
				assign A_reg[x][y] = (B[x][y] ^ (~B[(x+1) % 5][y] & B[(x+2) % 5][y])) ^ RC[RCS]; //chi + iota(A[0,0] = A[0,0] + RC[0];)
			else
				assign A_reg[x][y] = B[x][y] ^ (~B[(x+1) % 5][y] & B[(x+2) % 5][y]);
		end
	end
endgenerate

assign  RND_OUT = A_reg;

endmodule 