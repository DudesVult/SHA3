`timescale 1ns / 1ps

module top #(
	parameter DATA_WIDTH = 16,
	parameter ID_WIDTH = 8
)
(
    input   ACLK,
    input   ARESETn,
    input   [2:0] USER,
    input   [1:0] ID,
    input   [DATA_WIDTH-1:0] in_data,
    input   how_to_last,
    output  [DATA_WIDTH-1:0] out_data,
    output  [4:0][4:0][63:0] D_out
    ,output logic VALID
);

logic [(DATA_WIDTH/8)-1:0] TKEEP;
logic [(DATA_WIDTH/8)-1:0] TSTRB;
logic [1:0] TID;
logic TDEST;
logic TVALID;
logic TLAST;
logic [2:0] TUSER;
logic [DATA_WIDTH-1:0] TDATA;

logic [DATA_WIDTH-1:0] p_Data;

logic [127:0] txstate_tx;
logic [127:0] txstate_rx;

assign VALID = TVALID;

Axi_Stream_Transmitter Axi_Stream_Transmitter_i(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TREADY(TREADY),
    .in_data(in_data),
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
);

pad_16 UUT_pad_16 (
    .ACLK(ACLK),
    .TLAST(TLAST),
    .TUSER(TUSER),
    .din(out_data),
    .dout(p_Data)
);

AXI_reg AXI_reg_i(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .TVALID(VALID_reg),   //VALID_reg
    .data_in(p_Data), // out_data
    .D_out(D_out),
    .TLAST(TLAST),
    .TID(TID)
);

endmodule
