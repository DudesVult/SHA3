`timescale 1ns / 1ps

module AXI_SHA #(
	parameter DATA_WIDTH = 16,
	parameter ID_WIDTH = 8
)
(
    input   ACLK,
    input   ARESETn,

    input [(DATA_WIDTH/8)-1:0] TKEEP_i,
    input [(DATA_WIDTH/8)-1:0] TSTRB_i,
    input [7:0] TDEST_i,
    input  [1:0] TUSER_i, //[2:0] for byte_numb
    input  TID_i, // �?спользовать для загрузки в регистр?
    input  TVALID_i,
    input  TLAST_i,
    input  [DATA_WIDTH-1:0] TDATA_i,


    output  [DATA_WIDTH-1:0] out_data,
    output  [4:0][4:0][63:0] Dout
    // ,output logic VALID
    ,output Ready
    // ,input SHA_valid
    ,input Mode
    ,output Last
    ,output TREADY
    ,output TID_o
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
logic TLAST_i;
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

logic KEEP;

/*  SHA_Mode    */

Axi_Stream_Receiver Axi_Stream_Receiver_i (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TREADY(TREADY),
    .TKEEP(TKEEP_i),
    .TSTRB(TSTRB_i),
    .TID(TID_i),
    .TDEST(TDEST_i),
    .TUSER(TUSER_i),
    .TVALID(TVALID_i),
    .TLAST(TLAST_i),
    .TDATA(TDATA_i),
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
    .TVALID(TVALID_i),     //VALID_reg
    .data_in(TDATA_i),     // out_data
    .D_out(reg_out),          // D_out
    .TLAST(TLAST_i),
    .TID(ID_o)
    ,.TUSER(TUSER_i)
    ,.VALID(SHA_valid)
);

padding padding_i(
    .ACLK(ACLK),
    .TLAST(TLAST_i),
    .TUSER(TUSER_i),    
    .D_in(reg_out),
    .D_out(D_out)    
    );

keccak_xor keccak_xor_i(
    .clk(ACLK),
    .nrst(ARESETn),
    .Din(D_out),
    .Din_valid(SHA_valid),
    .Last_block(TLAST_i),
    .Ready(Ready),
    .KEEP(KEEP),
    .Dout(D_reg),
    .cnt(cnt),
    .txstate(txstate)
);

SHA_mode SHA_mode_i(
    .ACLK(ACLK),
    .TUSER(TUSER_i), 
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
    .USER(TUSER_i),
    .ID(KEEP),
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
