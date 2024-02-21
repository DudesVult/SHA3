`timescale 1ns/1ns

module transmitter_tb();

logic ACLK;
logic ARESETn;
logic TREADY;
logic [15:0] in_data;
logic how_to_last;

wire [1:0] TKEEP;
wire [1:0] TSTRB;
wire [7-1:0] TID; // �?спользовать для загрузки в регистр?
wire TDEST;
wire TUSER;

wire TVALID;
wire TLAST;
wire [15:0] TDATA;
wire [127:0] txstate;

Axi_Stream_Transmitter Axi_Stream_Transmitter_i(.*);

always #5 ACLK = !ACLK;

initial begin

	ARESETn = 1'b0;
	ACLK = 1'b1;
	in_data = 32'b0;
	TREADY = 1'b0;
	how_to_last = 1'b0;
	in_data = 32'b0;


	#10
	ARESETn = 1'b1;

	in_data = 32'd10000;
	#10
	in_data = 32'd9999;


	#10 in_data = 32'd9998;
	TREADY = 1'b1;
	#10 in_data = 32'd9997;
	#10 in_data = 32'd9996;
		 how_to_last = 1'b1;
	
	#10 in_data = 32'd9995;

	#20 $stop;

end


endmodule 