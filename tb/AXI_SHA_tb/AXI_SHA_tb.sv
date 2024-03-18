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


module AXI_SHA_tb();
localparam WIDTH = 16;

logic ACLK;
logic ARESETn;
logic [1:0] USER;
logic ID;
logic VALID_i;

logic TREADY;

logic [15:0] in_data;
logic how_to_last;

logic [15:0] out_data;
logic [4:0][4:0][63:0] D_out;
logic [7:0] i;

// logic SHA_valid;
logic Mode;
logic Last;

logic Ready;

localparam FILE_IN   = "Copilot.bin";
localparam FILE_OUT      = "output.txt";

integer result;
integer file_in, file_out;
string  line_in, line_out;

int j;

wire   [0:4][0:4][63:0]  	Dout;

logic [(1600/WIDTH)-1:0][WIDTH-1:0] D_result;
logic [1599-1:0] Dres;
logic [7:0] cnt;

logic [15:0] line;

int fd; // file descriptor

AXI_SHA AXI_SHA_i(.*);

int SHA;

logic [7:0] cnt_data;
logic [4:0] cnt_cd;

logic [1:0] TID_o;
logic [3:0] TUSER_o;
logic TKEEP_o;
logic TSTRB_o;
logic TDEST_o;
logic TVALID_o;
logic TLAST_o;
logic [WIDTH-1:0] TDATA_o;

bit [WIDTH-1:0] queue [$];
int queue_length;

always #5 ACLK = !ACLK;

// Начальные значения

initial begin

    ACLK = 1'b1;
    ARESETn = 1'b0;
    VALID_i = 1'b1;
    in_data = 16'd0;
    how_to_last = 1'b0;
    USER = 2'b0;		// Еще используется? Мб перенести ID сюда 
    ID = 1'b0;              // 0 - SHA3-224, 1 - SHA3-256, 2 - SHA3-384, 3 - SHA3-512
    // SHA_valid = 1'b0;
	Mode = 1'b1;
	cnt = 8'b0;
    
    i = 8'b0;
    cnt_data = 0;
    cnt_cd = 0;

    // Открытие файла и проверка 

//    fd = $fopen("Copilot.bin","r");
    fd = $fopen("1600.bin","r");
//    fd = $fopen("order.bin","r");
    if (fd) $display("Success :%d", fd);
    else    $display("Error :%d", fd);
end

//// Хэш от 0

initial begin
    #50 ARESETn = 1'b1;
    USER = 2'd0;
//	 in_data = 16'd6; // 16'd0
//	 how_to_last = 1'b1;
//	 #50 SHA_valid = 1'b1;
//	 #50 SHA_valid = 1'b0;
end

initial begin
logic [15:0] data;
automatic byte unsigned byte_data[2];
    while (!$feof(fd)) begin
        byte_data[0] = $fgetc(fd); // Читаем старший байт
        byte_data[1] = $fgetc(fd); // Читаем младший байт
        data = {byte_data[0], byte_data[1]}; // Соединяем байты в 16-битное значение
        queue.push_back(data); // Записываем данные в очередь
        $display("Я дурак, который не видит конец файла", $time);
    end
    $fclose(fd);
    queue_length = queue.size();
end

//Чтение бинарного файла
// Добавить счетчик до какого момента можно отправлять, проверку когда заново считывать

// Рабочий вариант

// always @(posedge(ACLK)) begin
//     if (TREADY == 1'b1 && !$feof(fd)) begin
//         if (!$feof(fd)) begin
//             $fgets(line, fd);
//             $display("line : %h", line, $time);
//             in_data = line;
//         end
//         if ($feof(fd)) begin
//             ID = 1'b1;
//             how_to_last = 1'b1;     // Добавить расчет last block заранее 
//             #50                     // TODO: починить костыль
//             ID = 1'b0;
//         end
//     end
// end

// экспериментальный

