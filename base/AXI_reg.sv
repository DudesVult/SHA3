`timescale 1ns / 1ps

module AXI_reg #(
    parameter int DATA_WIDTH = 16
)
(
    input ACLK,
    input ARESETn,
    input TVALID,
    input [DATA_WIDTH-1:0] data_in,

    output [4:0][4:0][63:0] D_out
    );

logic [1599:0] D_reg;
logic [7:0] cnt;

always_ff @(posedge ACLK) begin
    if (ARESETn == 1'b0)
        D_reg <= 1600'b0;
    else
        if (TVALID == 1'b1)
            cnt <= cnt + 1;
        else
            cnt <= -1;
    //    if (cnt == 8'd101)
    //        cnt = -1;
end

generate
    for(genvar i = 0; i<(1600/DATA_WIDTH); i++) begin
        assign D_reg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = (cnt-1 == i) ? data_in : D_reg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
    end
endgenerate

assign  D_out [0][0] = D_reg [63:0] ;
assign  D_out [0][1] = D_reg [127:64]  ;
assign  D_out [0][2] = D_reg [191:128] ;
assign  D_out [0][3] = D_reg [255:192] ;
assign  D_out [0][4] = D_reg [319:256] ;
assign  D_out [1][0] = D_reg [383:320] ;
assign  D_out [1][1] = D_reg [447:384] ;
assign  D_out [1][2] = D_reg [511:448] ;
assign  D_out [1][3] = D_reg [575:512] ;
assign  D_out [1][4] = D_reg [639:576] ;
assign  D_out [2][0] = D_reg [703:640] ;
assign  D_out [2][1] = D_reg [767:704] ;
assign  D_out [2][2] = D_reg [831:768] ;
assign  D_out [2][3] = D_reg [895:832] ;
assign  D_out [2][4] = D_reg [959:896] ;
assign  D_out [3][0] = D_reg [1023:960] ;
assign  D_out [3][1] = D_reg [1087:1024];
assign  D_out [3][2] = D_reg [1151:1088];
assign  D_out [3][3] = D_reg [1215:1152];
assign  D_out [3][4] = D_reg [1279:1216];
assign  D_out [4][0] = D_reg [1343:1280];
assign  D_out [4][1] = D_reg [1407:1344];
assign  D_out [4][2] = D_reg [1471:1408];
assign  D_out [4][3] = D_reg [1535:1472];
assign  D_out [4][4] = D_reg [1599:1536];

endmodule