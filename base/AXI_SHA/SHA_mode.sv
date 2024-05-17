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
   logic [5:0] lite_lim;
   logic [63:0] rev1; 
   logic [63:0] rev2; 
   logic [63:0] rev3; 
   logic [63:0] rev4; 
   
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
        Last <= 1'b0;
    end
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

always_ff @(posedge ACLK) begin
    if (cnt1 == 4)
        VALID <= 1'b1;
end

generate
    for(genvar i = 0; i<(1600/DATA_WIDTH); i++) begin
        always @(posedge ACLK) begin
            if (cnt2 == i)                                                         // Bounded
                Dout <= (Ready == 1) ? Dreg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] : 0;
        end
    end
endgenerate

// byte_reversal in HW

 generate
     for(genvar j = 1; j<26; j++) begin
         always @(posedge ACLK) begin
             if (cnt1 == j-1)
                rev1 <= (Ready == 0) ? 64'b0 : Din [(25-j)%5] [(25-j)/5];
                rev2 <= ((rev1<<8)   & 64'hFF00FF00FF00FF00)|((rev1>>8)  & 64'h00FF00FF00FF00FF);
//                rev3 <= ((rev2<<16)   & 64'hFFFF0000FFFF0000)|((rev2>>16)  & 64'h0000FFFF0000FFFF);
//                rev4 <= ((rev3<<32)   & 64'hFFFFFFFF00000000)|((rev3>>32)  & 64'h00000000FFFFFFFF);
                Dreg [64*j-1:64*(j-1)] <= (cnt1 == j+1) ? rev2 : Dreg [64*j-1:64*(j-1)];
            end
     end
 endgenerate
    
endmodule
