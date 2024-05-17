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
   logic [1599:0] Dreg;
   logic [(1600/DATA_WIDTH)-1:0][DATA_WIDTH-1:0] Dreg2;
   logic [5:0] lite_lim;
   logic [63:0] rev1; 
   logic [63:0] rev2; 
   logic [63:0] rev3; 
   logic [63:0] rev4; 
   logic [63:0] rev; 
   
   logic reg_Last;
      
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
    if (Ready == 1'b0) 
        cnt1 <= -1;
    else
        cnt1 <= cnt1 + 1;
end

always_ff @(posedge ACLK) begin
    if (Ready == 1'b0) begin
        cnt2 <= -1;
        Last <= 1'b0;
        VALID <= 1'b0;
    end
    else if(cnt1 > 3) begin 
        VALID <= 1'b1;
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

generate
    for(genvar i = 0; i<(1600/DATA_WIDTH); i++) begin
        always @(posedge ACLK) begin                                                      // Bounded
            if (VALID) begin
                Dout <= Dreg2[0];
                Dreg2 <= Dreg2 << 1;
            end
        end
    end
endgenerate

generate
    for(genvar j = 0; j<25; j++) begin
        always @(posedge ACLK) begin
        if (DATA_WIDTH == 8) begin
            Dreg2[8*j]   <= rev[7:0];
            Dreg2[8*j+1] <= rev[15:8];
            Dreg2[8*j+2] <= rev[23:16];
            Dreg2[8*j+3] <= rev[31:24];
            Dreg2[8*j+4] <= rev[39:32];
            Dreg2[8*j+5] <= rev[47:40];
            Dreg2[8*j+6] <= rev[55:48];
            Dreg2[8*j+7] <= rev[53:56];
        end
        if (DATA_WIDTH == 16) begin
            Dreg2[4*j]   <= Din [15:0];
            Dreg2[4*j+1] <= Din [31:16];
            Dreg2[4*j+2] <= Din [47:32];
            Dreg2[4*j+3] <= Din [63:48];
        end
        if (DATA_WIDTH == 32) begin
            Dreg2[2*j]   <= rev[31:0];
            Dreg2[2*j+1] <= rev[63:32];
        end
        if (DATA_WIDTH == 64) begin
            Dreg2[j]   <= rev;
        end
    end
    end
endgenerate


// byte_reversal in HW

always_ff @(posedge ACLK) begin 
    case (DATA_WIDTH)
        8:  rev <= rev1;
        16: rev <= rev2;
        32: rev <= rev3;
        64: rev <= rev4;
        default: rev <= rev2;
    endcase
end  

generate
    for(genvar j = 1; j<26; j++) begin
        always @(posedge ACLK) begin
            if (cnt1 == j-1)
            rev1 <= Din [(25-j)%5] [(25-j)/5];
            rev2 <= ((rev1<<8)   & 64'hFF00FF00FF00FF00)|((rev1>>8)  & 64'h00FF00FF00FF00FF);
            rev3 <= ((rev2<<16)   & 64'hFFFF0000FFFF0000)|((rev2>>16)  & 64'h0000FFFF0000FFFF);
            rev4 <= ((rev3<<32)   & 64'hFFFFFFFF00000000)|((rev3>>32)  & 64'h00000000FFFFFFFF);
//            Dreg [64*j-1:64*(j-1)] <= (cnt1 == j+2) ? rev : Dreg [64*j-1:64*(j-1)];
        end
    end
endgenerate
    
endmodule
