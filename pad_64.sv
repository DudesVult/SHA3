module pad_64 (
    input ACLK,
    input TLAST,
    input [2:0] TUSER, // TUSER?
    input [63:0] din,
    output [63:0] dout );

logic [63:0] d_reg;

always @ (posedge(ACLK))
    case (TUSER)
    0: d_reg =              64'h0100000000000000;
    1: d_reg = {din[63:56], 56'h01000000000000};
    2: d_reg = {din[63:48], 48'h010000000000};
    3: d_reg = {din[63:40], 40'h0100000000};
    4: d_reg = {din[63:32], 32'h01000000};
    5: d_reg = {din[63:24], 24'h010000};
    6: d_reg = {din[63:16], 16'h0100};
    7: d_reg = {din[63:8],  8'h01};
    default: d_reg = din;
endcase

assign dout = d_reg;

endmodule