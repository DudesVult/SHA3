module padding #(
    parameter DATA_WIDTH = 16
    )(
    input ACLK,
    input TLAST,
    input [2:0] TUSER, // TUSER?
    input [DATA_WIDTH-1:0] din,
    output [DATA_WIDTH-1:0] dout );

logic [DATA_WIDTH/8:0][DATA_WIDTH-1:0] d_reg;

genvar i;

generate
    for (i = 0; i < DATA_WIDTH/8; i++) begin : name_2
        assign d_reg[i] = {din[DATA_WIDTH-1:8*i], 8'h01, (i-2)*{8'h00}};
    end
endgenerate

assign dout = d_reg[TUSER];

endmodule