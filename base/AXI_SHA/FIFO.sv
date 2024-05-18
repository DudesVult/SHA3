module FIFO#(
    parameter int DATA_WIDTH = 16
)
(
    input clk,
    input [DATA_WIDTH-1:0] Din,
    output logic [DATA_WIDTH-1:0] Dout,
    input Vin,
    input RE,
    input RST
);

logic [1600/DATA_WIDTH-1:0] [DATA_WIDTH-1:0] fifo_body;
logic [4:0] cnt;

always_ff @(posedge clk) begin

    if (RST) begin
        fifo_body = 0;
        cnt = 0;
    end

    if (Vin) begin
        fifo_body [1600/DATA_WIDTH-1-cnt] <= Din;
        cnt <= cnt + 1;
    end

    if (RE) begin
        Dout <= fifo_body [1600/DATA_WIDTH-1-cnt];
        cnt <= cnt - 1;
        fifo_body <= fifo_body << 1;
    end

end

endmodule