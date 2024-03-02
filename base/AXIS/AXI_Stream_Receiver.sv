module Axi_Stream_Receiver #(
	parameter int DATA_WIDTH = 16,
	parameter int ID_WIDTH = 8
)
(
  input  ACLK,
  input  ARESETn,
  input  [DATA_WIDTH-1:0] TDATA,
  input  TVALID,
  input  TLAST,

  input [(DATA_WIDTH/8)-1:0] TKEEP,
  input [(DATA_WIDTH/8)-1:0] TSTRB,
  input [1:0] TID, // �?спользовать для загрузки в регистр?
  input TDEST,
  input [3:0] TUSER, //[2:0] for byte_numbs
  
  output logic TREADY,
  output logic [DATA_WIDTH-1:0] out_data,
  output logic [127:0] txstate
  ,output logic VALID_reg
);

logic [DATA_WIDTH-1:0] data_reg;

logic [1:0] state;

localparam int	IDLE  = 0,  WAIT_INPUT_DATA   = 1,	LOAD_OUTPUT_DATA   = 2, WAIT_OUTPUT_READY   = 3;

always_ff @(state) begin
	case(state)
		IDLE 				:	txstate = "IDLE ";
		WAIT_INPUT_DATA		:	txstate = "WAIT_INPUT_DATA ";
		LOAD_OUTPUT_DATA	:	txstate = "LOAD_OUTPUT_DATA";
		WAIT_OUTPUT_READY	:	txstate = "WAIT_OUTPUT_READY";
		default 			:   txstate = "Default";
	endcase
end

always_ff @(posedge ACLK) begin
	if (~ARESETn) state <= IDLE;
	else
		case(state)
		IDLE: begin
			TREADY <= 1'b0;
			VALID_reg <= 1'b0;
			data_reg <= (DATA_WIDTH/8)*{1'b0};
			if (ARESETn) state <= WAIT_INPUT_DATA;
		end
		WAIT_INPUT_DATA: begin
			TREADY <= 1'b1;
			if (TVALID && ~TLAST) state <= LOAD_OUTPUT_DATA;
			else state <= WAIT_INPUT_DATA;
		end
		LOAD_OUTPUT_DATA: begin
			data_reg <= TDATA;
			VALID_reg <= TVALID;
			if (TVALID && ~TLAST) state <= LOAD_OUTPUT_DATA;
			else state <= WAIT_INPUT_DATA;
			end
		WAIT_OUTPUT_READY:
			if (TREADY) state <= WAIT_INPUT_DATA;
		default:
          state <= IDLE;
		endcase
end

assign out_data = data_reg;

endmodule
