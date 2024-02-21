`timescale 1ns / 1ps

module tb_top();

logic ACLK;
logic ARESETn;
logic [2:0] USER;

logic [15:0] in_data;
logic how_to_last;

logic [15:0] out_data;
logic [4:0][4:0][63:0] D_out;

top UUT(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .USER(USER),
    .in_data(in_data),
    .how_to_last(how_to_last),
    .out_data(out_data),
    .D_out(D_out)
);

always #5 ACLK = !ACLK;

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b0;
    in_data = 16'd0;
    how_to_last = 1'b0;
    USER = 3'b0;

    #20 ARESETn = 1'b1;
        
end

always @(posedge ACLK) begin
    if (ARESETn == 1'b1)
        in_data = in_data + 1;
        if (in_data == 16'd100)
            how_to_last = 1'b1;
        if (how_to_last == 1'b1)
            USER = USER + 1;
end

endmodule
