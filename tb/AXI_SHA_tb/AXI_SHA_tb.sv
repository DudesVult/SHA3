`timescale 1ns / 1ps

// `include "test.mem"

module AXI_SHA_tb();
localparam DATA_WIDTH = 32;
localparam clock_period = 5.5; //ns

localparam SHA = 384;

logic ACLK;
logic ARESETn;
logic [1:0] USER;
logic ID;
logic VALID_i;

logic TREADY;

logic [DATA_WIDTH-1:0] in_data;
logic Last_i;

logic [DATA_WIDTH-1:0] out_data;
logic [7:0] i;

// logic SHA_valid;
logic Mode;
logic Last;

logic Ready;

localparam FILE_IN   = "1600.bin"; //"1600.bin";
localparam FILE_OUT      = "output.txt";

integer file_out;
string  line_out;

logic [(1600/DATA_WIDTH)-1:0][DATA_WIDTH-1:0] D_result;
logic [1599-1:0] Dres;
logic [7:0] cnt;
logic [7:0] cnt2;

int fd; // file descriptor

AXI_SHA AXI_SHA_i(.*);

logic [7:0] DEST;
logic [4:0] cnt_cd;

logic TID_o;
logic [3:0] TUSER_o;
logic TKEEP_o;
logic TSTRB_o;
logic TDEST_o;
logic TVALID_o;
logic TLAST_o;
logic [DATA_WIDTH-1:0] TDATA_o;

logic TREADY_reg;
logic TVALID_o_reg;

logic ARESETn_reg;
logic ARESETn_assert;
logic read;

bit [DATA_WIDTH-1:0] queue [$];

int rcnt;

int len;
int cnt_l;

// AXI tx logic

logic [(DATA_WIDTH/8)-1:0] TKEEP_i;
logic [(DATA_WIDTH/8)-1:0] TSTRB_i;
logic [7:0] TDEST_i;
logic  [1:0] TUSER_i;
logic  TID_i;
logic  TVALID_i;
logic  TLAST_i;
logic  [DATA_WIDTH-1:0] TDATA_i;
logic  [24:0][63:0] Dtmp;

always #(clock_period/2) ACLK = !ACLK;

// Initial values

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b1;
    ARESETn_reg = 1'b1;
    VALID_i = 1'b1;
    in_data = 16'd0;
    Last_i = 1'b0;
    ID = 1'b0;              // 0 - SHA3-224, 1 - SHA3-256, 2 - SHA3-384, 3 - SHA3-512
	Mode = 1'b1;
	cnt = 0;
	cnt2 = 24;
    
    i = 8'b0;
    DEST = 0;
    cnt_cd = 0;
    rcnt = 0;
    cnt_l = 0;

end

// Transform SHA version to USER

initial begin
    case(SHA)
        224 : USER = 2'd0;
        256 : USER = 2'd1;
        384 : USER = 2'd2;
        512 : USER = 2'd3;
        default : USER = 2'd1;
    endcase
end

initial begin
    ARESETn_assert = 1'b0;
    #50 ARESETn = 1'b0;
    #50 ARESETn = 1'b1;
end

