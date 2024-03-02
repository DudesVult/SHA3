`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.03.2024 17:14:38
// Design Name: 
// Module Name: SHA_mode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SHA_mode #(
    parameter DATA_WIDTH = 16,
    parameter [7:0] max_out = (1600/DATA_WIDTH)-1
)
(
    input ACLK,
    input [1:0] TID,
    input [4:0][4:0][63:0] Din,
    input Ready,
    input Mode,
    output logic [DATA_WIDTH-1:0] Dout,
    output logic Last 
//    ,output logic Valid_mode
    );

   logic [7:0] cnt;
   logic [1599:0] Dreg;
   logic [5:0] lite_lim;
   logic [63:0] rev; 
   
   logic reg_Last;
      
always_ff @(posedge ACLK) begin
    if (Ready == 1'b1)
        case (TID)
        0:  lite_lim = 224/DATA_WIDTH;
        1:  lite_lim = 256/DATA_WIDTH;
        2:  lite_lim = 384/DATA_WIDTH;
        3:  lite_lim = 512/DATA_WIDTH;
        default: lite_lim = 256/DATA_WIDTH;
        endcase
end   

always_ff @(posedge ACLK) begin
    if (Ready == 1'b0) begin
        cnt = -1;
        Last = 1'b0;
    end
    else begin 
        if (Mode == 1'b1)
            if (cnt == lite_lim-1) 
                Last = 1'b1;
        if (Mode == 1'b0)
            if (cnt == max_out)
                Last = 1'b1;
        if (reg_Last == 1'b0)
            cnt = cnt + 1;
        else
            cnt = -1;
        reg_Last = Last;
    end
end

generate
    for(genvar i = 0; i<(1600/DATA_WIDTH); i++) begin
        always @(posedge ACLK) begin
//         if(Last == 1'b0)
            if (cnt == i+1)
                Dout = Dreg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
                // Dout = Dreg [1600 - DATA_WIDTH*i : 1600 - DATA_WIDTH*(i+1)];
        end
    end
endgenerate

// generate
//     for(genvar i = 0; i<25; i++) begin
//             always @(posedge ACLK) begin
//                 assign Dout = [i/5][i%5][DATA_WIDTH*(j+1)-1:DATA_WIDTH*j] Din;
//         end
//     end
// endgenerate

// byte_reversal in HW

 generate
     for(genvar j = 1; j<26; j++) begin
         always @(posedge ACLK) begin
//         if(Last == 1'b0)
             if (cnt == j-1)
                rev = Din [(25-j)%5] [(25-j)/5];
//                rev = ((rev<<32)  & 64'hFFFFFFFF00000000)|((rev>>32) & 64'h00000000FFFFFFFF);
//                rev = ((rev<<16)  & 64'hFFFF0000FFFF0000)|((rev>>16) & 64'h0000FFFF0000FFFF);
                rev = ((rev<<8)   & 64'hFF00FF00FF00FF00)|((rev>>8)  & 64'h00FF00FF00FF00FF);
                Dreg [64*j-1:64*(j-1)] = (cnt == j-1) ? rev : Dreg [64*j-1:64*(j-1)];
            end
     end
 endgenerate
    
//assign  Dreg [63:0]        = Din [4][4];
//assign  Dreg [127:64]      = Din [4][3];
//assign  Dreg [191:128]     = Din [4][2];
//assign  Dreg [255:192]     = Din [4][1];
//assign  Dreg [319:256]     = Din [4][0];
//assign  Dreg [383:320]     = Din [3][4];
//assign  Dreg [447:384]     = Din [3][3];
//assign  Dreg [511:448]     = Din [3][2];
//assign  Dreg [575:512]     = Din [3][1];
//assign  Dreg [639:576]     = Din [3][0];
//assign  Dreg [703:640]     = Din [2][4];
//assign  Dreg [767:704]     = Din [2][3];
//assign  Dreg [831:768]     = Din [2][2];
//assign  Dreg [895:832]     = Din [2][1];
//assign  Dreg [959:896]     = Din [2][0];
//assign  Dreg [1023:960]    = Din [1][4];
//assign  Dreg [1087:1024]   = Din [1][3];
//assign  Dreg [1151:1088]   = Din [1][2];
//assign  Dreg [1215:1152]   = Din [1][1];
//assign  Dreg [1279:1216]   = Din [1][0];
//assign  Dreg [1343:1280]   = Din [0][4];
//assign  Dreg [1407:1344]   = Din [0][3];
//assign  Dreg [1471:1408]   = Din [0][2];
//assign  Dreg [1535:1472]   = Din [0][1];
//assign  Dreg [1599:1536]   = Din [0][0];

endmodule
