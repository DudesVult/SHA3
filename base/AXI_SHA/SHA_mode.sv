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
    output logic Last 
    ,output logic VALID
//    ,output logic Valid_mode
    );

   logic [7:0] cnt;
   logic [1599:0] Dreg;
   logic [5:0] lite_lim;
   logic [63:0] rev; 
   
   logic reg_Last;
      
always_ff @(posedge ACLK) begin
    if (Ready == 1'b1)
        case (TUSER)
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
            if (cnt == i+1)
                Dout = Dreg [DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
        end
    end
endgenerate

// byte_reversal in HW

 generate
     for(genvar j = 1; j<26; j++) begin
         always @(posedge ACLK) begin
             if (cnt == j-1)
                rev = Din [(25-j)%5] [(25-j)/5];
                rev = ((rev<<8)   & 64'hFF00FF00FF00FF00)|((rev>>8)  & 64'h00FF00FF00FF00FF);
                Dreg [64*j-1:64*(j-1)] = (cnt == j-1) ? rev : Dreg [64*j-1:64*(j-1)];
            end
     end
 endgenerate
    
always_ff @(posedge ACLK)
    VALID <= Ready;

endmodule
