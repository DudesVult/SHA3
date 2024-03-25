`timescale 1ns / 1ps

module AXI_SHA #(
	parameter DATA_WIDTH = 16,
	parameter ID_WIDTH = 8
)
(
    input   ACLK,
    input   ARESETn,
    input   [3:0] USER,
    input   [1:0] ID,
    input   [DATA_WIDTH-1:0] in_data,
    input   how_to_last,
    input   VALID_i,
    input   [7:0] DEST,
    output  [DATA_WIDTH-1:0] out_data,
    output  [4:0][4:0][63:0] Dout
    // ,output logic VALID
    ,output Ready
    // ,input SHA_valid
    ,input Mode
    ,output Last
    ,output TREADY
    ,output [1:0] TID_o
    ,output [3:0] TUSER_o
    ,output TKEEP_o
    ,output TSTRB_o
    ,output TDEST_o
    ,output TVALID_o
    ,output TLAST_o
    ,output [DATA_WIDTH-1:0] TDATA_o
);

logic [(DATA_WIDTH/8)-1:0] TKEEP;
logic [(DATA_WIDTH/8)-1:0] TSTRB;
logic TID;
logic [7:0] TDEST;
logic TVALID;
logic TLAST;
logic [1:0] TUSER;
logic [DATA_WIDTH-1:0] TDATA;

logic [DATA_WIDTH-1:0] p_Data;

logic [127:0] txstate_tx;
logic [127:0] txstate_rx;
logic [127:0] txstate_tx_0;
logic [47:0] txstate;

logic [4:0] cnt;

logic [4:0][4:0][63:0] D_out;
logic [4:0][4:0][63:0] reg_out;
logic [4:0][4:0][63:0] D_reg;

logic SHA_valid;

logic [DATA_WIDTH-1:0] Mode_out;

logic VALID;

logic [7:0] DEST_reg;
logic [7:0] DEST_o;
logic ID_o;

/*  SHA_Mode    */

//logic Ready;

// assign VALID = TVALID;

Axi_Stream_Transmitter Axi_Stream_Transmitter_i(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TREADY(TREADY),
    .VALID(VALID_i),
    .in_data(in_data),
    .DEST(DEST),
    .how_to_last(how_to_last),
    .USER(USER),
    .ID(ID),
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
    .txstate(txstate_rx),
    .out_data(out_data),
    .VALID_reg(VALID_reg)
    ,.DEST_o(DEST_reg)
    ,.ID(ID_o)
);

AXI_reg AXI_reg_i(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TDEST(DEST_reg),
    .TVALID(TVALID),     //VALID_reg
    .data_in(TDATA),     // out_data
    .D_out(reg_out),          // D_out
    .TLAST(TLAST),
    .TID(ID_o)
    ,.TUSER(TUSER)
    ,.VALID(SHA_valid)
);

padding padding_i(
    .ACLK(ACLK),
    .TLAST(TLAST),
    .TUSER(TUSER),    
    .D_in(reg_out),
    .D_out(D_out)    
    );

keccak_xor keccak_xor_i(
    .clk(ACLK),
    .nrst(ARESETn),
    .Din(D_out),
    .Din_valid(SHA_valid),
    .Last_block(TLAST),
    .Ready(Ready),
    .Dout(D_reg),
    .cnt(cnt),
    .txstate(txstate)
);

SHA_mode SHA_mode_i(
    .ACLK(ACLK),
    .TUSER(TUSER), 
    .Din(D_reg), 
    .Ready(Ready),
    .Mode(Mode),
    .Dout(Mode_out),
    .Last(Last)
    ,.VALID(VALID)
    ); 

Axi_Stream_Transmitter Axi_Stream_Transmitter_o(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TREADY(TREADY),
    .VALID(VALID),
    .in_data(Mode_out),
    .how_to_last(Last),
    .USER(TUSER),
    .ID(TID),
    .TKEEP(TKEEP_o),
    .TSTRB(TSTRB_o),
    .TID(TID_o),
    .TDEST(TDEST_o),
    .TUSER(TUSER_o),
    .TVALID(TVALID_o),
    .TLAST(TLAST_o),
    .TDATA(TDATA_o)
    ,.txstate(txstate_tx_0)  
);    

assign Dout = D_reg;

endmodule