always @(posedge ACLK) begin
    if (ARESETn_reg != ARESETn && ARESETn_reg == 1'b0) begin
        ARESETn_reg <= ARESETn;
        read = 1'b1;
        #20 ARESETn_assert = 1'b1;
    end
    else if (ARESETn_reg != ARESETn && ARESETn_reg == 1'b1) begin
        ARESETn_reg <= ARESETn;
        read = 1'b0;
    end
    else read = 1'b0;
end

initial begin
    fd = $fopen(FILE_IN,"r");
    if (fd) $display("Success :%d", fd);
    else    $display("Error :%d", fd);
    readfile;
end

always @(posedge(ACLK)) begin
        TREADY_reg = TREADY;
end

always @(posedge(ACLK)) begin
    if (TREADY_reg == 1'b1 && ARESETn_assert == 1'b1) begin
        if(DEST < ((1600 - SHA*2)/DATA_WIDTH) - 1) begin
            if (queue.size() >= 1) begin
                in_data = queue.pop_front();
                DEST = DEST + 1;
            end
             if (queue.size() == 0) begin
                in_data = 0;
                rcnt = 1;
                DEST = ((1600 - SHA*2)/DATA_WIDTH) - 1;
                #clock_period;
            end
            if (rcnt == 1 && TID_o == 1'b1) begin
                in_data = 32'h8000_0000;
                ID = 1'b1;
                Last_i = 1'b1;
                #50                     
                ID = 1'b0;
                DEST = 255;
            end
            cnt_cd = 0;
            $display("queue.size(): %d , cnt: %d, data: %h", queue.size(), DEST, in_data, $time);
        end
        else if (DEST == 255)
            DEST = 0;
        else if (TUSER_o[1] == 1'b1) begin
            in_data = queue.pop_front();
            ID = 1'b1;
            #(2*clock_period) ID = 1'b0;
            #clock_period DEST = 255;
            #clock_period;
        end
    end
end

// AXI TX

logic [1:0] state;

localparam int 	IDLE  = 0,  WAIT_READY   = 1,	DATA_OUT   = 2, TLAST_OUT   = 3;

always_ff @(posedge ACLK) begin
	if (~ARESETn) state <= IDLE;
	else
		case(state)
            IDLE: begin
                TVALID_i <= 1'b0;
                TLAST_i <= 1'b0;
                TUSER_i <= 2'b0;
                TID_i   <= 1'b0;
                TKEEP_i <= 2'b0;
                TSTRB_i <= 0;
                TDEST_i <= 0;
                TDATA_i <= '0;
                if (ARESETn) state <= WAIT_READY;
            end
            WAIT_READY: begin
                TVALID_i <= 1;
                TDEST_i <= DEST;
                if (TREADY) state <= DATA_OUT;
            end
            DATA_OUT: begin
                TDATA_i <= in_data;
                TUSER_i <= USER;
                TID_i <= ID;
                TVALID_i <= 1;
                TDEST_i <= DEST;
                if (TREADY && ~Last_i) state <= DATA_OUT;
                else state <= TLAST_OUT;
            end
            TLAST_OUT: begin
                TLAST_i <= 1'b1;
                TID_i <= ID;
                if (~Last_i) state <= WAIT_READY;
            end
            default:
              state <= IDLE;
		endcase
end

always @(posedge ACLK) 
    TVALID_o_reg <= TVALID_o;

always @(posedge ACLK) begin
    if (TVALID_o_reg == 1'b1 && TLAST_o == 1'b0) begin
        cnt = cnt + 1;
        read_hash(TDATA_o, cnt, cnt2);
        // Dtmp [cnt2][cnt*DATA_WIDTH-1:(cnt-1)*DATA_WIDTH] = TDATA_o;
        // if (cnt == 64/DATA_WIDTH) begin
        //     cnt = 0; 
        //     Dtmp [cnt2] = reverse_byte(Dtmp [cnt2]);
        //     cnt2 = cnt2 - 1;
        // end
    end
    if (TVALID_o_reg == 1'b1 &&  TLAST_o == 1'b1) begin
        cnt = cnt + 1;
        read_hash(TDATA_o, cnt, cnt2);
        // Dtmp [cnt2][cnt*DATA_WIDTH-1:(cnt-1)DATA_WIDTH] = TDATA_o;
        // if (cnt == 64/DATA_WIDTH) begin
        //     cnt = 0; 
        //     Dtmp [cnt2] = reverse_byte(Dtmp [cnt2]);
        //     cnt2 = cnt2 - 1;
        // end
//        print_term;
        print_file;
        #20 $stop;
    end
end

// version for prepared data

// logic [DATA_WIDTH-1:0] data;
// byte byte_data[(DATA_WIDTH/8)];
// task readfile;
//     queue.delete();
//     DEST = 255;
//     Last_i = 0;
//     len = $fgetc(fd);
//     // while (!$feof(fd)) begin
//     while (cnt_l < len) begin
//         for (i = 0; i < (DATA_WIDTH/8); i++) begin
//             byte_data[i] = $fgetc(fd);
//             // $display("i: %d", i);
//             cnt_l = cnt_l + 1;
//         end
//         loader;
//         queue.push_back(data); // Write data to file
//     end
//     queue.size() = queue.size();
//     $fclose(fd);
// endtask

// version for raw data

logic [DATA_WIDTH-1:0] data;
byte byte_data[(DATA_WIDTH/8)];
task readfile;
    queue.delete();
    DEST = 255;
    Last_i = 0;
    while (!$feof(fd)) begin        // Loop in questasim
        reader;
        loader;
        queue.push_back(data); 
        $display("data: %h", data);
    end
    $fclose(fd);
    #100;
endtask

//read final hash

function logic [63:0] read_hash (logic [63:0] TDATA_o, count, count2); 
begin
    case(DATA_WIDTH)
    8: begin
            if (count == 1) begin Dtmp [count2][63:56]  = TDATA_o; end
            if (count == 2) begin Dtmp [count2][55:48]  = TDATA_o; end
            if (count == 3) begin Dtmp [count2][47:40]  = TDATA_o; end
            if (count == 4) begin Dtmp [count2][39:32]  = TDATA_o; end
            if (count == 5) begin Dtmp [count2][31:24]  = TDATA_o; end
            if (count == 6) begin Dtmp [count2][23:16]  = TDATA_o; end
            if (count == 7) begin Dtmp [count2][15:8]   = TDATA_o; end
            if (count == 8) begin Dtmp [count2][7:0]    = TDATA_o; Dtmp [count2] = revers_byte(Dtmp [count2]); cnt = 0; cnt2 = cnt2 - 1; end
        end
    16: begin
            if (count == 1) begin Dtmp [count2][63:48]  = TDATA_o; end
            if (count == 2) begin Dtmp [count2][47:32]  = TDATA_o; end
            if (count == 3) begin Dtmp [count2][31:16]  = TDATA_o; end
            if (count == 4) begin Dtmp [count2][15:0]   = TDATA_o; Dtmp [count2] = revers_byte(Dtmp [count2]); cnt = 0; cnt2 = cnt2 - 1; end
        end
    32: begin
            if (count == 1) begin Dtmp [count2][63:32]  = TDATA_o; end
            if (count == 2) begin Dtmp [count2][31:0]   = TDATA_o; Dtmp [count2] = revers_byte(Dtmp [count2]); cnt = 0; cnt2 = cnt2 - 1; end
        end
    64: begin
            if (count == 1) begin Dtmp [count2] = TDATA_o; Dtmp [count2] = revers_byte(Dtmp [count2]); cnt = 0; cnt2 = cnt2 - 1; end
        end
    endcase
end
endfunction

// reverse byte order

function logic [63:0] revers_byte(logic [63:0] data);
	logic [63:0] res;

	begin
		res = data;
		res = ((res<<32)  & 64'hFFFFFFFF00000000)|((res>>32) & 64'h00000000FFFFFFFF);
		res = ((res<<16)  & 64'hFFFF0000FFFF0000)|((res>>16) & 64'h0000FFFF0000FFFF);
		res = ((res<<8)   & 64'hFF00FF00FF00FF00)|((res>>8)  & 63'h00FF00FF00FF00FF);
		return res;
	end
endfunction  

// Побайтовое чтение файла с данными для которых нужно получить хэш 

task reader;
    for (int i = 1; i <= DATA_WIDTH/8; i++) begin
        if(!$feof(fd))
            byte_data[(DATA_WIDTH/8)-i] = $fgetc(fd);
        else
            byte_data[(DATA_WIDTH/8)-i] = 8'b0;
    end
endtask

// Объединение байт в слово размером DATA_WIDTH

task loader;
    case (DATA_WIDTH/8)
    1 :    data = byte_data[0];
    2 :    data = {byte_data[1], byte_data[0]};
    4 :    data = {byte_data[3], byte_data[2], byte_data[1], byte_data[0]};
    8 :    data = {byte_data[7], byte_data[6], byte_data[5], byte_data[4], byte_data[3], byte_data[2], byte_data[1], byte_data[0]};
    default :    data = {byte_data[0], byte_data[1]};
    endcase
endtask

// Выводит значение SHA в терминал

task print_term;
    file_out = $fopen(FILE_OUT, "w");
//    $display("Result: %h", D_result [i]);
    for (int i = 0; i<SHA/DATA_WIDTH; i++) begin
        $display("%h", D_result [i]);
        $sformat(line_out, "%h", D_result [i]);
        $fwrite(file_out, "%s", line_out);
    end
    $fclose(file_out);
endtask

// Выводит значение SHA в файл

task print_file;
    file_out = $fopen(FILE_OUT, "w");
    begin
    if (Mode == 1'b0) begin 
        $display("Рассчитаный хэш: %h", Dtmp [24:0]);
        $sformat(line_out, "%h", Dtmp [24:0]); 
    end
    else begin
        if (USER == 2'b00) begin 
            $display("Рассчитаный хэш: %h%h", Dtmp [24:22], Dtmp [21][63:32]);
            $sformat(line_out, "%h%h", Dtmp [24:20], Dtmp [21][63:32]); 
        end
        if (USER == 2'b01) begin 
            $display("Рассчитаный хэш: %h", Dtmp [24:21]);
            $sformat(line_out, "%h", Dtmp [24:21]); 
        end
        if (USER == 2'b10) begin 
            $display("Рассчитаный хэш: %h", Dtmp [24:19]);
            $sformat(line_out, "%h", Dtmp [24:19]); 
        end
        if (USER == 2'b11) begin 
            $display("Рассчитаный хэш: %h", Dtmp [24:17]);
            $sformat(line_out, "%h", Dtmp [24:17]); 
        end
    end
    $fwrite(file_out, "%s\n", line_out);
    $fclose(file_out);
    end
endtask
	
endmodule 