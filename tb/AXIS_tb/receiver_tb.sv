`timescale 1ns/1ns

module receiver_tb();

logic ACLK;
logic ARESETn;
logic TVALID;
logic how_to_last;

logic [1:0] TKEEP;
logic [1:0] TSTRB;
logic [7:0] TID; // �?спользовать для загрузки в регистр?
logic TDEST;
logic TUSER;

logic [15:0] TDATA;
logic TLAST;

wire TREADY;
wire [15:0] out_data;
wire [127:0] txstate;

Axi_Stream_Receiver Axi_Stream_Receiver_i (.*);

always #5 ACLK = !ACLK;

initial begin

    ARESETn = 1'b0;
    ACLK = 1'b1;
    TDATA = 32'b0;
    TVALID = 1'b0;
    TLAST = 1'b0;
    
    #10
    ARESETn = 1'b1;
    
    TDATA = 32'd10000;
    
    #20
    TVALID = 1'b1;
    
    #20 TVALID = 1'b0;
    TDATA = 32'd9999;
    
    #20 TVALID = 1'b1;
    
    #5 TDATA = 32'd9998;
    #10 TDATA = 32'd9997;
    #10 TDATA = 32'd9996;
    #10 TDATA = 32'd9995;
    #10 TLAST = 1'b1;
    #20 TLAST = 1'b0;

#20 $stop;

end


endmodule 