`timescale 1ns / 1ps

module tb_TX_RX();

logic ACLK;
logic ARESETn;
logic TREADY;

wire [1:0] TKEEP;
wire [1:0] TSTRB;
wire [7:0] TID;
wire TDEST;
wire TUSER;
wire TLAST;
wire [15:0] TDATA;

logic [15:0] in_data;

logic how_to_last;

wire [127:0] txstate_tx;
wire [127:0] txstate_rx;

Axi_Stream_Transmitter Axi_Stream_Transmitter_i(
    .ACLK(ACLK),             
    .ARESETn(ARESETn),             
    .TREADY(TREADY),             
    .in_data(in_data),
    .how_to_last(how_to_last),            
                 
    .TKEEP(TKEEP),
    .TSTRB(TSTRB),
    .TID(TID),
    .TDEST(TDEST),             
    .TUSER(TUSER),             
                  
    .TVALID(TVALID),      
    .TLAST(TLAST),        
    .TDATA(TDATA),
    .txstate(txstate_tx)  
);

Axi_Stream_Receiver Axi_Stream_Receiver_i (
    .ACLK(ACLK),              
    .ARESETn(ARESETn),        
    .TREADY(TREADY),          
                              
    .TKEEP(TKEEP),            
    .TSTRB(TSTRB),            
    .TID(TID),                
    .TDEST(TDEST),            
    .TUSER(TUSER),            
                              
    .TVALID(TVALID),          
    .TLAST(TLAST),            
    .TDATA(TDATA),            
    .txstate(txstate_rx)         
);

always #5 ACLK = !ACLK;

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b0;
    in_data = 16'd0;
    
    #20 
    ARESETn = 1'b1;
    
    #200
    how_to_last = 1'b1;
    
end

always @(posedge ACLK) begin
    in_data = in_data + 1;
end

endmodule
