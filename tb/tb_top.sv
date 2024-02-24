`timescale 1ns / 1ps

module tb_top();

logic ACLK;
logic ARESETn;
logic [3:0] USER;
logic [1:0] ID;
logic VALID;

logic [15:0] in_data;
logic how_to_last;

logic [15:0] out_data;
logic [4:0][4:0][63:0] D_out;
logic [7:0] i;

top UUT(
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .USER(USER),
    .ID(ID),
    .VALID(VALID),
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
    USER = 4'b0;
    ID = 2'b1;
    
    i = 8'b0;

    #50 ARESETn = 1'b1;
    ID = 2'b1;
    USER = 4'd5;
end

// SHA3-256 _ test

//always @(posedge ACLK) begin 
//    if (ARESETn == 1'b1 && VALID == 1'b1) begin
//        USER = 3'b1;
//        how_to_last = 1'b1;
//    end
//end

// SHA3-256 1 1 0 0 1 test

//always @(posedge ACLK) begin 
//    if (ARESETn == 1'b1 && VALID == 1'b1) begin
//        in_data = 16'b11001;
//        i = i+1;
//        if (i == 2)
//            how_to_last = 1'b1;
//        end
//end

// counter

always @(posedge ACLK) begin
    if (ARESETn == 1'b1 && VALID == 1'b1)
        in_data = in_data + 1;
        if (in_data == 16'd16)
            how_to_last = 1'b1;
        if (how_to_last == 1'b1)
            USER = USER + 1;
end

endmodule
