`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.02.2024 20:42:36
// Design Name: 
// Module Name: AXI_SHA_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// `include "test.mem"

module AXI_SHA_tb();
localparam WIDTH = 16;

localparam SHA = 512;

logic ACLK;
logic ARESETn;
logic [1:0] USER;
logic ID;
logic VALID_i;

logic TREADY;

logic [15:0] in_data;
logic how_to_last;

logic [15:0] out_data;
logic [7:0] i;

// logic SHA_valid;
logic Mode;
logic Last;

logic Ready;

localparam FILE_IN   = "Copilot.bin";
localparam FILE_OUT      = "output.txt";

integer file_out;
string  line_out;

int j;

logic [(1600/WIDTH)-1:0][WIDTH-1:0] D_result;
logic [1599-1:0] Dres;
logic [7:0] cnt;

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
logic [WIDTH-1:0] TDATA_o;

logic TREADY_reg;
logic TVALID_o_reg;

logic ARESETn_reg;
logic ARESETn_assert;
logic read;

bit [WIDTH-1:0] queue [$];

int queue_length;

int status;

int rcnt;

int len;
int cnt_l;

// AXI tx logic

logic [(WIDTH/8)-1:0] TKEEP_i;
logic [(WIDTH/8)-1:0] TSTRB_i;
logic [7:0] TDEST_i;
logic  [1:0] TUSER_i; //[2:0] for byte_numb
logic  TID_i;
logic  TVALID_i;
logic  TLAST_i;
logic  [WIDTH-1:0] TDATA_i;

always #5 ACLK = !ACLK;

// Начальные значения

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b1;
    ARESETn_reg = 1'b1;
    VALID_i = 1'b1;
    in_data = 16'd0;
    how_to_last = 1'b0;
    // USER = 2'd0;		// Еще используется? Мб перенести ID сюда 
    ID = 1'b0;              // 0 - SHA3-224, 1 - SHA3-256, 2 - SHA3-384, 3 - SHA3-512
    // SHA_valid = 1'b0;
	Mode = 1'b1;
	cnt = 8'b0;
    
    i = 8'b0;
    DEST = 0;
    cnt_cd = 0;
    rcnt = 0;
    cnt_l = 0;

end

// Перевод размера SHA в сигнал

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
    // Открытие файла и проверка 

    //    fd = $fopen("Copilot.bin","r");
    fd = $fopen("1600.bin","r");
    // fd = $fopen("order.bin","r");
    //    fd = $fopen("test.docx","r");
    //    fd = $fopen("test_1.bin","r");
    if (fd) $display("Success :%d", fd);
    else    $display("Error :%d", fd);
    readfile;
end

always @(posedge(ACLK)) begin
        TREADY_reg = TREADY;
end

