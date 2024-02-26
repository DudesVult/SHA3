module XOR_IO (Xin,Xout,D);

parameter WIDTH = 64;

input 		[0:4][0:4][WIDTH-1:0] 	Xin;
input 		[0:4][0:4][WIDTH-1:0] 	Xout;

output		[0:4][0:4][WIDTH-1:0] 	D;

assign	D = Xin ^ Xout;

endmodule 