always @(posedge(ACLK)) begin
    if(cnt_data < (1600 - SHA*2)/WIDTH) begin
        if (TREADY == 1'b1 && !$feof(fd)) begin
            if (queue_length > 1) begin
                in_data = queue.pop_front();
                queue_length = queue.size();
            end
            if (queue_length == 1) begin
                ID = 1'b1;
                in_data = queue.pop_front();
                how_to_last = 1'b1;     // Добавить расчет last block заранее 
                #50                     // TODO: починить костыль
                ID = 1'b0;
                queue_length = queue.size();
            end
        end
        cnt_data = cnt_data + 1;
        cnt_cd = 0;
    end
    else
        if(cnt_cd == 0) begin
            ID = 1'b1;
            #50 ID = 1'b0;           // Сомнительно и не окэй
            cnt_cd = cnt_cd + 1;
        end
        if (cnt_cd < 25 && cnt_cd > 0)
            cnt_cd = cnt_cd + 1;
        if (cnt_cd == 25)
            cnt_data = 0;
end

//// Запись данных из файла

// always @(posedge ACLK) begin
//     if (TVALID_o == 1'b1 && TLAST_o == 1'b0) begin
//         cnt = cnt + 1;
//         Dres [(WIDTH*(cnt-3))-1:(WIDTH*(cnt-2))] = TDATA_o;
//     end
//     if (TVALID_o == 1'b1 &&  TLAST_o == 1'b1) begin
//         cnt = cnt + 1;
//         Dres [(WIDTH*(cnt-3))-1:(WIDTH*(cnt-2))] = TDATA_o;
//         print_3;
//         #20 $stop;
//     end
// end

always @(posedge ACLK) begin
    if (TVALID_o == 1'b1 && TLAST_o == 1'b0) begin
        cnt = cnt + 1;
        D_result [cnt-3] = TDATA_o;
    end
    if (TVALID_o == 1'b1 &&  TLAST_o == 1'b1) begin
        cnt = cnt + 1;
        D_result [cnt-3] = TDATA_o;
        print_2;
        #20 $stop;
    end
end

//

// Вывод нужного количества SHA

initial begin
    case(USER)
        0 : SHA = 224;
        1 : SHA = 256;
        2 : SHA = 384;
        3 : SHA = 512;
        default : SHA = 256;
    endcase
end

// initial begin
//     file_out = $fopen(out.txt, "w");
//     $fwrite(file_out, "%s", "xyz");
//     $fclose(file_out);
// end

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

//// После расчета последнего сообщения переводит SHA в режим хранения
	
//always @(posedge ACLK) begin
//	if(Ready == 1'b1) begin
//	   SHA_valid = 1'b0;
//    end
//end

//// Не помню зачем добавил...

// initial begin
// 	forever begin
// 	#1;
// 	for (int i = 0; i<5; i++)
// 		for (int j = 0; j<5; j++)
// 			D_out[i][j] = revers_byte(Dout[i][j]);
// 	end
// end

//// Функция, которая будет ловить поток с АКС�? передатчика

//always @(posedge ACLK) begin
//    for(cnt = 0; cnt<(1600/WIDTH); cnt++) begin
//        if (Ready == 1'b1 && Last == 1'b0) begin
//            D_result [(WIDTH*cnt)-1:WIDTH*(cnt-1)] = Mode_out;
//            cnt = cnt + 1;
//        end
//        if (Ready == 1'b1 &&  Last == 1'b1) begin
//            D_result [(WIDTH*cnt)-1:WIDTH*(cnt-1)] = Mode_out;
//            cnt = cnt + 1;
//            $display("Result: %h", D_result);
//            #20 $stop;
//        end
//    end
//end
//


// Переворачивайт порядок байт (может не понадобиться)

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

// Функция для вывода правильного хэша в терминал

task print;
	// file_out = $fopen(FILE_OUT, "w");
	$display("Hash from function: %h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	$display("%h%h%h%h", revers_byte(Dout[4][0]), revers_byte(Dout[0][1]), revers_byte(Dout[1][1]), revers_byte(Dout[2][1]));
	$sformat(line_out, "%h%h%h%h", revers_byte(Dout[0][0]), revers_byte(Dout[1][0]), revers_byte(Dout[2][0]), revers_byte(Dout[3][0]));
	// $fwrite(file_out, "%s\n", line_out);
	// $fclose(file_out);
	# 10 $stop;
endtask
	
endmodule 