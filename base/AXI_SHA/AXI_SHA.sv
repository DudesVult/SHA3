`timescale 1ns / 1ps

module AXI_SHA #(
	parameter DATA_WIDTH = 32
)
(
    input   ACLK,
    input   ARESETn,

    input [(DATA_WIDTH/8)-1:0] TKEEP_i,
    input [(DATA_WIDTH/8)-1:0] TSTRB_i,
    input [7:0] TDEST_i,
    input  [1:0] TUSER_i,
    input  TID_i,
    input  TVALID_i,
    input  TLAST_i,
    input  [DATA_WIDTH-1:0] TDATA_i,


    output  [DATA_WIDTH-1:0] out_data,
    output Ready,
    input Mode,
    output Last,
    output TREADY,
    output TID_o,
    output [3:0] TUSER_o,
    output TKEEP_o,
    output TSTRB_o,
    output TDEST_o,
    output TVALID_o,
    output TLAST_o,
    output [DATA_WIDTH-1:0] TDATA_o
);

logic [4:0][4:0][63:0] reg_out;
logic [4:0][4:0][63:0] D_reg;

logic [(DATA_WIDTH/8)-1:0] TKEEP;
logic [(DATA_WIDTH/8)-1:0] TSTRB;

logic [DATA_WIDTH-1:0] Mode_out;
logic [DATA_WIDTH-1:0] TDATA;

logic [7:0] TDEST;
logic [7:0] DEST_reg;

logic TID;
logic VALID;
logic ID_o;
logic SHA_valid;
logic KEEP;

logic [3:0] Done;

Axi_Stream_Receiver #(DATA_WIDTH) Axi_Stream_Receiver_i(
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
    .out_data(out_data),
    .VALID_reg(VALID_reg)
    ,.DEST_o(DEST_reg)
    ,.ID(ID_o)
);

AXI_reg #(DATA_WIDTH) AXI_reg_i(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TDEST(DEST_reg),
    .data_in(TDATA_i),     // out_data
    .D_out(reg_out),          // D_out
    .TLAST(TLAST_i),
    .TID(ID_o)
    ,.VALID(SHA_valid)
);

keccak_xor keccak_xor_i(
    .clk(ACLK),
    .nrst(ARESETn),
    .Din(reg_out),
    .Din_valid(SHA_valid),
    .Last_block(TLAST_i),
    .Ready(Ready),
    .KEEP(KEEP),
    .Dout(D_reg),
    .Done(Done[1]),
	.pre_Done(Done[0])
);

SHA_mode #(DATA_WIDTH) SHA_mode_i(
    .ACLK(ACLK),
    .TUSER(TUSER_i), 
    .Din(D_reg), 
    .Ready(Ready),
    .Mode(Mode),
    .Dout(Mode_out),
    .Last(Last)
    ,.VALID(VALID)
    ); 

Axi_Stream_Transmitter #(DATA_WIDTH) Axi_Stream_Transmitter_o(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TREADY(TREADY),
    .VALID(VALID),
    .in_data(Mode_out),
    .Last(Last),
    .USER(Done),
    .ID(KEEP),
    .TKEEP(TKEEP_o),
    .TSTRB(TSTRB_o),
    .TID(TID_o),
    .TDEST(TDEST_o),
    .TUSER(TUSER_o),
    .TVALID(TVALID_o),
    .TLAST(TLAST_o),
    .TDATA(TDATA_o)
);    

endmodule
