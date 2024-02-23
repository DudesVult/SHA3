module Axi_Stream_Transmitter #(
	parameter int DATA_WIDTH = 16,
	parameter int ID_WIDTH = 8
)
(
  input  ACLK,
  input  ARESETn,
  input  TREADY,
  input  [DATA_WIDTH-1:0] in_data,
  input  how_to_last,
  input [2:0] USER,
  input [1:0] ID, 
  
  output logic [(DATA_WIDTH/8)-1:0] TKEEP,
  output logic [(DATA_WIDTH/8)-1:0] TSTRB,
  output logic TDEST,
  
  output logic [2:0] TUSER, //[2:0] for byte_numb
  output logic [1:0] TID, // �?спользовать для загрузки в регистр?
  output logic  TVALID,
  output logic  TLAST,
  output logic  [DATA_WIDTH-1:0] TDATA,
  output logic 	[127:0] txstate
);

logic [1:0] state;

localparam int 	IDLE  = 0,  WAIT_READY   = 1,	DATA_OUT   = 2, TLAST_OUT   = 3;

always_ff @(state) begin
	case(state)
		IDLE 			:	txstate = "IDLE ";
		WAIT_READY		:	txstate = "WAIT_READY ";
		DATA_OUT		:	txstate = "DATA_OUT";
		TLAST_OUT		:	txstate = "TLAST_OUT";
		default 		:   txstate = "Default";
	endcase
end

always_ff @(posedge ACLK or negedge ARESETn) begin
	if (~ARESETn) state <= IDLE;
	else
		case(state)
		IDLE: begin
			TVALID <= 1'b0;
			TLAST <= 1'b0;
			TUSER <= 3'b0;
			TID <= 2'b0;
			TKEEP <= (DATA_WIDTH/8)*{1'b0};
			TSTRB <= (DATA_WIDTH/8)*{1'b0};
			TDEST <= 1'b0;
			state <= WAIT_READY;
		end
		WAIT_READY: begin
			TVALID <= 1'b1;
			if (TREADY) state <= DATA_OUT;
		end
		DATA_OUT: begin
			TDATA <= in_data;
			TUSER <= USER;
			TID <= ID;
			if (TREADY && ~how_to_last) state <= DATA_OUT;
			else state <= TLAST_OUT;
		end
		TLAST_OUT: begin
			TLAST <= 1'b1;
			if (~how_to_last) state <= WAIT_READY;
		end
		default:
          state <= IDLE;
		endcase
end

endmodule
