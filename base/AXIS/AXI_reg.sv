`timescale 1ns / 1ps

module AXI_reg #(
    parameter int DATA_WIDTH = 16
)
(
    input ACLK,
    input ARESETn,
    input TVALID,
    input TLAST,
    input TID,
    input [1:0] TUSER,
    input [DATA_WIDTH-1:0] data_in,

    output [0:4][0:4][63:0] D_out
    ,output logic VALID
    );

logic [1599:0] D_reg;
logic [7:0] cnt;

always_ff @(posedge ACLK)
    VALID <= TID; 

always_ff @(posedge ACLK) begin
    if (ARESETn == 1'b0) 
        cnt = 0;
    else
        if (TVALID == 1'b1 && TLAST == 1'b0)
            cnt <= cnt + 1;
        else begin
            cnt <= -1;

        end
//    if (cnt == 8'd101)
//        cnt = -1;
end

//// padding

// always_ff @(posedge ACLK) begin
//     if (TLAST == 1'b1)
//         case (TUSER)
//         0:  D_reg[(1600-2*224):(1600-2*224)-4] = 4'h8;
//         1:  D_reg[(1600-2*256)-64:(1600-2*256)-68] = 4'h8;
//         2:  D_reg[(1600-2*384):(1600-2*384)-4] = 4'h8;
//         3:  D_reg[(1600-2*512):(1600-2*512)-4] = 4'h8;
//         default: D_reg[(1600-2*256)+4:(1600-2*256)]  = 4'h8;
//         endcase
// end

//always_ff @(posedge ACLK) begin
//    if (TLAST == 1'b1)
//        case (TUSER)
//        0:  D_reg[(1600-2*224):(1600-2*224)-4] = 4'h8;
//        1:  D_reg[(1600-2*256):(1600-2*256)-4] = 4'h8;
//        2:  D_reg[(1600-2*384):(1600-2*384)-4] = 4'h8;
//        3:  D_reg[(1600-2*512):(1600-2*512)-4] = 4'h8;
//        default: D_reg[(1600-2*256)+4:(1600-2*256)] = 4'h8;
//        endcase
//end

//generate
//    for(genvar i = 0; i<(1600/DATA_WIDTH); i++) begin
//        assign D_reg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = (ARESETn == 1'b0) ? '{1'b0} : ((cnt == i) ? data_in : D_reg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]);
//    end
//endgenerate

generate
    for(genvar i = 0; i<(1600/DATA_WIDTH); i++) begin
        always @(negedge ACLK) begin
            if(TLAST != 1'b1)
                D_reg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] = (ARESETn == 1'b0) ? '{1'b0} : ((cnt == i) ? data_in : D_reg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]); // cnt-1 if using padder
        end
    end
endgenerate

assign  D_out [0][0] =  D_reg [63:0];
assign  D_out [1][0] =  D_reg [127:64] ;
assign  D_out [2][0] =  D_reg [191:128];
assign  D_out [3][0] =  D_reg [255:192];
assign  D_out [4][0] =  D_reg [319:256];
assign  D_out [0][1] =  D_reg [383:320];
assign  D_out [1][1] =  D_reg [447:384];
assign  D_out [2][1] =  D_reg [511:448];
assign  D_out [3][1] =  D_reg [575:512];
assign  D_out [4][1] =  D_reg [639:576];
assign  D_out [0][2] =  D_reg [703:640];
assign  D_out [1][2] =  D_reg [767:704];
assign  D_out [2][2] =  D_reg [831:768];
assign  D_out [3][2] =  D_reg [895:832];
assign  D_out [4][2] =  D_reg [959:896];
assign  D_out [0][3] =  D_reg [1023:960] ;
assign  D_out [1][3] =  D_reg [1087:1024];
assign  D_out [2][3] =  D_reg [1151:1088];
assign  D_out [3][3] =  D_reg [1215:1152];
assign  D_out [4][3] =  D_reg [1279:1216];
assign  D_out [0][4] =  D_reg [1343:1280];
assign  D_out [1][4] =  D_reg [1407:1344];
assign  D_out [2][4] =  D_reg [1471:1408];
assign  D_out [3][4] =  D_reg [1535:1472];
assign  D_out [4][4] =  D_reg [1599:1536];

endmodule
