`timescale 1ns / 1ps

module padding(
    input ACLK,
    input TLAST,
    input [1:0] TUSER,
    input [0:4][0:4][63:0] D_in,
    output logic [0:4][0:4][63:0] D_out
);

always_ff @(posedge ACLK) begin
    if (TLAST == 1'b1)
        case (TUSER)
        0:  D_out [2][1][63:59]= 4'h8;
        1:  D_out [2][0][63:59] = 4'h8;
        2:  D_out [1][2][63:59] = 4'h8;
        3:  D_out [1][3][63:59] = 4'h8;
        default: D_out [2][0][63:59]  = 4'h8;
        endcase
end

endmodule
