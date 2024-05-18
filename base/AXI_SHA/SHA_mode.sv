`timescale 1ns / 1ps

module SHA_mode #(
    parameter DATA_WIDTH = 16,
    parameter [7:0] max_out = (1600/DATA_WIDTH)-1
)
(
    input ACLK,
    input [1:0] TUSER,
    input [4:0][4:0][63:0] Din,
    input Ready,
    input Mode,
    output logic [DATA_WIDTH-1:0] Dout,
    output logic Last, 
    output logic VALID
    );

   logic [7:0] cnt1;
   logic [7:0] cnt2;
   logic [7:0] lite_lim;
   logic [1599:0] Dreg;
   
   logic reg_Last;
   logic valid_q;
      
always_ff @(posedge ACLK) begin
    if (Ready == 1'b1)
        case (TUSER)
        0:  lite_lim <= 224/DATA_WIDTH;
        1:  lite_lim <= 256/DATA_WIDTH;
        2:  lite_lim <= 384/DATA_WIDTH;
        3:  lite_lim <= 512/DATA_WIDTH;
        default: lite_lim <= 256/DATA_WIDTH;
        endcase
    else
        lite_lim <= 0;
end   

always_ff @(posedge ACLK) begin
    if (Ready == 1'b0) begin
        cnt1 <= -1;
    end
    else begin
        cnt1 <= cnt1 + 1;
    end
end

always_ff @(posedge ACLK) begin
    if (Ready == 1'b0) begin
        cnt2 <= -1;
        Last <= 1'b0;
        VALID <= 1'b0;
    end
    if (cnt1 == 0) begin
        Dreg [63:0]       <=  Din [0][0];
        Dreg [127:64]     <=  Din [1][0];
        Dreg [191:128]    <=  Din [2][0];
        Dreg [255:192]    <=  Din [3][0];
        Dreg [319:256]    <=  Din [4][0];
        Dreg [383:320]    <=  Din [0][1];
        Dreg [447:384]    <=  Din [1][1];
        Dreg [511:448]    <=  Din [2][1];
        Dreg [575:512]    <=  Din [3][1];
        Dreg [639:576]    <=  Din [4][1];
        Dreg [703:640]    <=  Din [0][2];
        Dreg [767:704]    <=  Din [1][2];
        Dreg [831:768]    <=  Din [2][2];
        Dreg [895:832]    <=  Din [3][2];
        Dreg [959:896]    <=  Din [4][2];
        Dreg [1023:960]   <=  Din [0][3];
        Dreg [1087:1024]  <=  Din [1][3];
        Dreg [1151:1088]  <=  Din [2][3];
        Dreg [1215:1152]  <=  Din [3][3];
        Dreg [1279:1216]  <=  Din [4][3];
        Dreg [1343:1280]  <=  Din [0][4];
        Dreg [1407:1344]  <=  Din [1][4];
        Dreg [1471:1408]  <=  Din [2][4];
        Dreg [1535:1472]  <=  Din [3][4];
        Dreg [1599:1536]  <=  Din [4][4];
    end
    else if(cnt1 > 3) begin 
        VALID <= 1'b1;
        Dreg <= {{DATA_WIDTH{1'b0}}, Dreg[1600-DATA_WIDTH-1:DATA_WIDTH]};
        if (Mode == 1'b1)
            if (cnt2 == lite_lim-1) 
                Last <= 1'b1;
        if (Mode == 1'b0)
            if (cnt2 == max_out)
                Last <= 1'b1;
        if (reg_Last == 1'b0)
            cnt2 <= cnt2 + 1;
        else
            cnt2 <= -1;
            reg_Last <= Last; // bounded
    end
end

assign Dout = Dreg [15:0];
    
endmodule
