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
        0: begin D_out = D_in; D_out [2][3][63:60] = 4'h8; end
        1: begin D_out = D_in; D_out [1][3][63:60] = 4'h8; end
        2: begin D_out = D_in; D_out [2][2][63:60] = 4'h8; end
        3: begin D_out = D_in; D_out [3][1][63:60] = 4'h8; end
        default: begin D_out = D_in; D_out [2][0][63:60]  = 4'h8; end
        endcase
    else
        D_out <= D_in;
end

endmodule
