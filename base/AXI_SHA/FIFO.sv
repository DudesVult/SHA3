module FIFO(
    input clk,
    input [63:0] Din,
    output logic [63:0] Dout,
    input Vin,
    input RE,
    input RST
);

logic [31:0] [63:0] fifo_body;
logic [4:0] cnt;

always_ff @(posedge clk) begin

    if (RST) begin
        fifo_body = 0;
        cnt = 0;
    end

    if (Vin) begin
        fifo_body [31-cnt] <= Din;
        cnt <= cnt + 1;
    end

    if (RE) begin
        Dout <= fifo_body [31-cnt];
        cnt <= cnt - 1;
        fifo_body <= fifo_body << 1;
    end

end

endmodule