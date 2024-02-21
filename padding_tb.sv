`timescale 1ns / 1ps

module padding_tb();

parameter width = 16;

logic ACLK;
logic TLAST;
logic [2:0] TUSER;
logic [width-1:0] din;
logic [width-1:0] dout;

always #20 ACLK = !ACLK;

pad_16 UUT_pad_16(
    .ACLK(ACLK),
    .TLAST(TLAST),
    .TUSER(TUSER),
    .din(din),
    .dout(dout)
);

initial begin
    ACLK = 1'b1;
    TLAST = 1'b1;
    TUSER = 3'b0;
    din = 16'hffff;
end

always begin
    #200 TUSER = TUSER + 1;
end

endmodule
