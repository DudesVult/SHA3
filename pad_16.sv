module pad_16 (
    input ACLK,
    input TLAST,
    input [2:0] TUSER, // TUSER?
    input [15:0] din,
    output [15:0] dout );

logic [15:0] d_reg;

//always @ (posedge(ACLK)) begin
//    if (TLAST == 1'b1)
//        case (TUSER)
//            0: d_reg = 16'h0100;
//            1: d_reg = {din[15:8], 8'h01};
//            default: d_reg = din;
//        endcase
//    else
//        d_reg = din;
//end

always @ (posedge(ACLK)) begin
    if (TLAST == 1'b1)
        case (TUSER)
            0: d_reg = 16'h0100;
            1: d_reg = {8'h01, din[7:0]};
            default: d_reg = din;
        endcase
    else
        d_reg = din;
end


assign dout = d_reg;

endmodule
