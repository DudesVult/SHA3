module XOR_64 (Xin,Xout,X,D);

parameter WIDTH = 64;

input 		[WIDTH-1:0] 	Xin;
input 		[WIDTH-1:0] 	Xout;
input 										X;

output		[WIDTH-1:0] 	D;

assign D = Xin ^ Xout;

endmodule 