always @(posedge(ACLK)) begin
    if (TREADY_reg == 1'b1 && ARESETn_assert == 1'b1) begin
        if(DEST < ((1600 - SHA*2)/WIDTH) - 1) begin // Видимо где-то здесь ошибка
            if (queue_length >= 1) begin
                in_data = queue.pop_front();
                queue_length = queue.size();
            end
            if (queue_length == 0) begin
                in_data = 0;
                DEST = DEST;
            end
            if (queue_length == 0 && TID_o == 1'b1) begin
                in_data = 0;
                ID = 1'b1;
                how_to_last = 1'b1;     // Добавить расчет last block заранее 
                #50                     
                ID = 1'b0;
                queue_length = queue.size();
                DEST = 255;
            end
            DEST = DEST + 1;
            cnt_cd = 0;
            $display("queue_length: %d , cnt: %d, data: %h", queue_length, DEST, in_data, $time);
        end
        else if (DEST == 255)
            DEST = 0;
        else begin
            in_data = queue.pop_front();
            ID = 1'b1;
            #50 ID = 1'b0;
            #20 DEST = 255;
            #20;
        end
    end
end

// AXI TX

logic [1:0] state;

localparam int 	IDLE  = 0,  WAIT_READY   = 1,	DATA_OUT   = 2, TLAST_iUT   = 3;

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
                TVALID_i <= VALID_i;
                TDEST_i <= DEST;
                if (TREADY) state <= DATA_OUT;
            end
            DATA_OUT: begin
                TDATA_i <= in_data;
                TUSER_i <= USER;
                TID_i <= ID;
                TVALID_i <= VALID_i;
                TDEST_i <= DEST;
                if (TREADY && ~how_to_last) state <= DATA_OUT;
                else state <= TLAST_iUT;
            end
            TLAST_iUT: begin
                TLAST_i <= 1'b1;
                TID_i <= ID;
                if (~how_to_last) state <= WAIT_READY;
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
        D_result [cnt-1] = TDATA_o;
    end
    if (TVALID_o_reg == 1'b1 &&  TLAST_o == 1'b1) begin
        cnt = cnt + 1;
        D_result [cnt-1] = TDATA_o;
        print_2;
        #20 $stop;
    end
end

// Версия с чтением конца файла из самого файла

// logic [WIDTH-1:0] data;
// byte byte_data[(WIDTH/8)];
// task readfile;
//     queue.delete();
//     DEST = 255;
//     how_to_last = 0;
//     len = $fgetc(fd);
//     // while (!$feof(fd)) begin
//     while (cnt_l < len) begin
//         for (i = 0; i < (WIDTH/8); i++) begin
//             byte_data[i] = $fgetc(fd);
//             // $display("i: %d", i);
//             cnt_l = cnt_l + 1;
//         end
//         loader;
//         queue.push_back(data); // Записываем данные в очередь
//     end
//     queue_length = queue.size();
//     $fclose(fd);
// endtask

// Версия для неподготовленных файлов

logic [WIDTH-1:0] data;
byte byte_data[(WIDTH/8)];
task readfile;
    queue.delete();
    DEST = 255;
    how_to_last = 0;
    while (!$feof(fd)) begin        // Loop в questasim
        byte_data[1] = $fgetc(fd); 
        byte_data[0] = $fgetc(fd); 
        loader;
        queue.push_back(data); 
        #1;
    end
    queue_length = queue.size();
    $fclose(fd);
    #100;
endtask


task loader;
    case (WIDTH/8)
    1 :    data = byte_data[0];
    2 :    data = {byte_data[1], byte_data[0]};
    4 :    data = {byte_data[3], byte_data[2], byte_data[1], byte_data[0]};
    8 :    data = {byte_data[7], byte_data[6], byte_data[5], byte_data[4], byte_data[3], byte_data[2], byte_data[1], byte_data[0]};
    default :    data = {byte_data[0], byte_data[1]};
    endcase
endtask

task print_2;
    file_out = $fopen(FILE_OUT, "w");
//    $display("Result: %h", D_result [i]);
    for (int i = 0; i<SHA/WIDTH; i++) begin
        $display("%h", D_result [i]);
        $sformat(line_out, "%h", D_result [i]);
        $fwrite(file_out, "%s", line_out);
    end
    $fclose(file_out);
endtask

task print_3;
    file_out = $fopen(FILE_OUT, "w");
    begin
    if (Mode == 1'b0) begin 
        $display("Result: %h", Dres [1599:0]);
        $sformat(line_out, "%h", Dres [1599:0]); 
    end
    else begin
        if (USER == 2'b00) begin 
            $display("Result: %h", Dres [223:0]);
            $sformat(line_out, "%h", Dres [223:0]); 
        end
        if (USER == 2'b01) begin 
            $display("Result: %h", Dres [255:0]);
            $sformat(line_out, "%h", Dres [255:0]); 
        end
        if (USER == 2'b10) begin 
            $display("Result: %h", Dres [383:0]);
            $sformat(line_out, "%h", Dres [383:0]); 
        end
        if (USER == 2'b11) begin 
            $display("Result: %h", Dres [511:0]);
            $sformat(line_out, "%h", Dres [511:0]); 
        end
    end
    $fwrite(file_out, "%s\n", line_out);
    $fclose(file_out);
    end
endtask
	
endmodule 